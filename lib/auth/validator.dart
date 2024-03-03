class Validator {
  static String? validateName({required String? name}) {
    if (name == null) {
      return null;
    }

    if (name.isEmpty) {
      return 'Name can\'t be empty';
    }
    return null;
  }

  static String? validateEmail({required String? email}) {
    if (email == null) {
      return null;
    }

    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    if (email.isEmpty) {
      return 'Email can\'t be empty';
    } else if (!emailRegExp.hasMatch(email)) {
      return 'Enter a correct email';
    }

    return null;
  }

  static String? validatePassword({required String? password}) {
    if (password == null) {
      return null;
    }

    if (password.isEmpty) {
      return 'Password can\'t be empty';
    } else if (password.length < 6) {
      return 'Enter a password with length at least 6';
    }

    return null;
  }

  static String? validateMobile({required String? mobile}) {
    if (mobile == null) {
      return null;
    }

    // Validate if the mobile number is not empty
    if (mobile.isEmpty) {
      return 'Mobile number is required';
    }

    // Validate if the mobile number contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      return 'Enter a valid mobile number';
    }

    // Validate if the mobile number has a valid length
    if (mobile.length < 10) {
      return 'Mobile number should be between 10 and 15 digits';
    }

    // Return null if the mobile number is valid
    return null;
  }
}
