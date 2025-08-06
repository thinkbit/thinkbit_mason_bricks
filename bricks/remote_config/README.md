# Remote Config Brick 🧱

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

A Mason brick to generate the necessary boilerplate for using Firebase Remote Configuration in a Flutter project.

---

## Prerequisites

Before using this brick, make sure you have:

1.  **Installed the Mason CLI:**
    `dart pub global activate mason_cli`
2.  **Configured Firebase** in your Flutter project. See the official [FlutterFire documentation](https://firebase.flutter.dev/docs/overview) for details.

---

## Installation 🚀

1.  **Initialize Mason** in your project's root directory if you haven't already:
    `mason init`
2.  **Add the Brick** to your `mason.yaml` file:
    ```yaml
    bricks:
      remote_config:
        git:
          url: https://github.com/thinkbit/thinkbit_mason_bricks.git
          path: bricks/remote_config
    ```
3.  **Fetch the Brick:**
    `mason get`

---

## Usage ✨

1. **To generate the Remote Config setup** run the following command from your project's root directory:
    `mason make remote_config`