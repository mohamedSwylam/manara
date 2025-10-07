import 'package:get/get.dart';
import '../models/auth/login_response_model.dart';
import '../utility/token_manager.dart';
import '../utility/secure_storage_manager.dart';
import '../services/auth_service.dart';
import 'dart:convert';

class MoreScreenController extends GetxController {
  final _isLoggedIn = false.obs;
  final _userData = Rxn<UserData>();

  bool get isLoggedIn => _isLoggedIn.value;
  UserData? get userData => _userData.value;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final isLoggedIn = await SecureStorageManager.isLoggedIn();
    _isLoggedIn.value = isLoggedIn;
    
    if (isLoggedIn) {
      // Try to get user ID from secure storage
      final userId = await SecureStorageManager.getUserId();
      if (userId != null && userId.isNotEmpty) {
        // Fetch fresh user data from API
        final freshUserData = await AuthService.findUserById(userId);
        if (freshUserData != null) {
          _userData.value = freshUserData;
          // Update stored user data with fresh data
          await SecureStorageManager.saveUserData(jsonEncode(freshUserData.toJson()));
        } else {
          // User not found, clear login status
          _isLoggedIn.value = false;
          _userData.value = null;
          await SecureStorageManager.logout();
          await AuthController.clearTokenValue();
        }
      } else {
        // No user ID found, clear login status
        _isLoggedIn.value = false;
        _userData.value = null;
        await SecureStorageManager.logout();
        await AuthController.clearTokenValue();
      }
    } else {
      _userData.value = null;
    }
  }

  void updateLoginStatus(bool isLoggedIn, {UserData? userData}) {
    _isLoggedIn.value = isLoggedIn;
    if (userData != null) {
      _userData.value = userData;
    }
  }

  Future<void> logout() async {
    _isLoggedIn.value = false;
    _userData.value = null;
    await SecureStorageManager.logout();
    await AuthController.clearTokenValue();
  }
}
