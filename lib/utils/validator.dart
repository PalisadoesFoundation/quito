import 'package:email_validator/email_validator.dart';

class Validator {
  static String validateURL(String value) {
    if (value.length == 0) {
      return 'Please enter and save url to continue'.toUpperCase();
    }
    return null;
  }

  static String validateFirstName(String value) {
    if (value.length == 0) {
      return 'Firstname must not be left blank.';
    }
    return null;
  }

  static String validateLastName(String value) {
    if (value.length == 0) {
      return 'Lastname must not be left blank.';
    }
    return null;
  }

  static String validateEmail(String email) {
    final bool isValid = EmailValidator.validate(email);
    if (!isValid) {
      return 'Not a Valid Email Address';
    }
    return null;
  }

  // static String validateEmail(String value) {
  //   bool emailDup = false;
  //   RegExp regExp = new RegExp(
  //       r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
  //       multiLine: false);
  //   if (!regExp.hasMatch(value)) {
  //     return 'E-mail Address must be a valid email address.';
  //   }
  //   if(emailDup == true){
  //     return 'E-mail Address already exists';
  //   }
  //   return null;
  // }

  static String validatePassword(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,20}$';
    RegExp regExp = new RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return "Invalid password";
    }
    return null;
  }

  static bool upperAlpha(String value) {
    String patternUpperAlpha = r'^(?=.*?[A-Z])';
    RegExp regExp = new RegExp(patternUpperAlpha);
    if (regExp.hasMatch(value)) return true;
    return false;
  }

  static bool lowerAlpha(String value) {
    String patternLowerAlpha = r'^(?=.*?[a-z])';
    RegExp regExp = new RegExp(patternLowerAlpha);
    if (regExp.hasMatch(value)) return true;
    return false;
  }

  static bool numeric(String value) {
    String patternNumeric = r'^(?=.*?[0-9])';
    RegExp regExp = new RegExp(patternNumeric);
    if (regExp.hasMatch(value)) return true;
    return false;
  }

  static bool specialChar(String value) {
    String patternSpecialChara = r'^(?=.*?[!@#\$&*~])';
    RegExp regExp = new RegExp(patternSpecialChara);
    if (regExp.hasMatch(value)) return true;
    return false;
  }
  

  static String validatePasswordConfirm(String value, String comparator) {
    if (value != comparator) {
      return 'Password does not match original';
    }
    return null;
  }

  static String validateTitle(String value) {
    if (value.length < 4) {
      return 'Title must be at least 4 characters.';
    }

    return null;
  }

  static String validateDateTime(DateTime value) {
    if (value == null) {
      return 'Date field must not be left blank.';
    }

    return null;
  }

  static String validateDescription(String value) {
    if (value.length < 5 || value.length > 50) {
      return 'Description field must range between\n 5 and 30 characters';
    }

    return null;
  }

  static String validateOrgName(String value) {
    if (value.length == 0) {
      return 'Organization Name must not be left blank.';
    }
    return null;
  }

  static String validateOrgDesc(String value) {
    if (value.length == 0) {
      return 'Organization Description must not be left blank.';
    }
    return null;
  }

  static String validateOrgAttendeesDesc(String value) {
    if (value.length == 0) {
      return 'Attendees Description must not be left blank.';
    }
    return null;
  }
}
