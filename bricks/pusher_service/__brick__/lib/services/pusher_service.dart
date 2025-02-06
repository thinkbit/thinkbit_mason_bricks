import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/material.dart';

class PusherService {
  factory PusherService() => _instance;
  PusherService._internal();

  late PusherChannelsClient pusher;

  static final PusherService _instance = PusherService._internal();

  static final String _host = 'localhost';
  static final String _scheme = 'ws';
  static final String _key = 'key';
  static final int _port = 6001;

  static final String _baseUrl = 'http://localhost:8000';
  static final Uri _authEndpoint = Uri.parse('$_baseUrl/api/admin/broadcasting/auth');

  static Map<String, String> _authHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> init() async {
    // PusherChannelsPackageLogger.enableLogs();

    final hostOptions = PusherChannelsOptions.fromHost(
      scheme: _scheme,
      host: _host,
      key: _key,
      port: _port,
    );

    pusher = PusherChannelsClient.websocket(
      options: hostOptions,
      connectionErrorHandler: (exception, trace, refresh) async {
        debugPrint('Error connecting to pusher: $exception');
        refresh();
        await pusher.reconnect();
      },
    );

    debugPrint('Connecting to pusher...');

    try {
      await pusher.connect();

      await pusher.connect().whenComplete(
        () {
          debugPrint('Connected to pusher');
        },
      );
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
    if (pusher.isDisposed) return null;
    final channel = pusher.publicChannel(
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
    void Function(ChannelReadEvent) onEvent,
  ) async {
    if (pusher.isDisposed) return null;
    final channel = pusher.privateChannel(
      channelName,
      authorizationDelegate: EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: _authEndpoint,
        headers: _authHeaders('token'),
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
    required void Function(ChannelReadEvent) onSubscribed,
    required void Function(ChannelReadEvent) onMemberAdded,
    required void Function(ChannelReadEvent) onMemberRemoved,
  }) async {
    if (pusher.isDisposed) return null;
    final presence = pusher.presenceChannel(
      'presence-$channelName',
      authorizationDelegate: EndpointAuthorizableChannelTokenAuthorizationDelegate.forPresenceChannel(
        authorizationEndpoint: _authEndpoint,
        headers: _authHeaders('token'),
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
    if (pusher.isDisposed) return;
    pusher.dispose();
    debugPrint('Disposed pusher');
  }
}
