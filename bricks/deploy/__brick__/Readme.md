# Flutter Build and Deployment Script

This bash script automates the process of building Flutter applications for different flavors (development, production, staging) and platforms (Android, iOS) and distributing them to Firebase App Distribution.  It also handles FlutterFire configuration and provides notifications upon completion.

## Prerequisites

Before running the script, ensure you have the following installed:

* **Flutter:** Make sure Flutter is installed and configured on your system.
* **FlutterFire CLI:** Install the FlutterFire CLI: `flutter pub global activate flutterfire_cli`
* **Firebase CLI:** Install the Firebase CLI and log in: `npm install -g firebase-tools` and `firebase login`
* **Android Studio/Xcode:** Required for building Android and iOS apps, respectively.
* **`terminal-notifier` (macOS - Optional):** For macOS notifications, install `terminal-notifier` using Homebrew: `brew install terminal-notifier`
* **PowerShell (Windows):** Required for Windows notifications.  Generally built into Windows.

## Configuration

1.  **`.deploy-configs` file:** Create a file named `.deploy-configs` in the same directory as the script. This file will contain your project-specific configurations.  Example:

    ```bash
    development_package_name="com.example.app.dev"
    development_firebase_project_id="your-dev-firebase-project-id"
    development_android_app_id="your-dev-android-app-id"
    development_ios_app_id="your-dev-ios-app-id"

    production_package_name="com.example.app"
    production_firebase_project_id="your-prod-firebase-project-id"
    production_android_app_id="your-prod-android-app-id"
    production_ios_app_id="your-prod-ios-app-id"

    staging_package_name="com.example.app.staging"
    staging_firebase_project_id="your-staging-firebase-project-id"
    staging_android_app_id="your-staging-android-app-id"
    staging_ios_app_id="your-staging-ios-app-id"
    ```

    **Important:** Replace the placeholder values with your actual project details.  Ensure you have the correct Firebase project IDs and app IDs for each flavor.

2.  **GoogleService-Info.plist (iOS):** The script automatically deletes the existing `GoogleService-Info.plist` file before configuring FlutterFire.  Make sure you have a backup or a way to regenerate this file if needed.

## Usage

1.  **Save the script:** Save the provided script as a file named `deploy.sh` (or any other name you prefer).
2.  **Make it executable:** Give the script execute permissions: `chmod +x deploy.sh`
3.  **Run the script:** Execute the script: `./deploy.sh`

The script will prompt you for:

*   **Build flavor:** Choose between `development`, `production`, or `staging`.
*   **Platform:** Choose between `android`, `ios`, or `all`.

## Script Breakdown

*   **Colorized output:** Uses ANSI escape codes for colored output.
*   **Configuration sourcing:** Reads configurations from `.deploy-configs`.
*   **FlutterFire configuration:** Configures FlutterFire for the selected project.
*   **APK/IPA path finding:** Locates the generated APK and IPA files.
*   **OS detection:** Detects the operating system (Linux, macOS, Windows).
*   **Platform-specific commands:** Uses `flutterfire.bat` on Windows and `flutterfire` on macOS/Linux.
*   **Command availability check:** Checks if `flutterfire`, `flutter`, and `firebase` are installed.
*   **Flavor selection:** Prompts the user for the build flavor and sets corresponding variables.
*   **Platform selection:** Prompts the user for the platform and executes the appropriate build command.
*   **Git commit message retrieval:** Gets the last 10 relevant git commit messages (containing "feat", "feature", "fix", or "chore") for release notes.
*   **Firebase App Distribution upload:** Uploads the APK/IPA to Firebase App Distribution with release notes.
*   **Notifications:** Sends notifications on build completion (Windows and macOS).

## Proposed Features/Enhancements

*   **Automated versioning:** Implement automatic versioning based on git tags or commit numbers.
*   **Customizable notification messages:** Allow users to customize the notification messages.
*   **CI/CD integration:** Integrate the script into a CI/CD pipeline for automated deployments.
*   **Error handling:** Improve error handling and provide more informative error messages.
*   **Code signing (iOS):** Automate code signing for iOS builds.  Currently using `--export-method=development`, which is not suitable for production.
*   **More Robust File Finding:** The `find` commands for APK and IPA could be made more robust to handle potential directory structure variations.  Consider adding error handling if the files are not found.
*   **Prompt for Release Notes:** Instead of relying solely on git messages, allow the user to provide custom release notes during the deployment process.
*   **Configuration Validation:** Validate the configuration values in `.deploy-configs` to catch errors early.
*   **Parallel Builds (all):** When building for "all" platforms, consider running the Android and iOS builds in parallel to speed up the process.
