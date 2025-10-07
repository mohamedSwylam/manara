import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LastReadService {
  static const String _lastReadKey = 'last_read_surah';
  
  /// Save the last read surah information
  static Future<void> saveLastRead({
    required int surahNumber,
    required String surahName,
    required int pageNumber,
    required int juzNumber,
    required int ayahNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final lastReadData = {
      'surahNumber': surahNumber,
      'surahName': surahName,
      'pageNumber': pageNumber,
      'juzNumber': juzNumber,
      'ayahNumber': ayahNumber,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    print('DEBUG: LastReadService - Saving data:');
    print('  $lastReadData');
    
    await prefs.setString(_lastReadKey, jsonEncode(lastReadData));
  }
  
  /// Get the last read surah information
  static Future<Map<String, dynamic>?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReadString = prefs.getString(_lastReadKey);
    
    if (lastReadString != null) {
      try {
        final data = jsonDecode(lastReadString) as Map<String, dynamic>;
        print('DEBUG: LastReadService - Retrieved data:');
        print('  $data');
        return data;
      } catch (e) {
        print('Error parsing last read data: $e');
        return null;
      }
    }
    
    print('DEBUG: LastReadService - No saved data found');
    return null;
  }
  
  /// Check if user has any last read data
  static Future<bool> hasLastRead() async {
    final lastRead = await getLastRead();
    return lastRead != null;
  }
  
  /// Clear the last read data
  static Future<void> clearLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastReadKey);
  }
}
