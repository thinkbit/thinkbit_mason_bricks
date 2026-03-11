# BLoC Feature Brick 🧱

A professional-grade BLoC feature generator for Flutter, implementing modern state management patterns and clean architecture principles.

## Features ✨

- **Automatic Provider Injection**: The generated `Page` widget automatically wraps the `View` in a `BlocProvider`.
- **Status Pattern**: Includes an optional `Status` enum (initial, loading, success, failure) to easily manage UI transitions.
- **State Immutability**: Generates a `copyWith` method for robust state updates.
- **Clean Separation**: Separates the `Page` (dependency injection) from the `View` (UI layout).

## Installation 🚀

```yaml
dev_dependencies:
  mason_cli: any
```

## Usage 🛠️

```bash
mason make bloc_feature --feature_name user_profile
```

### Folder Structure
```text
lib/
└── user_profile/
    ├── bloc/
    │   ├── user_profile_bloc.dart
    │   ├── user_profile_event.dart
    │   └── user_profile_state.dart
    ├── view/
    │   ├── user_profile_page.dart
    │   └── view.dart
    └── user_profile.dart
```

### Modern State Transitions
Instead of manually creating states for every situation, use the built-in status:

```dart
void _onLoadData(LoadData event, Emitter<State> emit) {
  emit(state.copyWith(status: Status.loading));
  try {
    final data = await repo.getData();
    emit(state.copyWith(status: Status.success, data: data));
  } catch (_) {
    emit(state.copyWith(status: Status.failure));
  }
}
```

## Setup & Dependencies 📦

This brick assumes you have the following packages in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_bloc: ^8.1.0
  bloc: ^8.1.0
  equatable: ^2.0.5
```
