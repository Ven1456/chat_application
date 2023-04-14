import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static String userLogin = "LoginKey";
  static String userName = "NameKey";
  static String userEmail = "EmailKey";
  static String profilePic = "profilePic";
  static String groupPic = "GroupPic";
  // SAVE THE USER LOGIN STATUS SHARED PREFERENCE
  static Future<bool?> saveUserLoginStatus(bool isUserLogged) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(userLogin, isUserLogged);
    return null;
  }

  // SAVE THE USER NAME STATUS SHARED PREFERENCE
  static Future<bool?> saveUserName(String isUsername) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(userName, isUsername);
    return null;
  } // SAVE THE USER EMAIL STATUS SHARED PREFERENCE

  static Future<bool?> saveUserEmail(String isUserEmail) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(userEmail, isUserEmail);
  }

// SAVE THE USER PROFILE PIC STATUS SHARED PREFERENCE
  static Future<bool?> saveProfilePic(String profile) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(profilePic, profile);
  }
// SAVE THE USER GROUP PIC STATUS SHARED PREFERENCE
  static Future<bool?> saveGroupPic(String profile) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(groupPic, profile);
  }
// SAVE THE IS USER LOGIN NAME STATUS SHARED PREFERENCE
  static Future<bool?> isUserLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(userLogin);
  }

  // GET THE NAME STATUS SHARED PREFERENCE
  static Future<String?> getName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userName);
  }

  // GET THE EMAIL STATUS SHARED PREFERENCE
  static Future<String?> getEmail() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userEmail);
  }
  // GET THE GROUP PIC STATUS SHARED PREFERENCE
  static Future<String?> getGroupPic() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(groupPic);
  }
  // GET THE PROFILE PIC STATUS SHARED PREFERENCE
  static Future<String?> getProfilePic() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(profilePic);
  }
}
