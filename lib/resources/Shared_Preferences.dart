import 'package:shared_preferences/shared_preferences.dart';

class SharedPref{
  static String userLogin="LoginKey";
  static String userName="NameKey";
  static String userEmail="EmailKey";

    static Future<bool?> saveUserLoginStatus(bool isUserLogged) async{
       SharedPreferences sharedPreferences =await SharedPreferences.getInstance();
      sharedPreferences.setBool(userLogin,isUserLogged );
    }

  static Future<bool?> saveUserName(String isUsername) async{
    SharedPreferences sharedPreferences =await SharedPreferences.getInstance();
    sharedPreferences.setString(userName,isUsername);
  }
  static Future<bool?> saveUserEmail(String isUserEmail) async{
    SharedPreferences sharedPreferences =await SharedPreferences.getInstance();
    sharedPreferences.setString(userEmail,isUserEmail);
  }

  static Future <bool?> isUserLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(userLogin);
  }
  static Future<String?> getName()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userName);
  }
  static Future<String?> getEmail()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userEmail);
  }
}