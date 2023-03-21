import 'package:shared_preferences/shared_preferences.dart';

class SharedPref{
  static String userLogin="LoginKey";
  static String userName="NameKey";
  static String userEmail="EmailKey";

  static Future <bool?> isUserLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(userLogin);
  }
}