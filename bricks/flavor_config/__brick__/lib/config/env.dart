import 'package:flutter/material.dart';

// since this is a configuration file.
// ignore: constant_identifier_names
enum Flavor { DEV, BETA, PRODUCTION, TESTING }

class FlavorValues {
  FlavorValues({required this.baseUrl, required this.apiUrl});
  final String baseUrl;
  final String apiUrl;
  //Add other flavor specific values, e.g database name
}

class FlavorConfig {
  final Flavor flavor;
  final String name;
  final Color color;
  final Duration apiTimeoutDuration;
  final FlavorValues values;
  static FlavorConfig? _instance;

  factory FlavorConfig(
      {required Flavor flavor,
      required FlavorValues values,
      Color color = Colors.blue,
      Duration apiTimeoutDuration = const Duration(seconds: 30)}) {
    _instance ??= FlavorConfig._internal(
        flavor, flavor.toString(), color, values, apiTimeoutDuration);
    return _instance!;
  }

  FlavorConfig._internal(
      this.flavor, this.name, this.color, this.values, this.apiTimeoutDuration);
  static FlavorConfig? get instance {
    return _instance;
  }

  static bool isProduction() => _instance!.flavor == Flavor.PRODUCTION;
  static bool isDevelopment() => _instance!.flavor == Flavor.DEV;
  static bool isBeta() => _instance!.flavor == Flavor.BETA;
  static bool isTesting() => _instance!.flavor == Flavor.TESTING;
}
