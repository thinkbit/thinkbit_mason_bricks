// since this is a configuration file.
// ignore: constant_identifier_names
enum Flavor { 
  {{#flavors}}
  {{#upper}}{{this}}{{/upper}},
  {{/flavors}}
}

class FlavorValues {
  FlavorValues({required this.baseUrl, required this.apiUrl});
  final String baseUrl;
  final String apiUrl;
  //Add other flavor specific values, e.g database name
}

class FlavorConfig {
  final Flavor flavor;
  final String name;
  final int color;
  final Duration apiTimeoutDuration;
  final FlavorValues values;
  static FlavorConfig? _instance;

  factory FlavorConfig(
      {required Flavor flavor,
      required FlavorValues values,
      int color = 0xFF2196F3, // Default blue
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

  {{#flavors}}
  static bool is{{#pascal}}{{this}}{{/pascal}}() => _instance!.flavor == Flavor.{{#upper}}{{this}}{{/upper}};
  {{/flavors}}
}
