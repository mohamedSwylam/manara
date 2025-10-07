import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  static String? _accessToken;
  static String? _tokenExpireTime;

  static String? get accessToken => _accessToken;

  static String? get tokenExpireTime => _tokenExpireTime;

  static Future<void> setExpireDateAndTime(String expTime) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.setString('expire_time', expTime);
    _tokenExpireTime = expTime;
  }

  static Future<void> getExpireDateAndTime() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _tokenExpireTime = sharedPreferences.getString('expire_time');
  }

  static Future<void> setAccessToken(String token) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.setString('access_token', token);
    _accessToken = token;
  }

  static Future<void> getAccessToken() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _accessToken = sharedPreferences.getString('access_token');
  }

  static Future<void> clearTokenValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('access_token');
    prefs.remove('user_id');
    print('Value associated with key access_token has been cleared.');
  }

  static bool get isLoggedIn {
    return _accessToken != null;
  }
}
