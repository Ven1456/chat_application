class CustomValidators{


  static String? fullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name.';
    }
    if (value.length <= 2) {
      return 'Please enter a valid full name.';
    }
    return null;
  }
  static String? empty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Your Feedback.';
    }
    return null;
  }



  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address.';
    }
    final regex = RegExp(r"^[a-zA-Z\d.a-zA-Z!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z\d]+\.[a-zA-Z]+");
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  static String? dateOfBirth(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String text) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != text.toString()) {
      return 'Confirm Passwords do not match';
    }
    return null;
  }




  static String? phone(String? value) {
    if (value == null || value.isEmpty || value.length != 10) {
      return 'Please enter a valid 10-digit phone number.';
    }
    return null;
  }
}