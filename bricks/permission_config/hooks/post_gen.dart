import 'dart:io';
import 'package:mason/mason.dart';
import 'package:xml/xml.dart';

Future<void> run(HookContext context) async {
  final logger = context.logger;
  final vars = context.vars;

  final permissionTypes = (vars['permission_types'] as List).cast<String>();
  final permissionEntries = (vars['permissions'] as List)
      .cast<Map>()
      .map((m) => {
            'type': (m['type'] ?? '').toString(),
            'custom_message': (m['custom_message'] ?? '').toString(),
          })
      .where((m) => m['type']!.isNotEmpty)
      .toList();
  final existingPermissions = (vars['existing_permissions'] as List).cast<String>();

  final customMessageByType = <String, String>{
    for (final e in permissionEntries) e['type']!: e['custom_message']!.trim(),
  };

  final locationBackground = vars['location_background'] == true;

  final androidSdk = await _readAndroidSdkVersions(logger);
  final iosTarget = await _readIOSDeploymentTarget(logger);

  logger.info('');
  logger.info('📦 Detected Android SDK: compile=${androidSdk.compileSdk} target=${androidSdk.targetSdk}');
  if (iosTarget != null) {
    logger.info('📦 Detected iOS Deployment Target: $iosTarget');
  }

  final progress = logger.progress('Configuring platform permissions');

  for (final permission in permissionTypes) {
    final customMessage = customMessageByType[permission] ?? '';
    logger.info('🔧 Configuring permission: $permission');
    await _configurePermission(
      permission,
      customMessage,
      logger,
      androidSdk: androidSdk,
      iosDeploymentTarget: iosTarget,
      locationBackground: locationBackground && permission == 'location',
    );
  }

  await _configureIOSPodfileMacros(
    permissionTypes: permissionTypes + existingPermissions,
    locationBackground: locationBackground,
    logger: logger,
  );

  progress.complete('✅ Platform permissions configured');

  await _showCompletionSummary(permissionTypes, logger);
}

Future<void> _configurePermission(
  String permission,
  String customMessage,
  Logger logger, {
  required _AndroidSdk androidSdk,
  required String? iosDeploymentTarget,
  required bool locationBackground,
}) async {
  await _configureAndroidPermissions(permission, logger,
      androidSdk: androidSdk, locationBackground: locationBackground);

  await _configureIOSPermissions(
    permission,
    customMessage,
    logger,
    iosDeploymentTarget: iosDeploymentTarget,
    locationBackground: locationBackground,
  );
}

Future<void> _showCompletionSummary(
  List<String> permissions,
  Logger logger,
) async {
  logger.info('');
  logger.info('🎉 Configuration Complete!');
  logger.info('==========================');
  logger.info('');
  logger.info('🔐 Permissions: ${permissions.join(', ')}');
  logger.info('');

  logger.info('📁 Files modified:');

  if (await File('android/app/src/main/AndroidManifest.xml').exists()) {
    logger.success('   ✅ android/app/src/main/AndroidManifest.xml');
    if (await File('android/app/src/main/AndroidManifest.xml.bak').exists()) {
      logger.info('   📋 android/app/src/main/AndroidManifest.xml.bak (backup created)');
    }
  }

  if (await File('ios/Runner/Info.plist').exists()) {
    logger.success('   ✅ ios/Runner/Info.plist');
    if (await File('ios/Runner/Info.plist.bak').exists()) {
      logger.info('   📋 ios/Runner/Info.plist.bak (backup created)');
    }
  }

  logger.info('');
  logger.info('📄 Generated files:');
  logger.success('   ✅ lib/utils/permission_handler.dart');

  await _runFlutterPubGet(logger);

  logger.info('');
  logger.info('🚀 Next steps:');
  logger.info('   1. Import the generated utilities:');
  logger.info('      import \'package:your_app/utils/permission_handler.dart\';');

  logger.info('');
  logger.info('💡 Usage examples:');
  logger.info('   // Simple permission request');
  logger.info('   final granted = await PermissionHandler.requestCameraPermission();');
  logger.info('');

  logger.info('   // Check permission status');
  logger.info('   final isGranted = await PermissionHandler.isPermissionGranted(Permission.camera);');
  logger.info('');

  logger.success('🎊 Happy coding!');
}

Future<void> _configureAndroidPermissions(
  String permissionType,
  Logger logger, {
  required _AndroidSdk androidSdk,
  required bool locationBackground,
}) async {
  const androidManifestPath = 'android/app/src/main/AndroidManifest.xml';
  final file = File(androidManifestPath);

  if (!await file.exists()) {
    logger.warn('⚠️  AndroidManifest.xml not found, skipping Android configuration');
    return;
  }

  final permissions = _getAndroidPermissions(
    permissionType,
    androidSdk: androidSdk,
    locationBackground: locationBackground,
  );
  if (permissions.isEmpty) return;

  await _backupFile(androidManifestPath, logger);

  try {
    final xmlDoc = XmlDocument.parse(await file.readAsString());
    final manifest = xmlDoc.getElement('manifest');

    if (manifest == null) {
      logger.err('❌ Invalid AndroidManifest.xml structure');
      return;
    }

    bool modified = false;
    for (final permission in permissions) {
      final existing =
          xmlDoc.findAllElements('uses-permission').any((e) => e.getAttribute('android:name') == permission);

      if (!existing) {
        final permissionElement = XmlElement(XmlName('uses-permission'), [
          XmlAttribute(XmlName('android:name'), permission),
        ]);

        final applicationElement = manifest.getElement('application');
        if (applicationElement != null) {
          final appIndex = manifest.children.indexOf(applicationElement);
          manifest.children.insert(appIndex, permissionElement);
        } else {
          manifest.children.insert(0, permissionElement);
        }

        logger.success('   ✅ Android: $permission');
        modified = true;
      } else {
        logger.info('   ✔️  Android: $permission (already exists)');
      }
    }

    if (modified) {
      await file.writeAsString(xmlDoc.toXmlString(pretty: true, indent: '  '));
    }
  } catch (e) {
    logger.err('❌ Error parsing AndroidManifest.xml: $e');
  }
}

Future<void> _configureIOSPermissions(
  String permissionType,
  String customMessage,
  Logger logger, {
  required String? iosDeploymentTarget,
  required bool locationBackground,
}) async {
  const iosPlistPath = 'ios/Runner/Info.plist';
  final file = File(iosPlistPath);

  if (!await file.exists()) {
    logger.warn('⚠️  Info.plist not found, skipping iOS configuration');
    return;
  }

  final permissions = _getIOSPermissions(
    permissionType,
    customMessage,
    iosDeploymentTarget: iosDeploymentTarget,
    locationBackground: locationBackground,
  );
  if (permissions.isEmpty) return;

  await _backupFile(iosPlistPath, logger);

  try {
    final xmlDoc = XmlDocument.parse(await file.readAsString());
    XmlElement? rootDict;

    try {
      rootDict = xmlDoc.rootElement.children.whereType<XmlElement>().firstWhere((e) => e.name.local == 'dict');
    } catch (_) {
      rootDict = XmlElement(XmlName('dict'));
      xmlDoc.rootElement.children.add(rootDict);
    }

    bool modified = false;
    for (final entry in permissions.entries) {
      final existingKeys = rootDict.findElements('key');
      if (!existingKeys.any((e) => e.innerText == entry.key)) {
        final keyElement = XmlElement(XmlName('key'), [], [XmlText(entry.key)]);
        final stringElement = XmlElement(XmlName('string'), [], [XmlText(entry.value)]);

        rootDict.children.add(keyElement);
        rootDict.children.add(stringElement);

        logger.success('   ✅ iOS: ${entry.key}');
        modified = true;
      } else {
        logger.info('   ✔️  iOS: ${entry.key} (already exists)');
      }
    }

    if (modified) {
      await file.writeAsString(xmlDoc.toXmlString(pretty: true, indent: '  '));
    }
  } catch (e) {
    logger.err('❌ Error parsing Info.plist: $e');
  }
}

Future<void> _backupFile(String path, Logger logger) async {
  final file = File(path);
  if (await file.exists()) {
    final backupPath = '$path.bak';
    final backupFile = File(backupPath);
    if (!await backupFile.exists()) {
      await file.copy(backupPath);
    }
  }
}

List<String> _getAndroidPermissions(
  String type, {
  required _AndroidSdk androidSdk,
  required bool locationBackground,
}) {
  final permissions = <String>[];
  final compile = androidSdk.compileSdk;
  final target = androidSdk.targetSdk;

  switch (type.toLowerCase()) {
    case 'camera':
      permissions.add('android.permission.CAMERA');
      break;
    case 'microphone':
      permissions.add('android.permission.RECORD_AUDIO');
      break;
    case 'location':
      permissions.addAll([
        'android.permission.ACCESS_FINE_LOCATION',
        'android.permission.ACCESS_COARSE_LOCATION',
      ]);
      if (locationBackground && target >= 29) {
        permissions.add('android.permission.ACCESS_BACKGROUND_LOCATION');
      }
      break;
    case 'storage':
      if (target >= 33) {
        permissions.addAll([
          'android.permission.READ_MEDIA_IMAGES',
          'android.permission.READ_MEDIA_VIDEO',
          'android.permission.READ_MEDIA_AUDIO',
        ]);
      } else {
        permissions.addAll([
          'android.permission.READ_EXTERNAL_STORAGE',
          'android.permission.WRITE_EXTERNAL_STORAGE',
        ]);
      }
      break;
    case 'bluetooth':
      if (target >= 31) {
        permissions.addAll([
          'android.permission.BLUETOOTH_SCAN',
          'android.permission.BLUETOOTH_CONNECT',
          'android.permission.BLUETOOTH_ADVERTISE',
        ]);
      } else {
        permissions.addAll([
          'android.permission.BLUETOOTH',
          'android.permission.BLUETOOTH_ADMIN',
        ]);
      }
      break;
    case 'sensors':
      permissions.add('android.permission.BODY_SENSORS');
      if (compile >= 34) {
        permissions.add('android.permission.BODY_SENSORS_BACKGROUND');
      }
      break;
    case 'contacts':
      permissions.add('android.permission.READ_CONTACTS');
      break;
    case 'calendar':
      permissions.addAll([
        'android.permission.READ_CALENDAR',
        'android.permission.WRITE_CALENDAR',
      ]);
      break;
    case 'notifications':
      if (target >= 33) {
        permissions.add('android.permission.POST_NOTIFICATIONS');
      }
      break;
  }
  return permissions;
}

Map<String, String> _getIOSPermissions(
  String type,
  String customMessage, {
  required String? iosDeploymentTarget,
  required bool locationBackground,
}) {
  final permissions = <String, String>{};

  double deployment = 13.0;
  if (iosDeploymentTarget != null) {
    deployment = double.tryParse(iosDeploymentTarget) ?? deployment;
  }

  final defaultMessages = <String, String>{
    'camera': 'Required to capture photos and record video.',
    'microphone': 'Required to record audio for voice or video features.',
    'location': 'Required to determine your location for location-based features.',
    'location_bg': 'Required to access your location in the background.',
    'photo library': 'Required to select existing photos and videos.',
    'photo add': 'Required to save photos or videos to your library.',
    'contacts': 'Required to pick and display contacts.',
    'calendar': 'Required to read or add calendar events.',
    'sensor data': 'Required to enable motion and activity related features.',
    'speech recognition': 'Required to convert spoken words to text.',
    'bluetooth': 'Required to connect with nearby Bluetooth devices.',
    'bluetooth peripherals': 'Required to communicate with Bluetooth peripherals.',
    'notifications': 'Notifications keep you informed of important updates.',
  };

  String getMessage(String key) {
    if (customMessage.isNotEmpty) return customMessage;
    return defaultMessages[key] ?? 'Access to $key is required for full functionality.';
  }

  switch (type.toLowerCase()) {
    case 'camera':
      permissions['NSCameraUsageDescription'] = getMessage('camera');
      break;
    case 'microphone':
      permissions['NSMicrophoneUsageDescription'] = getMessage('microphone');
      break;
    case 'location':
      permissions['NSLocationWhenInUseUsageDescription'] = getMessage('location');
      // Always/Background
      if (locationBackground) {
        permissions['NSLocationAlwaysAndWhenInUseUsageDescription'] = getMessage('location_bg');
        if (deployment < 13.0) {
          permissions['NSLocationAlwaysUsageDescription'] = getMessage('location_bg');
        }
      }
      break;
    case 'bluetooth':
      permissions['NSBluetoothAlwaysUsageDescription'] = getMessage('bluetooth');
      permissions['NSBluetoothPeripheralUsageDescription'] = getMessage('bluetooth peripherals');
      break;
    case 'sensors':
      permissions['NSMotionUsageDescription'] = getMessage('sensor data');
      break;
    case 'contacts':
      permissions['NSContactsUsageDescription'] = getMessage('contacts');
      break;
    case 'calendar':
      permissions['NSCalendarsUsageDescription'] = getMessage('calendar');
      break;
    case 'photos':
      permissions['NSPhotoLibraryUsageDescription'] = getMessage('photo library');
      permissions['NSPhotoLibraryAddUsageDescription'] = getMessage('photo add');
      break;
    case 'speech':
      permissions['NSSpeechRecognitionUsageDescription'] = getMessage('speech recognition');
      permissions['NSMicrophoneUsageDescription'] ??= getMessage('microphone');
      break;
  }

  return permissions;
}

Future<void> _configureIOSPodfileMacros({
  required List<String> permissionTypes,
  required bool locationBackground,
  required Logger logger,
}) async {
  const podfilePath = 'ios/Podfile';
  final file = File(podfilePath);

  if (!await file.exists()) {
    logger.warn('⚠️  Podfile not found, skipping iOS macro configuration');
    return;
  }

  await _backupFile(podfilePath, logger);
  var content = await file.readAsString();

  // Build selected macros
  final macros = <String>[];
  if (permissionTypes.contains('calendar')) macros.add('PERMISSION_EVENTS=1');
  if (permissionTypes.contains('contacts')) macros.add('PERMISSION_CONTACTS=1');
  if (permissionTypes.contains('camera')) macros.add('PERMISSION_CAMERA=1');
  if (permissionTypes.contains('microphone')) macros.add('PERMISSION_MICROPHONE=1');
  if (permissionTypes.contains('speech')) macros.add('PERMISSION_SPEECH_RECOGNIZER=1');
  if (permissionTypes.contains('photos')) macros.add('PERMISSION_PHOTOS=1');
  if (permissionTypes.contains('bluetooth')) macros.add('PERMISSION_BLUETOOTH=1');
  if (permissionTypes.contains('sensors')) macros.add('PERMISSION_SENSORS=1');
  if (permissionTypes.contains('notifications')) macros.add('PERMISSION_NOTIFICATIONS=1');
  if (permissionTypes.contains('location')) {
    macros.add(locationBackground ? 'PERMISSION_LOCATION=1' : 'PERMISSION_LOCATION_WHENINUSE=1');
  }
  if (macros.isEmpty) {
    logger.info('ℹ️  No iOS permission macros required');
    return;
  }

  final macroRegex = RegExp(
    r"config\.build_settings\['GCC_PREPROCESSOR_DEFINITIONS'\]\s*\|\|=\s*\[(.*?)\]",
    dotAll: true,
  );

  final macroBlock = [
    "config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [",
    "        '\$(inherited)',",
    ...macros.map((m) => "        '$m',"),
    "      ]"
  ].join('\n');

  if (macroRegex.hasMatch(content)) {
    content = content.replaceAll(macroRegex, macroBlock);
  } else {
    final insertRegex = RegExp(r'(flutter_additional_ios_build_settings\(target\)[ \t]*\n)');
    content = content.replaceFirstMapped(
      insertRegex,
      (match) => '${match.group(0)}    target.build_configurations.each do |config|\n'
          '      # permission_handler (selected only)\n'
          '$macroBlock\n'
          '    end\n',
    );
  }

  await file.writeAsString(content);
  logger.success('   ✅ iOS: Podfile macros updated');
}

Future<void> _runFlutterPubGet(Logger logger) async {
  logger.info('');
  final progress = logger.progress('Running flutter pub get');

  try {
    final result = await Process.run('flutter', ['pub', 'get']);

    if (result.exitCode == 0) {
      progress.complete('✅ Dependencies installed successfully');
    } else {
      progress.fail('❌ Failed to run flutter pub get');
      logger.err('Error: ${result.stderr}');
      logger.warn('Please run "flutter pub get" manually');
    }
  } catch (e) {
    progress.fail('❌ Failed to run flutter pub get');
    logger.err('Error: $e');
    logger.warn('Please run "flutter pub get" manually');
  }
}

class _AndroidSdk {
  final int compileSdk;
  final int targetSdk;
  const _AndroidSdk(this.compileSdk, this.targetSdk);
}

Future<_AndroidSdk> _readAndroidSdkVersions(Logger logger) async {
  final gradleFile = File('android/app/build.gradle');
  final ktsFile = File('android/app/build.gradle.kts');
  String? content;
  if (await gradleFile.exists()) {
    content = await gradleFile.readAsString();
  } else if (await ktsFile.exists()) {
    content = await ktsFile.readAsString();
  }
  int compileSdk = 33;
  int targetSdk = 33;
  if (content != null) {
    final compileMatch = RegExp(r'compileSdk(?:Version)?\s+(\d{2})').firstMatch(content);
    final targetMatch = RegExp(r'targetSdk(?:Version)?\s+(\d{2})').firstMatch(content);
    if (compileMatch != null) compileSdk = int.tryParse(compileMatch.group(1)!) ?? compileSdk;
    if (targetMatch != null) targetSdk = int.tryParse(targetMatch.group(1)!) ?? targetSdk;
  }
  return _AndroidSdk(compileSdk, targetSdk);
}

Future<String?> _readIOSDeploymentTarget(Logger logger) async {
  final proj = File('ios/Runner.xcodeproj/project.pbxproj');
  if (!await proj.exists()) return null;
  try {
    final text = await proj.readAsString();
    final match = RegExp(r'IPHONEOS_DEPLOYMENT_TARGET\s*=\s*([0-9.]+);').firstMatch(text);
    return match?.group(1);
  } catch (_) {
    return null;
  }
}
