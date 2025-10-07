import 'package:shared_preferences/shared_preferences.dart';

class PasswordService {
  static const String _passwordKey = 'user_password';
  static const String _passwordSetDateKey = 'password_set_date';

  // Check if password is set
  static Future<bool> isPasswordSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey) != null;
  }

  // Get stored password
  static Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey);
  }

  // Set password
  static Future<bool> setPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString(_passwordKey, password);
    await prefs.setString(_passwordSetDateKey, now.toIso8601String());
    return true;
  }

  // Verify password
  static Future<bool> verifyPassword(String password) async {
    final storedPassword = await getPassword();
    return storedPassword == password;
  }

  // Get password set date
  static Future<DateTime?> getPasswordSetDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_passwordSetDateKey);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  // Format date for display
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  // Clear password (for testing/reset)
  static Future<bool> clearPassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_passwordKey);
    await prefs.remove(_passwordSetDateKey);
    return true;
  }

  // Test method to verify functionality
  static Future<void> testPasswordService() async {
    print('Testing Password Service...');
    
    // Test 1: Check if password is set initially
    bool isSet = await isPasswordSet();
    print('Initial password set: $isSet');
    
    // Test 2: Set a password
    await setPassword('TestPassword123!');
    isSet = await isPasswordSet();
    print('After setting password: $isSet');
    
    // Test 3: Verify password
    bool isValid = await verifyPassword('TestPassword123!');
    print('Password verification (correct): $isValid');
    
    bool isInvalid = await verifyPassword('WrongPassword');
    print('Password verification (incorrect): $isInvalid');
    
    // Test 4: Get set date
    final setDate = await getPasswordSetDate();
    print('Password set date: $setDate');
    
    // Test 5: Format date
    if (setDate != null) {
      final formattedDate = formatDate(setDate);
      print('Formatted date: $formattedDate');
    }
    
    // Test 6: Clear password
    await clearPassword();
    isSet = await isPasswordSet();
    print('After clearing password: $isSet');
    
    print('Password Service test completed!');
  }
}
