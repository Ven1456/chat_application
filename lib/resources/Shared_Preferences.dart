import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static String userLogin = "LoginKey";
  static String userName = "NameKey";
  static String userEmail = "EmailKey";
  static String profilePic = "profilePic";
  static String groupPic = "GroupPic";
  static String groupId = "GroupId";
  static String phone = "phone";
  static String dob = "dob";
  static String gender = "gender";
  static String saveAllGroupId = "SaveAllGroupId";

  // SAVE THE USER LOGIN STATUS SHARED PREFERENCE
  static Future<bool?> saveUserLoginStatus(bool isUserLogged) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(userLogin, isUserLogged);
    return null;
  }
  static Future<void> saveUserGender(String isGender) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
   await sharedPreferences.setString(gender, isGender);
  }

  // SAVE THE USER NAME STATUS SHARED PREFERENCE
  static Future<void> saveUserName(String isUsername) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
   await sharedPreferences.setString(userName, isUsername);
  }
  // SAVE THE USER PHONE STATUS SHARED PREFERENCE
  static Future<void> saveUserPhone(String isUserPhone) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(phone, isUserPhone);
  }
  // SAVE THE USER DOB STATUS SHARED PREFERENCE
  static Future<void> saveUserDob(String isUserDob) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
   await sharedPreferences.setString(dob, isUserDob);
  }
  // SAVE THE USER EMAIL STATUS SHARED PREFERENCE
  static Future<void> saveUserEmail(String isUserEmail) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
     await sharedPreferences.setString(userEmail, isUserEmail);
  }

// SAVE THE USER PROFILE PIC STATUS SHARED PREFERENCE
  static Future<bool?> saveProfilePic(String profile) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(profilePic, profile);
  }
  // SAVE GROUP ID
  static Future<bool?> saveGroupId(String groupIdString) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(groupId, groupIdString);
  }
  // 24/04/23
  // SAVE ALL GROUP ID
  static Future<bool?> saveAllGroupIds(String groupIdString) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(saveAllGroupId, groupIdString);
  }

// SAVE THE IS USER LOGIN NAME STATUS SHARED PREFERENCE
  static Future<bool?> isUserLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(userLogin);
  }

  // GET THE NAME STATUS SHARED PREFERENCE
  static Future<String> getName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userName) ?? '';
  }
  static Future<String> getGender() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(gender) ?? '';
  }
  // GET THE EMAIL STATUS SHARED PREFERENCE
  static Future<String> getEmail() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userEmail) ?? '';
  }
  // GET THE PHONE STATUS SHARED PREFERENCE
  static Future<String> getPhone() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(phone) ?? '';
  }
  // GET THE DOB STATUS SHARED PREFERENCE
  static Future<String> getDob() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(dob) ?? '';
  }
  // GET THE GROUP PIC STATUS SHARED PREFERENCE
  static Future<String?> getGroupPic() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(groupPic);
  }
  static Future<String?> getGroupId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(groupId);
  }
  // 24/04/23
  static Future<String?> getAllGroupId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(saveAllGroupId);
  }
}
