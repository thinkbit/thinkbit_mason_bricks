part 'validator_constant.dart';

/// A class for validating text input based on set of predefined rules
///
class Validator {
  /// A map of validation [_rules] for validating [text] inputs.
  ///
  static final Map<String, Function> _rules = {
    /// Validates that the text falls within a specified range.
    ///
    'between': (String text, String values) {
      if (text.isEmpty) return null;

      final minMax = values.split(',');
      final min = double.parse(minMax[defaultZero]);
      final max = double.parse(minMax[defaultOne]);

      if (_rules['min']!(text, min.toString()) is String || _rules['max']!(text, max.toString()) is String) {
        return 'This must be between $min and $max.';
      }

      return true;
    },

    /// Validates that the text is a valid email address.
    ///
    'email': (String text) {
      if (text.isEmpty) return null;

      // ref: http://emailregex.com
      final error = _rules['regex']!(text, emailRegex);

      if (error is String) return emailRequirementMessage;

      return true;
    },

    /// Validates that the text is a valid integer.
    ///
    'integer': (String text) {
      if (text.isEmpty) return null;

      if (null == int.tryParse(text)) return integerRequirementMessage;

      return true;
    },

    /// Validates that the text length meets a minimum requirement.
    ///
    'min': (String text, String value) {
      if (text.isEmpty) return null;

      if (text.length < double.parse(value)) return 'This must be at least $value characters.';

      return true;
    },

    /// Validates that the text length does not exceed a specified maximum value.
    ///
    'max': (String text, String value) {
      if (text.isEmpty) return null;

      if (double.parse(value) < text.length) return 'Max of $value characters only';

      return true;
    },

    /// Validates text as per numeric requirements
    ///
    'numeric': (String text) {
      if (text.isEmpty) return null;

      if (null == double.tryParse(text)) return numericRequirementMessage;

      return true;
    },

    /// Validates text as per phone requirements
    ///
    'phone': (String text) {
      if (text.isEmpty) return null;
      final error = _rules['regex']!(text, phoneRegex);
      if (error is String) return phoneRequirementMesage;

      return true;
    },

    /// Validates that the text matches a specified regular expression pattern.
    ///
    'regex': (String text, String expression) {
      if (text.isEmpty) return null;
      if (!text.contains(RegExp(expression))) return regExInvalid;

      return true;
    },

    /// Validates that the text is not empty.
    ///
    'required': (String text) {
      if (text.isEmpty) return requiredMessage;

      return true;
    },

    /// Validates text as per password requirements
    ///
    'password': (String text) {
      if (text.isEmpty) return null;
      final error = _rules['regex']!(text, passwordRegex);
      if (error is String) return passwordRequirementMessage;

      return true;
    },
  };

  /// Validates a [text] input based on a list of [rules]
  ///
  static String? validate({String? text, List<String>? rules}) {
    for (final rule in rules!) {
      var error;
      final ruleComponents = rule.split(':');

      if (ruleComponents.length == defaultOne) {
        error = Validator._rules[ruleComponents[defaultZero]]!(text);
      } else if (ruleComponents.length == defaultTwo) {
        error = Validator._rules[ruleComponents[defaultZero]]!(text, ruleComponents[defaultOne]);
      } else {
        assert(false, 'Invalid rule.');
      }

      if (error is String) return error;
    }

    return null;
  }
}
