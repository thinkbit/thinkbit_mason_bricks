/// Utility validator class
class Validator {
  static final Map<String, Function> _rules = {
    'between': (String text, String values) {
      if (text.isEmpty) {
        return null;
      }

      final minMax = values.split(',');
      final min = double.parse(minMax[0]);
      final max = double.parse(minMax[1]);

      if (_rules['min']!(text, min.toString()) is String ||
          _rules['max']!(text, max.toString()) is String) {
        return 'This must be between $min and $max.';
      }

      return true;
    },
    'email': (String text) {
      if (text.isEmpty) {
        return null;
      }

      // ref: http://emailregex.com
      final error = _rules['regex']!(
        text,
        r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
      );
      if (error is String) {
        return 'This must be an email address.';
      }

      return true;
    },
    'integer': (String text) {
      if (text.isEmpty) {
        return null;
      }

      if (null == int.tryParse(text)) {
        return 'This field must be an integer.';
      }

      return true;
    },
    'min': (String text, String value) {
      if (text.isEmpty) {
        return null;
      }

      if (text.length < double.parse(value)) {
        return 'This must be at least $value characters.';
      }

      return true;
    },
    'max': (String text, String value) {
      if (text.isEmpty) {
        return null;
      }

      if (double.parse(value) < text.length) {
        // return 'This may not be greater than $value characters.';
        return 'Max of $value characters only';
      }

      return true;
    },
    // 'middleInitialMax': (String text, String value) {
    //   if (text.isEmpty) {
    //     return null;
    //   }
    //
    //   if (double.parse(value) < text.length) {
    //     return 'This may not be greater than $value characters.';
    //   }
    //
    //   return true;
    // },
    'numeric': (String text) {
      if (text.isEmpty) {
        return null;
      }

      if (null == double.tryParse(text)) {
        return 'This field must be a number.';
      }

      return true;
    },
    'phone': (String text) {
      if (text.isEmpty) {
        return null;
      }

      final error = _rules['regex']!(
        text,
        r'^[\d,;*+#\- .()/N]+$',
      );
      if (error is String) {
        return 'This must be a valid phone number.';
      }

      return true;
    },
    'regex': (String text, String expression) {
      if (text.isEmpty) {
        return null;
      }

      if (!text.contains(RegExp(expression))) {
        return 'This format is valid.';
      }

      return true;
    },
    'required': (String text) {
      if (text.isEmpty) {
        return 'This field is required.';
      }

      return true;
    },
    // 'password': (String text) {
    //   if (text.isEmpty) {
    //     return null;
    //   }
    //   String error = _rules['regex'](
    //     text,
    //     r'^(?:(?=.*[a-z])(?:(?=.*[A-Z])(?=.*[\d\W])|(?=.*\W)(?=.*\d))|(?=.*\W)(?=.*[A-Z])(?=.*\d)).{8,}$',
    //   );
    //   if (error is String) {
    //     return 'Must contain upper & lowercase letters\nand a number';
    //   }
    //
    //   return true;
    // },
    'password': (String text) {
      if (text.isEmpty) {
        return null;
      }
      final error = _rules['regex']!(
        text,
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,10}$',
      );
      if (error is String) {
        return 'Must contain at least one uppercase & lowercase letter, number\nand special characters.';
      }

      return true;
    },
  };

  static String? validate({String? text, List<String>? rules}) {
    for (final rule in rules!) {
      var error;
      final ruleComponents = rule.split(':');

      if (ruleComponents.length == 1) {
        error = Validator._rules[ruleComponents[0]]!(text);
      } else if (ruleComponents.length == 2) {
        error = Validator._rules[ruleComponents[0]]!(text, ruleComponents[1]);
      } else {
        assert(false, 'Invalid rule.');
      }

      if (error is String) {
        return error;
      }
    }

    return null;
  }
}
