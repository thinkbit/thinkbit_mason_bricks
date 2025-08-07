# Gitlab Pipelines

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

A mason brick to generate the Gitlab Pipelines yml files for CI/CD

## Installation 🚀

1. **Initialize Mason** in your project's root directory if you haven't already: `mason init`
2. **Add the Brick** to your `mason.yaml` file:
    ```yaml
    bricks:
      gitlab_pipelines:
        git:
          url: https://github.com/thinkbit/thinkbit_mason_bricks.git
          path: bricks/gitlab_pipelines
    ``` 
3. **Fetch the Brick:** `mason get`
4. **Generate the pipeline files:** `mason make gitlab_pipelines`

## Prerequisites :warning:

1. Setup Gitlab Runner
2. Add necessary variables in Gitlab CI/CD Settings > Variables with an environment suffix `app_id_development`
3. Upload key.properties and upload-keystore.jks files in Gitlab CI/CD Settings > Secure Files
4. Create a group for the Firebase testers
5. Package name for both iOS and Android should be the same

## Variables Required: :exclamation: 

1. Gitlab Runner Tags to be used
2. Branch names for the dev, beta, and prod environments
3. Firebase Testers Group name for Firebase Distribution
4. Firebase Project ID and the iOS/Android Package name for configuring FlutterFire (without $ and environment suffix)
5. iOS/Android Firebase App ID for Firebase Distribution (without $ and environment suffix)

[1]: https://github.com/felangel/mason
