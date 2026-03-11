# permission_config

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

This brick automatically updates your **AndroidManifest.xml**, **Info.plist**, and **Podfile** to add the permissions you selected.

## Getting Started 🚀

1. Make sure Mason CLI is activated
   ```
   dart pub global activate mason_cli
   ```
2. Initialize mason using this command inside your project root directory:
   ```
   mason init
   ```
3. Add this brick to your project by editing the `mason.yaml` file and adding these lines under the `bricks`:

   ```
   permission_config:
       git:
       url: https://github.com/thinkbit/thinkbit_mason_bricks.git
       path: bricks/permission_config
   ```

   or just run

   ```
   mason add permission_config --git-url https://github.com/thinkbit/thinkbit_mason_bricks.git --git-path bricks/permission_config
   ```

4. Get the brick from the repository using this command:
   ```
   mason get
   ```
5. Generate the code using this command:
   ```
   mason make permission_config
   ```

## PermissionHandler Utility Class

A simple class to help you request, check, and handle app permissions using [`permission_handler`][2].

### Usage

#### Request a Permission

```dart
final granted = await PermissionHandler.request(Permission.camera);
```

#### Check Permission Status

```dart
final isGranted = await PermissionHandler.isPermissionGranted(Permission.location);
```

#### Check if Permission is Permanently Denied

```dart
final isDenied = await PermissionHandler.isPermanentlyDenied(Permission.microphone);
```

#### Open App Settings

```dart
await PermissionHandler.openSettings();
```

#### Request and Handle Permission with UI

```dart
final granted = await PermissionHandler.requestAndHandle(context, Permission.contacts);
```

If the permission is permanently denied, a dialog will prompt the user to open app settings.

[1]: https://github.com/felangel/mason
[2]: https://pub.dev/packages/permission_handler
