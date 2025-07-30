import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// A service class to interact with Firebase Remote Config.
///
/// This class provides a singleton instance to be used throughout the app,
/// simplifying the process of fetching, activating, and listening to
/// remote configuration changes.

const rcIsAppMaintenance = 'is_app_maintenance';
const rcIsFeatureEnabled = 'is_feature_enabled';

class RemoteConfigService {
  RemoteConfigService._();

  /// The singleton instance of [RemoteConfigService].
  static final RemoteConfigService instance = RemoteConfigService._();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  final _configUpdatedController = StreamController<void>.broadcast();

  /// A stream that emits an event when the remote config is updated and activated.
  ///
  /// Widgets can listen to this stream to rebuild with the new config values.
  Stream<void> get onConfigUpdated => _configUpdatedController.stream;

  /// Initializes the Remote Config service.
  ///
  /// This method should be called once during app startup (e.g., in `main.dart`).
  /// It sets the configuration settings, defines default values, fetches the
  /// latest config from the server, and sets up a listener for real-time updates.
  Future<void> initialize() async {
    try {
      // Set config settings for fetch frequency.
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          // A shorter interval for debug mode, a longer one for production.
          minimumFetchInterval: kDebugMode
              ? const Duration(minutes: 5)
              : const Duration(hours: 1),
        ),
      );

      // Set default values. These are used if no values are fetched from the server.
      await _remoteConfig.setDefaults(
        const {
          rcIsAppMaintenance: false,
          rcIsFeatureEnabled: false,
        },
      );

      // Fetch and activate the latest config.
      await _fetchAndActivate();

      // Listen for real-time updates from the Firebase backend.
      _remoteConfig.onConfigUpdated.listen((event) async {
        debugPrint('Remote config updated keys: ${event.updatedKeys}');
        await _remoteConfig.activate();
        // Notify listeners within the app that the config has been updated.
        _configUpdatedController.add(null);
        debugPrint('Remote config updated and activated.');
      });
    } catch (e) {
      // You could use FirebaseCrashlytics here to report errors
      debugPrint('Failed to initialize Remote Config: $e');
    }
  }

  Future<void> _fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Error fetching or activating remote config: $e');
    }
  }

  String getString(String key) => _remoteConfig.getString(key);
  bool getBool(String key) => _remoteConfig.getBool(key);
  int getInt(String key) => _remoteConfig.getInt(key);
  double getDouble(String key) => _remoteConfig.getDouble(key);

  void dispose() => _configUpdatedController.close();
}
