import 'package:shared_preferences/shared_preferences.dart';

class UserDataController {
  static String? _userId;
  static String? _userMail;
  static String? _userName;

  static String? get userId => _userId;

  static String? get userMail => _userMail;

  static String? get userName => _userName;

  static Future<void> setUserId(String uId) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.setString('user_id', uId);
    _userId = uId;
  }

  static Future<void> getUserId() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _userId = sharedPreferences.getString('user_id');
  }

  static Future<void> setUserMail(String uMail) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.setString('user_mail', uMail);
    _userMail = uMail;
  }

  static Future<void> getUserMail() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _userMail = sharedPreferences.getString('user_mail');
  }

  static Future<void> setUserName(String userName) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.setString('user_name', userName);
    _userName = userName;
  }

  static Future<void> getUserName() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _userName = sharedPreferences.getString('user_name');
  }
}
