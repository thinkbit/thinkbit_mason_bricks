import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/material.dart';

class PusherService {
  factory PusherService() => _instance;
  PusherService._internal();

  PusherChannelsClient? _pusher;

  static final PusherService _instance = PusherService._internal();

  static final String _host = 'localhost';
  static final String _scheme = 'ws';
  static final String _key = 'key';
  static final int _port = 6001;

  static final String _baseUrl = 'http://localhost:8000';
  static final Uri _authEndpoint = Uri.parse(
    '$_baseUrl/api/admin/broadcasting/auth',
  );

  static Map<String, String> _authHeaders(String token) {
    return {'Authorization': 'Bearer $token'};
  }

  PusherChannelsClient? get _activePusher {
    final client = _pusher;
    if (client == null || client.isDisposed) return null;
    return client;
  }

  Future<void> init() async {
    // PusherChannelsPackageLogger.enableLogs();

    final hostOptions = PusherChannelsOptions.fromHost(
      scheme: _scheme,
      host: _host,
      key: _key,
      port: _port,
    );

    final client = PusherChannelsClient.websocket(
      options: hostOptions,
      connectionErrorHandler: (exception, trace, refresh) async {
        debugPrint('Error connecting to pusher: $exception');
        refresh();
        await _activePusher?.reconnect();
      },
    );
    _pusher = client;

    debugPrint('Connecting to pusher...');

    try {
      await client.connect().whenComplete(() {
        debugPrint('Connected to pusher');
      });
    } on PusherChannelsClientDisposedException catch (e) {
      debugPrint('Pusher client was disposed: $e');
    } catch (e) {
      debugPrint('Error connecting to pusher: $e');
    }
  }

  PublicChannel? subscribeToPublic(
    String channelName,
    String eventName,
    void Function(ChannelReadEvent) onEvent,
  ) {
    final client = _activePusher;
    if (client == null) return null;
    final channel = client.publicChannel(
      channelName,
      forceCreateNewInstance: true,
    );

    channel.bind(eventName).listen(onEvent);
    channel.subscribe();

    channel.whenSubscriptionSucceeded().listen((value) {
      debugPrint('Subscribed to $channelName');
    });

    channel.onSubscriptionError().listen((error) {
      debugPrint('Error subscribing to $channelName: ${error.data}');
    });

    return channel;
  }

  Future<PrivateChannel?> subscribeToPrivate(
    String channelName,
    String eventName,
    void Function(ChannelReadEvent) onEvent, {
    required String token,
  }) async {
    final client = _activePusher;
    if (client == null) return null;
    final channel = client.privateChannel(
      channelName,
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
            authorizationEndpoint: _authEndpoint,
            headers: _authHeaders(token),
          ),
      forceCreateNewInstance: true,
    );

    channel.bind(eventName).listen(onEvent);
    channel.subscribe();

    channel.whenSubscriptionSucceeded().listen((value) {
      debugPrint('Subscribed to $channelName');
    });

    channel.onSubscriptionError().listen((error) {
      debugPrint('Error subscribing to $channelName: ${error.data}');
    });

    return channel;
  }

  Future<PresenceChannel?> subscribeToPresence(
    String channelName, {
    required String token,
    required void Function(ChannelReadEvent) onSubscribed,
    required void Function(ChannelReadEvent) onMemberAdded,
    required void Function(ChannelReadEvent) onMemberRemoved,
  }) async {
    final client = _activePusher;
    if (client == null) return null;
    final presence = client.presenceChannel(
      'presence-$channelName',
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate.forPresenceChannel(
            authorizationEndpoint: _authEndpoint,
            headers: _authHeaders(token),
          ),
      forceCreateNewInstance: true,
    )..subscribe();

    presence.whenSubscriptionSucceeded().listen((event) {
      debugPrint('Subscribed to $channelName');

      onSubscribed(event);
    });

    presence.whenMemberAdded().listen((event) {
      debugPrint('Member added: $channelName');
      onMemberAdded(event);
    });

    presence.whenMemberRemoved().listen((event) {
      debugPrint('Member removed: $channelName');
      onMemberRemoved(event);
    });

    presence.onSubscriptionError().listen((error) {
      debugPrint('Error subscribing to $channelName: ${error.data}');
    });

    return presence;
  }

  void unsubPublic(PublicChannel? channel) {
    if (channel == null) return;
    channel.unsubscribe();
    debugPrint('Unsubscribed from ${channel.name}');
  }

  void unsubPrivate(PrivateChannel? channel) {
    if (channel == null) return;
    channel.unsubscribe();
    debugPrint('Unsubscribed from ${channel.name}');
  }

  void unsubPresence(PresenceChannel? channel) {
    if (channel == null) return;
    channel.unsubscribe();
    debugPrint('Unsubscribed from ${channel.name}');
  }

  void dispose() {
    final client = _activePusher;
    if (client == null) return;
    client.dispose();
    debugPrint('Disposed pusher');
  }
}
