# Release Management Guide: Mason Bricks

To allow projects to safely pin to specific versions of the bricks in this repository, we use **Git Tags** combined with Mason's `ref` field.

## Tagging Convention

Since this is a monorepo containing multiple bricks that evolve independently, tags follow this convention:

**`<brick_name>-v<version>`**

Examples:
- `validator-v0.1.2`
- `bloc_feature-v0.1.1`
- `api_service-v0.1.0`

## How to Release a New Version

1.  **Update `brick.yaml`**: Increment the `version` field in the specific brick's `brick.yaml` (e.g., `bricks/validator/brick.yaml`).
2.  **Commit changes**: `git add .` and `git commit -m "feat(validator): bump version to 0.1.3"`
3.  **Create Tag**: 
    ```bash
    git tag validator-v0.1.3
    ```
4.  **Push Tag**:
    ```bash
    git push origin validator-v0.1.3
    ```

## Pinning Versions in Projects

Older projects can pin to a specific version by referencing the tag in their `mason.yaml`:

```yaml
bricks:
  validator:
    git:
      url: https://github.com/thinkbit/thinkbit_mason_bricks
      path: bricks/validator
      ref: validator-v0.1.2 # <--- Pinning set here
```

## Global Release Tags
For major stable releases of the entire collection, we may also use repository-wide tags:
- `v1.0.0`
Projects can then pull any brick from that stable set using `ref: v1.0.0`.
