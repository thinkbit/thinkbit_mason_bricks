# Flavor Config Brick 🧱

A robust environment configuration manager for Flutter applications, helping you manage multiple flavors (e.g., dev, staging, production) with a centralized Singleton.

## Features ✨

- **Customizable Flavors**: Define your own flavor names during generation.
- **Singleton Pattern**: Access configuration globally via `FlavorConfig.instance`.
- **UI Integration**: Includes flavor-specific colors and names for debug overlays.

## Installation 🚀

```yaml
dev_dependencies:
  mason_cli: any
```

## Setup Guide (2025-2026 Standards) 🛠️

Flavoring a Flutter app requires both Dart code and native configuration.

### 1. Generate the Brick
```bash
mason make flavor_config
```
When prompted, provide your flavor names (e.g., `dev, staging, prod`).

### 2. Initialize in main.dart
Create entry points for each flavor: `main_dev.dart`, `main_prod.dart`, etc.

```dart
// main_dev.dart
void main() {
  FlavorConfig(
    flavor: Flavor.DEV,
    color: 0xFFF44336, // Red
    values: FlavorValues(
      baseUrl: "https://dev.api.example.com",
      apiUrl: "/api/v1",
    ),
  );
  runApp(MyApp());
}
```

### 3. Native Configuration (The Hard Part)

#### Android 🤖
Update your `android/app/build.gradle`:

```gradle
android {
    ...
    flavorDimensions "default"
    productFlavors {
        dev {
            dimension "default"
            applicationIdSuffix ".dev"
            resValue "string", "app_name", "My App - Dev"
        }
        production {
            dimension "default"
            resValue "string", "app_name", "My App"
        }
    }
}
```

#### iOS 🍎
1. Open XCode.
2. In **Product > Scheme > Manage Schemes**, create schemes for each flavor.
3. In **Project > Info > Configurations**, duplicate `Debug` and `Release` for each flavor (e.g., `Debug-dev`, `Release-dev`).

### 4. Running the App
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

## Best Practices 💡
- **Secret Management**: For sensitive keys (API Keys, Client Secrets), avoid putting them in `FlavorValues` directly. Use a package like [Envied](https://pub.dev/packages/envied) to generate encrypted environment classes that you can then pass to `FlavorConfig`.
- **Global Access**: Access your base URL anywhere in the app:
  ```dart
  final url = FlavorConfig.instance!.values.baseUrl;
  ```
