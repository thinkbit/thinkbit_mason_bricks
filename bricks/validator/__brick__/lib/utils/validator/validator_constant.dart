part of 'validator.dart';

///  Regex
const emailRegex =
    r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
const phoneRegex = r'^[\d,;*+#\- .()/N]+$';
const passwordRegex = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,10}$';

///  Integers
const defaultTwo = 2;
const defaultOne = 1;
const defaultZero = 0;

/// Requirement Messages
const emailRequirementMessage = 'This must be an email address.';
const integerRequirementMessage = 'This field must be an integer.';
const numericRequirementMessage = 'This field must be a number.';
const passwordRequirementMessage =
    'Must contain at least one uppercase & lowercase letter, number\nand special characters.';
const requiredMessage = 'This field is required.';
const regExInvalid = 'This format is valid.';
const phoneRequirementMesage = 'This must be a valid phone number.';
