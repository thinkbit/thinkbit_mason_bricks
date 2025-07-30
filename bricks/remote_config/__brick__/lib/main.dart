import 'dart:async';

import 'package:consumer/app/services/remote_config_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the Remote Config service (call this after Firebase.initializeApp())
  await RemoteConfigService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _remoteConfigService = RemoteConfigService.instance;
  late StreamSubscription<dynamic>? _configSubscription;

  bool _isAppMaintenance = true;

  @override
  void initState() {
    super.initState();
    // Set initial value
    _loadConfig();

    // Listen for updates and rebuild the widget
    _configSubscription = _remoteConfigService.onConfigUpdated.listen((_) {
      if (mounted) {
        setState(_loadConfig);
      }
    });
  }

  void _loadConfig() {
    _isAppMaintenance = _remoteConfigService.getBool(rcIsAppMaintenance);
  }

  @override
  void dispose() {
    // Clean up the subscription
    _configSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFeatureEnabled = _remoteConfigService.getBool(
      rcIsFeatureEnabled,
    );
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: _isAppMaintenance
            ? const MaintenancePage()
            : HomePage(isNewFeatureEnabled: isFeatureEnabled),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    required this.isNewFeatureEnabled,
    super.key,
  });

  final bool isNewFeatureEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 32,
      children: [
        const Text(
          'Home Page',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: !isNewFeatureEnabled ? null : () {},
          child: Text(
            !isNewFeatureEnabled
                ? 'Feature Coming Soon!'
                : 'Go to New Feature!',
          ),
        ),
      ],
    );
  }
}

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 32,
      children: [
        Icon(
          Icons.construction,
          size: 48,
        ),
        Text(
          'Under Maintenance',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
