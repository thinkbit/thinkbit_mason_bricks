import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final _flutterLocalNotificationPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  /// https://stackoverflow.com/questions/64314719/what-does-pragmavmprefer-inline-mean-in-flutter#:~:text=keyword%20in%20Kotlin-,%40pragma(%22vm%3Aentry%2Dpoint%22),-to%20mark%20a
  /// https://mrale.ph/dartvm/compiler/aot/entry_point_pragma.html
  @pragma('vm:entry-point')
  static void onDidReceiveBackgroundNotificationResponse(
    NotificationResponse? details,
  ) {
    if (details == null) return;

    debugPrint('onDidReceiveBackgroundNotificationResponse');
    debugPrint('payload ${details.payload}');
  }

  Future<void> initFirebaseMessaging() async {
    await _requestPermissions();
    _onBackgroundMessage();
    _onForegroundMessage();
    await _handleMessageInteraction();
  }

  Future<String?> getFcmToken() async {
    final response = await _firebaseMessaging.getToken();
    debugPrint('FCM token: $response');

    return response;
  }

  Future<bool> _requestPermissions() async {
    debugPrint('Requesting permissions');
    try {
      final response = await _firebaseMessaging.requestPermission();

      return response.authorizationStatus == AuthorizationStatus.authorized;
    } on Exception catch (e, s) {
      debugPrint('Error requesting permissions');
      debugPrint('e: $e)');
      debugPrint('s: $s)');

      return false;
    }
  }

  /// Listen to foreground notifications
  StreamSubscription<RemoteMessage> _onForegroundMessage() {
    return FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        debugPrint('Foreground message received, data: ${message.data}');

        if (message.notification != null) {
          debugPrint('Message has notification, ');
          debugPrint('notification: ${message.notification?.title}');
          debugPrint('notification: ${message.notification?.body}');
          _displayNotificationsAndroid(message);
        }
      },
    );
  }

  static void _onBackgroundMessage() {
    return FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    debugPrint("Handling a background message");

    log(
      'Background message received, '
      'data: ${message.data}, '
      'notification title: ${message.notification?.title}'
      'notification body: ${message.notification?.body}',
    );
  }

  static void _displayNotificationsAndroid(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification == null || android == null) {
      return;
    }

    final androidNotificationDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      icon: '@mipmap/ic_launcher',
      colorized: true,
      color: const Color(0xFFE07C4F),
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
    await _handleBackgroundMessageInteraction();
    _handleForegroundMessageInteraction();
    await _handleLocalNotificationInteraction();
  }

  Future<void> _handleBackgroundMessageInteraction() async {
    final initialMessage = await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  static StreamSubscription<RemoteMessage>
      _handleForegroundMessageInteraction() {
    return FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<void> _handleLocalNotificationInteraction() async {
    await _flutterLocalNotificationPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse? details) {
        if (details == null) return;

        debugPrint('onDidReceiveNotificationResponse');
        debugPrint('payload ${details.payload}');
      },
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );
  }

  static void _handleMessage(RemoteMessage message) {
    // _messageHandler?.call(message.data);
    debugPrint('_handleMessage');
    debugPrint('data ${message.data}');
  }
}
