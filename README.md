# Thinkbit Mason Bricks

A collection of [Mason](https://github.com/felangel/mason) bricks designed to accelerate Flutter development at Thinkbit.

## Available Bricks

| Brick | Description |
| --- | --- |
| [api_service](bricks/api_service) | Robust Dio-based API service template. |
| [auto_route](bricks/auto_route) | Setup for `auto_route` package. |
| [bloc_feature](bricks/bloc_feature) | Scaffolds a complete BLoC feature. |
| [deploy](bricks/deploy) | Deployment scripts and templates. |
| [firebase_messaging_service](bricks/firebase_messaging_service) | FCM setup. |
| [flavor_config](bricks/flavor_config) | Environment-based configuration. |
| [gitlab_pipelines](bricks/gitlab_pipelines) | GitLab CI/CD configurations. |
| [permission_config](bricks/permission_config) | Standardized permission handling. |
| [pusher_service](bricks/pusher_service) | Real-time messaging with Pusher. |
| [remote_config](bricks/remote_config) | Firebase Remote Config integration. |
| [validator](bricks/validator) | Validation utilities. |

## Quick Start

### 1. Initialize Bricks
This repository includes a root `mason.yaml` file. You can initialize all bricks at once from the root directory:

```bash
mason get
```

### 2. Use a Brick
Add a brick to your project's `mason.yaml`:

```yaml
bricks:
  api_service:
    git:
      url: https://github.com/thinkbit/thinkbit_mason_bricks
      path: bricks/api_service
```

## Versioning & Release Management

We use a Git-based versioning strategy to ensure that projects can pin to specific versions of a brick.

*   **Standardized Environment**: All bricks require `mason: ^0.1.1`.
*   **Release Guide**: See [RELEASE_MANAGEMENT.md](RELEASE_MANAGEMENT.md) for details on tagging and pinning.
*   **Version Updates**: Use the provided script at `scripts/manage_versions.dart` to update the Mason version constraint across all bricks simultaneously.

```bash
dart scripts/manage_versions.dart "^0.1.1"
```

---
© 2026 Thinkbit
