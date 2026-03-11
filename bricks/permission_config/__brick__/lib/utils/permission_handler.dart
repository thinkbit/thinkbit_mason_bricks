import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Utility class for handling app permissions
class PermissionHandler {
  /// Generic request helper (use when you have a dynamic Permission)
  static Future<bool> request(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }

  /// Check if a permission is granted
  static Future<bool> isPermissionGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  /// Determine if user permanently denied a permission (needs settings)
  static Future<bool> isPermanentlyDenied(Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }

  /// Open app settings if permission is permanently denied
  static Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Returns true if granted.
  static Future<bool> requestAndHandle(BuildContext context, Permission permission) async {
    // Try request
    if (await request(permission)) return true;

    // If permanently denied, prompt user
    if (await isPermanentlyDenied(permission)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        show(context);
      });
    }
    return false;
  }

  static void show(BuildContext context) {
    showAdaptiveDialog<void>(
      context: context,
      builder:
          (_) => AlertDialog.adaptive(
            title: const Text('Permission Required'),
            content: const Text(
              'This app requires certain permissions to function properly. Please grant the necessary permissions in the settings.',
            ),
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  openSettings();
                  Navigator.of(context).pop();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }
}
