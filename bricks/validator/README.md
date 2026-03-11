# Validator Brick

A utility brick that generates a Laravel-style string-based validation system for Flutter applications.

## Usage

The `Validator` class allows you to run multiple validation rules against a string input and returns either the first error message found or `null` if all rules pass.

### 1. Direct UI Usage (TextFormField)

You can use the validator directly in a `TextFormField`'s `validator` property:

```dart
TextFormField(
  decoration: InputDecoration(labelText: 'Email Address'),
  validator: (value) => Validator.validate(
    text: value,
    rules: ['required', 'email'],
  ),
),
```

### 2. Usage in BLoC / Logic Layer

If you're using a BLoC pattern (like our `bloc_feature` brick), you can use it to validate data before processing an event:

```dart
on<LoginSubmitted>((event, emit) {
  final emailError = Validator.validate(
    text: event.email,
    rules: ['required', 'email'],
  );
  
  if (emailError != null) {
      emit(state.copyWith(error: emailError));
      return;
  }
  
  // Proceed with login logic...
});
```

## Available Rules

| Rule | Example | Description |
| --- | --- | --- |
| `required` | `rules: ['required']` | Ensures the field is not empty. |
| `email` | `rules: ['email']` | Validates that the input is a valid email format. |
| `min:n` | `rules: ['min:8']` | Minimum character length. |
| `max:n` | `rules: ['max:10']` | Maximum character length. |
| `between:min,max`| `rules: ['between:1,10']` | Checks value range (numeric). |
| `numeric` | `rules: ['numeric']` | Ensures the input is any valid number. |
| `integer` | `rules: ['integer']` | Ensures the input is an integer. |
| `phone` | `rules: ['phone']` | Validates common phone number formats. |
| `password` | `rules: ['password']` | Requirement: uppercase, lowercase, number, and special character. |
| `regex:pattern` | `rules: ['regex:^[A-Z]+$']` | Validates against a custom Regular Expression. |
