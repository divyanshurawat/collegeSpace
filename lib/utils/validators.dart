import 'dart:async';

class Validators {
  static final String myformat ="@";
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  static final RegExp _phoneRegex = RegExp(
    r'^(?:[+0]9)?[0-9]{11}$',
  );

  static final RegExp _passwordRegExp = RegExp(
    r'^(.*){6,}$',
  );


  static isValidEmail(String email) {

      return _emailRegExp.hasMatch(email);


  }
  static isValidMail (String email){
    return myformat.contains(email);
  }


  static isValidPhone(String phone) {
    return _phoneRegex.hasMatch(phone);
  }

  static isValidPassword(String password) {
    return _passwordRegExp.hasMatch(password);
  }
}
