import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._();
  static final FirebaseMessagingService instance = FirebaseMessagingService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final _flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    '{{channel_id}}', // id
    '{{channel_name}}', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  /// Controller for exposing FCM message events to the UI/other services.
  final _messageStreamController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStream => _messageStreamController.stream;

  /// Callback for token updates.
  Function(String)? onTokenUpdate;

  @pragma('vm:entry-point')
  static void onDidReceiveBackgroundNotificationResponse(
    NotificationResponse? details,
  ) {
    if (details == null) return;

    debugPrint('onDidReceiveBackgroundNotificationResponse');
    debugPrint('payload ${details.payload}');
    
    if (details.payload != null) {
      instance._messageStreamController.add(json.decode(details.payload!));
    }
  }

  Future<void> initFirebaseMessaging({Function(String)? onTokenUpdate}) async {
    this.onTokenUpdate = onTokenUpdate;
    
    await _requestPermissions();
    _setupTokenListeners();
    _onBackgroundMessage();
    _onForegroundMessage();
    await _handleMessageInteraction();
    await _initializeLocalNotifications();
  }

  void _setupTokenListeners() {
    // Get initial token
    getFcmToken().then((token) {
      if (token != null) onTokenUpdate?.call(token);
    });

    // Listen for refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token Refreshed: $newToken');
      onTokenUpdate?.call(newToken);
    });
  }

  Future<String?> getFcmToken() async {
    try {
      final response = await _firebaseMessaging.getToken();
      debugPrint('FCM token: $response');
      return response;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  Future<bool> _requestPermissions() async {
    debugPrint('Requesting permissions');
    try {
      final response = await _firebaseMessaging.requestPermission();
      return response.authorizationStatus == AuthorizationStatus.authorized;
    } on Exception catch (e, s) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  /// Listen to foreground notifications
  StreamSubscription<RemoteMessage> _onForegroundMessage() {
    return FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        debugPrint('Foreground message received, data: ${message.data}');

        if (message.notification != null) {
          _displayNotificationsAndroid(message);
        }
        
        _messageStreamController.add(message.data);
      },
    );
  }

  static void _onBackgroundMessage() {
    return FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  @pragma('vm:entry-point')
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    debugPrint("Handling a background message: ${message.messageId}");

    log(
      'Background message received, '
      'data: ${message.data}, '
      'notification title: ${message.notification?.title}',
    );
  }

  static void _displayNotificationsAndroid(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification == null) return;

    final androidNotificationDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      icon: '{{notification_icon}}', 
      importance: Importance.max,
      priority: Priority.high,
    );
    
    final payload = json.encode(message.data);

    _flutterLocalNotificationPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: androidNotificationDetails,
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  Future<void> _handleMessageInteraction() async {
    debugPrint('Handling message interactions');
    
    // Check if app was opened from a terminated state via a notification
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Listen for messages when app is in background but still in memory
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('{{notification_icon}}'),
      iOS: DarwinInitializationSettings(),
    );

    await _flutterLocalNotificationPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse? details) {
        if (details?.payload != null) {
          _messageStreamController.add(json.decode(details!.payload!));
        }
      },
      onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
    );

    // Create the channel for Android
    await _flutterLocalNotificationPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  void _handleMessage(RemoteMessage message) {
    debugPrint('Opening app via notification: ${message.data}');
    _messageStreamController.add(message.data);
  }

  void dispose() {
    _messageStreamController.close();
  }
}
