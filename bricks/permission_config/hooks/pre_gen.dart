import 'dart:io';
import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final logger = context.logger;

  logger.info('');
  logger.info('🔧 Flutter Permissions Configuration');
  logger.info('=====================================');
  logger.info('');

  final existingPermissions = _detectExistingPermissionTypes(logger);

  final permissionTypes = _promptForPermissionTypes(logger, exclude: existingPermissions);
  final permissionsWithMessages = _promptForMessagesPerPermission(logger, permissionTypes);

  bool locationBackground = false;

  if (permissionTypes.contains('location')) {
    logger.info('');
    logger.info('📍 Background Location');
    logger.info(
        '   Choose YES only if you truly need location updates while the app is not in use (geofencing, trip tracking).');
    locationBackground = logger.confirm('Request background location access?');
  }

  context.vars = {
    'permission_types': permissionTypes,
    'permissions': permissionsWithMessages,
    'location_background': locationBackground,
    'existing_permissions': existingPermissions,
  };

  const allPermissions = [
    'camera',
    'microphone',
    'location',
    'storage',
    'bluetooth',
    'sensors',
    'contacts',
    'calendar',
    'photos',
    'notifications',
    'speech',
  ];

  for (final p in allPermissions) {
    context.vars['has_$p'] = permissionTypes.contains(p);
  }

  logger.info('');
  final progress = logger.progress('Adding permission_handler dependency');

  final result = await Process.run('flutter', ['pub', 'add', 'permission_handler']);

  if (result.exitCode == 0) {
    progress.complete('✅ Added permission_handler dependency');
  } else {
    progress.fail('❌ Failed to add permission_handler');
    logger.err('Error: ${result.stderr}');
  }
}

String _normalize(String value) {
  switch (value.toLowerCase().trim()) {
    case '1':
    case 'camera':
      return 'camera';
    case '2':
    case 'microphone':
      return 'microphone';
    case '3':
    case 'location':
      return 'location';
    case '4':
    case 'storage':
      return 'storage';
    case '5':
    case 'bluetooth':
      return 'bluetooth';
    case '6':
    case 'sensors':
      return 'sensors';
    case '7':
    case 'contacts':
      return 'contacts';
    case '8':
    case 'calendar':
      return 'calendar';
    case '9':
    case 'photos':
      return 'photos';
    case '10':
    case 'notifications':
    case 'notification':
      return 'notifications';
    case '11':
    case 'speech':
      return 'speech';
    default:
      return '';
  }
}

List<String> _promptForPermissionTypes(Logger logger, {List<String> exclude = const []}) {
  final allPermissions = [
    'camera',
    'microphone',
    'location',
    'storage',
    'bluetooth',
    'sensors',
    'contacts',
    'calendar',
    'photos',
    'notifications',
    'speech',
  ];

  final permissionLabels = [
    '1. camera        - Camera access',
    '2. microphone    - Microphone/audio recording',
    '3. location      - GPS location access',
    '4. storage       - File system access',
    '5. bluetooth     - Bluetooth connectivity',
    '6. sensors       - Device sensors (motion, etc.)',
    '7. contacts      - Address book access',
    '8. calendar      - Calendar events access',
    '9. photos        - Photo library (iOS only)',
    '10. notifications - Push notifications (Android 13+)',
    '11. speech       - Speech recognition',
  ];

  if (exclude.isNotEmpty) {
    logger.info('');
    logger.info('🔍 Detected existing permissions: ${exclude.join(', ')}');
  }

  logger.info('');
  logger.info('🎯 Available permission types (comma-separated allowed):');
  for (var i = 0; i < allPermissions.length; i++) {
    if (!exclude.contains(allPermissions[i])) {
      logger.info('   ${permissionLabels[i]}');
    }
  }
  logger.info('');
  logger.info('Examples: camera,microphone  OR  1,2');

  while (true) {
    final raw = logger.prompt('Select permission type(s):');
    final parts = raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) {
      logger.err('❌ No selection provided. Please try again.');
      continue;
    }

    final normalized = <String>[];
    var invalidFound = false;

    for (final p in parts) {
      final n = _normalize(p);
      if (n.isEmpty) {
        invalidFound = true;
        logger.err('❌ Invalid entry: "$p"');
      } else if (exclude.contains(n)) {
        invalidFound = true;
        logger.err('❌ "$n" is already configured and cannot be selected again.');
      } else {
        normalized.add(n);
      }
    }

    if (invalidFound) {
      continue;
    }

    final deduped = <String>[];
    for (final p in normalized) {
      if (!deduped.contains(p)) deduped.add(p);
    }

    if (deduped.isEmpty) {
      logger.err('❌ No valid permissions resolved. Try again.');
      continue;
    }

    logger.info('✅ Selected: ${deduped.join(', ')}');
    return deduped;
  }
}

List<Map<String, String>> _promptForMessagesPerPermission(Logger logger, List<String> permissionTypes) {
  logger.info('');
  logger.info('💬 Enter a custom message for each permission (leave empty for default).');
  final result = <Map<String, String>>[];

  for (final perm in permissionTypes) {
    final msg = logger.prompt('Custom message for "$perm":').trim();
    result.add({
      'type': perm,
      'custom_message': msg,
    });
  }
  return result;
}

List<String> _detectExistingPermissionTypes(Logger logger) {
  final found = <String>{};

  // Android
  try {
    final manifest = File('android/app/src/main/AndroidManifest.xml');
    if (manifest.existsSync()) {
      final text = manifest.readAsStringSync();
      void addIf(bool cond, String p) {
        if (cond) found.add(p);
      }

      addIf(text.contains('android.permission.CAMERA'), 'camera');
      addIf(text.contains('android.permission.RECORD_AUDIO'), 'microphone');
      addIf(RegExp(r'ACCESS_FINE_LOCATION|ACCESS_COARSE_LOCATION').hasMatch(text), 'location');
      addIf(RegExp(r'ACCESS_BACKGROUND_LOCATION').hasMatch(text), 'location');
      addIf(
          RegExp(r'READ_MEDIA_IMAGES|READ_MEDIA_VIDEO|READ_MEDIA_AUDIO|READ_EXTERNAL_STORAGE|WRITE_EXTERNAL_STORAGE')
              .hasMatch(text),
          'storage');
      addIf(RegExp(r'BLUETOOTH(_SCAN|_CONNECT|_ADVERTISE|[^A-Z])').hasMatch(text), 'bluetooth');
      addIf(RegExp(r'BODY_SENSORS').hasMatch(text), 'sensors');
      addIf(text.contains('android.permission.READ_CONTACTS'), 'contacts');
      addIf(RegExp(r'READ_CALENDAR|WRITE_CALENDAR').hasMatch(text), 'calendar');
      addIf(text.contains('android.permission.POST_NOTIFICATIONS'), 'notifications');
    }
  } catch (e) {
    logger.warn('⚠️  Error reading AndroidManifest.xml: $e');
  }

  // iOS Info.plist
  try {
    final plist = File('ios/Runner/Info.plist');
    if (plist.existsSync()) {
      final text = plist.readAsStringSync();
      void addIf(bool cond, String p) {
        if (cond) found.add(p);
      }

      addIf(text.contains('NSCameraUsageDescription'), 'camera');
      addIf(text.contains('NSMicrophoneUsageDescription'), 'microphone');
      addIf(RegExp(r'NSLocationWhenInUseUsageDescription|NSLocationAlwaysAndWhenInUseUsageDescription').hasMatch(text),
          'location');
      addIf(RegExp(r'NSPhotoLibraryUsageDescription').hasMatch(text), 'photos');
      addIf(RegExp(r'NSBluetooth(?:Always|Peripheral)UsageDescription').hasMatch(text), 'bluetooth');
      addIf(text.contains('NSMotionUsageDescription'), 'sensors');
      addIf(text.contains('NSContactsUsageDescription'), 'contacts');
      addIf(text.contains('NSCalendarsUsageDescription'), 'calendar');
      addIf(text.contains('NSSpeechRecognitionUsageDescription'), 'speech');
    }
  } catch (e) {
    logger.warn('⚠️  Error reading Info.plist: $e');
  }

  // iOS Podfile macros
  try {
    final podfile = File('ios/Podfile');
    if (podfile.existsSync()) {
      final text = podfile.readAsStringSync();
      void addIfMacro(String macro, String p) {
        if (RegExp("'$macro=1'").hasMatch(text) || RegExp('"$macro=1"').hasMatch(text)) {
          found.add(p);
        }
      }

      addIfMacro('PERMISSION_CAMERA', 'camera');
      addIfMacro('PERMISSION_MICROPHONE', 'microphone');
      if (RegExp(r"PERMISSION_LOCATION(_WHENINUSE)?=1").hasMatch(text)) found.add('location');
      addIfMacro('PERMISSION_PHOTOS', 'photos');
      addIfMacro('PERMISSION_BLUETOOTH', 'bluetooth');
      addIfMacro('PERMISSION_SENSORS', 'sensors');
      addIfMacro('PERMISSION_CONTACTS', 'contacts');
      addIfMacro('PERMISSION_EVENTS', 'calendar');
      addIfMacro('PERMISSION_NOTIFICATIONS', 'notifications');
      addIfMacro('PERMISSION_SPEECH_RECOGNIZER', 'speech');
    }
  } catch (e) {
    logger.warn('⚠️  Error reading Podfile: $e');
  }

  final list = found.toList()..sort();
  return list;
}
