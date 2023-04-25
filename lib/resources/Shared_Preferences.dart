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
  static String saveAllGroupId = "SaveAllGroupId";
  static String messageUrl= "messageUrl";

  // SAVE THE USER LOGIN STATUS SHARED PREFERENCE
  static Future<bool?> saveUserLoginStatus(bool isUserLogged) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(userLogin, isUserLogged);
    return null;
  }
  // 21/04/23
  // SAVE THE MESSAGE URL STATUS SHARED PREFERENCE
  static Future<bool?> saveMessageUrl(String isMessageUrl) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(messageUrl, isMessageUrl);
    return null;
  }

  // SAVE THE USER NAME STATUS SHARED PREFERENCE
  static Future<bool?> saveUserName(String isUsername) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(userName, isUsername);
    return null;
  }
  // SAVE THE USER PHONE STATUS SHARED PREFERENCE
  static Future<bool?> saveUserPhone(String isUserPhone) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(phone, isUserPhone);
    return null;
  }
  // SAVE THE USER DOB STATUS SHARED PREFERENCE
  static Future<bool?> saveUserDob(String isUserDob) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(dob, isUserDob);
    return null;
  }
  // SAVE THE USER EMAIL STATUS SHARED PREFERENCE
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
  static Future<String?> getName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userName);
  }

  // GET THE EMAIL STATUS SHARED PREFERENCE
  static Future<String?> getEmail() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userEmail);
  }
  // GET THE PHONE STATUS SHARED PREFERENCE
  static Future<String?> getPhone() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(phone);
  }
  // GET THE DOB STATUS SHARED PREFERENCE
  static Future<String?> getDob() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(dob);
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
  // 21/04/23
  static Future<String?> getMessageUrl() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(messageUrl);
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
