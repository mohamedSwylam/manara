import 'dart:developer';
import 'package:hive/hive.dart';
import '../models/dua/dua_category_model.dart';

class DuaCacheService {
  static const String _duaCategoriesBoxName = 'dua_categories';
  static const String _lastUpdateKey = 'last_update';
  static const Duration _cacheValidityDuration = Duration(hours: 24); // Cache for 24 hours

  static Future<void> initialize() async {
    try {
      log('🔄 Starting dua cache service initialization...');
      
      // Don't close boxes if they're already open - this preserves data
      bool categoriesBoxWasOpen = Hive.isBoxOpen(_duaCategoriesBoxName);
      bool lastUpdateBoxWasOpen = Hive.isBoxOpen(_lastUpdateKey);
      
      if (categoriesBoxWasOpen) {
        log('📦 Dua categories box already open, preserving data');
      }
      if (lastUpdateBoxWasOpen) {
        log('📦 Last update box already open, preserving data');
      }
      
      // Try to open boxes normally first (preserve existing data)
      try {
        log('🔍 Attempting to open boxes with existing data...');
        
        // Only open if not already open
        if (!categoriesBoxWasOpen) {
          await Hive.openBox<DuaCategoryModel>(_duaCategoriesBoxName);
        }
        if (!lastUpdateBoxWasOpen) {
          await Hive.openBox(_lastUpdateKey);
        }
        
        // Check if there's any data
        final box = Hive.box<DuaCategoryModel>(_duaCategoriesBoxName);
        final lastUpdateBox = Hive.box(_lastUpdateKey);
        final itemCount = box.length;
        final hasTimestamp = lastUpdateBox.get(_lastUpdateKey) != null;
        
        log('✅ Dua cache service initialized with existing data preserved');
        log('📊 Cache status: $itemCount items, timestamp: ${hasTimestamp ? 'exists' : 'missing'}');
      } catch (e) {
        // If opening fails due to corrupted data, then clear and recreate
        log('⚠️ Corrupted cache detected: $e');
        log('⚠️ Clearing and recreating boxes...');
        
        // Close boxes if they're open before deleting
        if (Hive.isBoxOpen(_duaCategoriesBoxName)) {
          await Hive.box(_duaCategoriesBoxName).close();
        }
        if (Hive.isBoxOpen(_lastUpdateKey)) {
          await Hive.box(_lastUpdateKey).close();
        }
        
        // Delete existing boxes to clear corrupted data
        await Hive.deleteBoxFromDisk(_duaCategoriesBoxName);
        await Hive.deleteBoxFromDisk(_lastUpdateKey);
        
        // Open fresh boxes
        await Hive.openBox<DuaCategoryModel>(_duaCategoriesBoxName);
        await Hive.openBox(_lastUpdateKey);
        log('✅ Dua cache service initialized with fresh boxes after clearing corrupted data');
      }
    } catch (e) {
      log('❌ Error initializing dua cache service: $e');
      // Final fallback - try to open boxes without clearing
      try {
        log('🔄 Attempting fallback initialization...');
        await Hive.openBox<DuaCategoryModel>(_duaCategoriesBoxName);
        await Hive.openBox(_lastUpdateKey);
        log('✅ Dua cache service initialized with fallback');
      } catch (fallbackError) {
        log('❌ Fallback initialization also failed: $fallbackError');
        rethrow;
      }
    }
  }

  /// Check if cache service is properly initialized
  static bool isInitialized() {
    try {
      return Hive.isBoxOpen(_duaCategoriesBoxName) && Hive.isBoxOpen(_lastUpdateKey);
    } catch (e) {
      log('❌ Error checking cache service initialization: $e');
      return false;
    }
  }

  /// Save dua categories to cache
  static Future<void> cacheDuaCategories(List<DuaCategoryModel> categories) async {
    try {
      log('💾 Starting to cache ${categories.length} dua categories...');
      
      // Ensure boxes are opened
      if (!Hive.isBoxOpen(_duaCategoriesBoxName)) {
        log('📦 Opening dua categories box for caching...');
        await Hive.openBox<DuaCategoryModel>(_duaCategoriesBoxName);
      }
      if (!Hive.isBoxOpen(_lastUpdateKey)) {
        log('📦 Opening last update box for caching...');
        await Hive.openBox(_lastUpdateKey);
      }
      
      final box = Hive.box<DuaCategoryModel>(_duaCategoriesBoxName);
      final lastUpdateBox = Hive.box(_lastUpdateKey);
      
      log('📊 Before clearing - Categories box length: ${box.length}');
      
      // Clear existing data
      await box.clear();
      log('🧹 Cleared existing data');
      
              // Save new data
        for (int i = 0; i < categories.length; i++) {
          await box.put(i.toString(), categories[i]);
          log('💾 Saved category ${i + 1}/${categories.length}: ${categories[i].id}');
        }
      
      log('📊 After saving - Categories box length: ${box.length}');
      
      // Save timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await lastUpdateBox.put(_lastUpdateKey, timestamp);
      log('⏰ Saved timestamp: $timestamp');
      
      // Verify the cache was saved correctly
      final verifyBox = Hive.box<DuaCategoryModel>(_duaCategoriesBoxName);
      final verifyTimestamp = lastUpdateBox.get(_lastUpdateKey);
      log('🔍 Verification - Box length: ${verifyBox.length}, Timestamp: $verifyTimestamp');
      
      log('✅ Cached ${categories.length} dua categories');
    } catch (e) {
      log('❌ Error caching dua categories: $e');
      // If it's a typeId error, clear corrupted cache and retry
      if (e.toString().contains('unknown typeId')) {
        log('🔄 Clearing corrupted cache and retrying...');
        try {
          await clearCorruptedCache();
          // Retry caching
          final box = Hive.box<DuaCategoryModel>(_duaCategoriesBoxName);
          final lastUpdateBox = Hive.box(_lastUpdateKey);
          
          await box.clear();
          for (int i = 0; i < categories.length; i++) {
            await box.put(i.toString(), categories[i]);
          }
          await lastUpdateBox.put(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
          log('✅ Successfully cached ${categories.length} dua categories after clearing corrupted data');
        } catch (retryError) {
          log('❌ Failed to cache after clearing corrupted data: $retryError');
        }
      }
    }
  }

  /// Get cached dua categories
  static Future<List<DuaCategoryModel>> getCachedDuaCategories() async {
    try {
      log('🔍 Attempting to get cached dua categories...');
      
      // Ensure boxes are opened
      if (!Hive.isBoxOpen(_duaCategoriesBoxName)) {
        log('📦 Opening dua categories box...');
        await Hive.openBox<DuaCategoryModel>(_duaCategoriesBoxName);
      }
      if (!Hive.isBoxOpen(_lastUpdateKey)) {
        log('📦 Opening last update box...');
        await Hive.openBox(_lastUpdateKey);
      }
      
      final box = Hive.box<DuaCategoryModel>(_duaCategoriesBoxName);
      final lastUpdateBox = Hive.box(_lastUpdateKey);
      
      log('📊 Box status - Categories box length: ${box.length}, Last update box has key: ${lastUpdateBox.get(_lastUpdateKey) != null}');
      
      // Check if cache exists and is valid
      final lastUpdate = lastUpdateBox.get(_lastUpdateKey);
      if (lastUpdate == null) {
        log('📝 No cached dua categories found - no timestamp');
        return <DuaCategoryModel>[]; // Return empty list instead of null
      }
      
      final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
      final now = DateTime.now();
      final timeDifference = now.difference(lastUpdateTime);
      
      log('📅 Cache timestamp: $lastUpdateTime, Current time: $now, Difference: $timeDifference, Valid duration: $_cacheValidityDuration');
      
      if (timeDifference > _cacheValidityDuration) {
        log('📝 Cached dua categories expired');
        return <DuaCategoryModel>[]; // Return empty list instead of null
      }
      
      // Get cached data
      final categories = <DuaCategoryModel>[];
      for (int i = 0; i < box.length; i++) {
        final category = box.get(i.toString());
        if (category != null) {
          categories.add(category);
        }
      }
      
      log('✅ Retrieved ${categories.length} cached dua categories');
      return categories;
    } catch (e) {
      log('❌ Error retrieving cached dua categories: $e');
      // If it's a typeId error, clear corrupted cache
      if (e.toString().contains('unknown typeId')) {
        log('🔄 Clearing corrupted cache due to typeId error...');
        try {
          await clearCorruptedCache();
        } catch (clearError) {
          log('❌ Failed to clear corrupted cache: $clearError');
        }
      }
      return <DuaCategoryModel>[]; // Return empty list instead of null
    }
  }

  /// Check if cache is valid
  static Future<bool> isCacheValid() async {
    try {
      // Ensure box is opened
      if (!Hive.isBoxOpen(_lastUpdateKey)) {
        await Hive.openBox(_lastUpdateKey);
      }
      
      final lastUpdateBox = Hive.box(_lastUpdateKey);
      final lastUpdate = lastUpdateBox.get(_lastUpdateKey);
      
      if (lastUpdate == null) {
        return false;
      }
      
      final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
      final now = DateTime.now();
      
      return now.difference(lastUpdateTime) <= _cacheValidityDuration;
    } catch (e) {
      log('❌ Error checking cache validity: $e');
      return false;
    }
  }

  /// Clear cache
  static Future<void> clearCache() async {
    try {
      // Ensure boxes are opened
      if (!Hive.isBoxOpen(_duaCategoriesBoxName)) {
        await Hive.openBox<DuaCategoryModel>(_duaCategoriesBoxName);
      }
      if (!Hive.isBoxOpen(_lastUpdateKey)) {
        await Hive.openBox(_lastUpdateKey);
      }
      
      final box = Hive.box<DuaCategoryModel>(_duaCategoriesBoxName);
      final lastUpdateBox = Hive.box(_lastUpdateKey);
      
      await box.clear();
      await lastUpdateBox.delete(_lastUpdateKey);
      
      log('✅ Dua categories cache cleared');
    } catch (e) {
      log('❌ Error clearing dua categories cache: $e');
    }
  }

  /// Clear corrupted cache data completely
  static Future<void> clearCorruptedCache() async {
    try {
      // Close boxes if open
      if (Hive.isBoxOpen(_duaCategoriesBoxName)) {
        await Hive.box(_duaCategoriesBoxName).close();
      }
      if (Hive.isBoxOpen(_lastUpdateKey)) {
        await Hive.box(_lastUpdateKey).close();
      }
      
      // Delete boxes from disk
      await Hive.deleteBoxFromDisk(_duaCategoriesBoxName);
      await Hive.deleteBoxFromDisk(_lastUpdateKey);
      
      // Reopen fresh boxes
      await Hive.openBox<DuaCategoryModel>(_duaCategoriesBoxName);
      await Hive.openBox(_lastUpdateKey);
      
      log('✅ Corrupted cache cleared and fresh boxes created');
    } catch (e) {
      log('❌ Error clearing corrupted cache: $e');
      rethrow;
    }
  }

  /// Get expired cached dua categories (for offline mode)
  static Future<List<DuaCategoryModel>> getExpiredCachedDuaCategories() async {
    try {
      log('🔍 Attempting to get expired cached dua categories...');
      
      // Ensure boxes are opened
      if (!Hive.isBoxOpen(_duaCategoriesBoxName)) {
        log('📦 Opening dua categories box for expired data...');
        await Hive.openBox<DuaCategoryModel>(_duaCategoriesBoxName);
      }
      if (!Hive.isBoxOpen(_lastUpdateKey)) {
        log('📦 Opening last update box for expired data...');
        await Hive.openBox(_lastUpdateKey);
      }
      
      final box = Hive.box<DuaCategoryModel>(_duaCategoriesBoxName);
      final lastUpdateBox = Hive.box(_lastUpdateKey);
      
      log('📊 Expired check - Categories box length: ${box.length}, Last update box has key: ${lastUpdateBox.get(_lastUpdateKey) != null}');
      
      // Check if cache exists (regardless of validity)
      final lastUpdate = lastUpdateBox.get(_lastUpdateKey);
      if (lastUpdate == null) {
        log('📝 No cached dua categories found - no timestamp for expired check');
        return <DuaCategoryModel>[];
      }
      
      // Get cached data (even if expired)
      final categories = <DuaCategoryModel>[];
      for (int i = 0; i < box.length; i++) {
        final category = box.get(i.toString());
        if (category != null) {
          categories.add(category);
        }
      }
      
      log('✅ Retrieved ${categories.length} expired cached dua categories');
      return categories;
    } catch (e) {
      log('❌ Error retrieving expired cached dua categories: $e');
      return <DuaCategoryModel>[];
    }
  }

  /// Force clear all cache data (for debugging/testing)
  static Future<void> forceClearAllCache() async {
    try {
      log('🧹 Force clearing all dua cache data...');
      
      // Close boxes if open
      if (Hive.isBoxOpen(_duaCategoriesBoxName)) {
        await Hive.box(_duaCategoriesBoxName).close();
      }
      if (Hive.isBoxOpen(_lastUpdateKey)) {
        await Hive.box(_lastUpdateKey).close();
      }
      
      // Delete boxes from disk
      await Hive.deleteBoxFromDisk(_duaCategoriesBoxName);
      await Hive.deleteBoxFromDisk(_lastUpdateKey);
      
      log('✅ All dua cache data force cleared');
    } catch (e) {
      log('❌ Error force clearing cache: $e');
    }
  }

  /// Add sample data for testing offline functionality
  static Future<void> addSampleDataForTesting() async {
    try {
      log('🧪 Adding sample data for testing...');
      
      // Ensure boxes are opened
      if (!Hive.isBoxOpen(_duaCategoriesBoxName)) {
        await Hive.openBox<DuaCategoryModel>(_duaCategoriesBoxName);
      }
      if (!Hive.isBoxOpen(_lastUpdateKey)) {
        await Hive.openBox(_lastUpdateKey);
      }
      
      final box = Hive.box<DuaCategoryModel>(_duaCategoriesBoxName);
      final lastUpdateBox = Hive.box(_lastUpdateKey);
      
      // Create sample categories
      final sampleCategories = [
        DuaCategoryModel(
          id: 'test1',
          categoryArabic: 'دعاء المغفرة',
          categoryEnglish: 'Dua for Forgiveness',
          categoryTurkish: 'Bağışlanma Duası',
          categoryUrdu: 'معافی کی دعا',
          categoryBangla: 'ক্ষমার জন্য দোয়া',
          categoryHindi: 'क्षमा के लिए दुआ',
          categoryFrench: 'Dua pour le pardon',
          timestamp: '1709061189',
        ),
        DuaCategoryModel(
          id: 'test2',
          categoryArabic: 'دعاء القلق',
          categoryEnglish: 'Dua for Anxiety',
          categoryTurkish: 'Endişe Duası',
          categoryUrdu: 'پریشانی کی دعا',
          categoryBangla: 'উদ্বেগের জন্য দোয়া',
          categoryHindi: 'चिंता के लिए दुआ',
          categoryFrench: 'Dua pour l\'anxiété',
          timestamp: '1709061189',
        ),
        DuaCategoryModel(
          id: 'test3',
          categoryArabic: 'دعاء الحماية',
          categoryEnglish: 'Dua for Protection',
          categoryTurkish: 'Koruma Duası',
          categoryUrdu: 'حفاظت کی دعا',
          categoryBangla: 'সুরক্ষার জন্য দোয়া',
          categoryHindi: 'सुरक्षा के लिए दुआ',
          categoryFrench: 'Dua pour la protection',
          timestamp: '1709061189',
        ),
      ];
      
      // Clear existing data
      await box.clear();
      
      // Save sample data
      for (int i = 0; i < sampleCategories.length; i++) {
        await box.put(i.toString(), sampleCategories[i]);
      }
      
      // Save timestamp (make it expired for testing)
      final expiredTime = DateTime.now().subtract(const Duration(hours: 25)); // 25 hours ago (expired)
      await lastUpdateBox.put(_lastUpdateKey, expiredTime.millisecondsSinceEpoch);
      
      log('✅ Added ${sampleCategories.length} sample categories for testing');
    } catch (e) {
      log('❌ Error adding sample data: $e');
    }
  }

  /// Check if app has ever cached data (for first-time offline users)
  static Future<bool> hasEverCachedData() async {
    try {
      // Ensure boxes are opened
      if (!Hive.isBoxOpen(_duaCategoriesBoxName)) {
        await Hive.openBox<DuaCategoryModel>(_duaCategoriesBoxName);
      }
      if (!Hive.isBoxOpen(_lastUpdateKey)) {
        await Hive.openBox(_lastUpdateKey);
      }
      
      final box = Hive.box<DuaCategoryModel>(_duaCategoriesBoxName);
      final lastUpdateBox = Hive.box(_lastUpdateKey);
      
      // Check if there's any data in the box
      return box.length > 0 || lastUpdateBox.get(_lastUpdateKey) != null;
    } catch (e) {
      log('❌ Error checking if app has ever cached data: $e');
      return false;
    }
  }

  /// Quick test method to add data and verify cache
  static Future<void> quickTest() async {
    try {
      log('🧪 Starting quick cache test...');
      
      // Add sample data
      await addSampleDataForTesting();
      
      // Check cache info
      final info = await getCacheInfo();
      log('📊 Cache test results:');
      log('   - Items: ${info['itemCount']}');
      log('   - Last update: ${info['lastUpdate']}');
      log('   - Is valid: ${info['isValid']}');
      
      // Try to get cached data
      final cachedData = await getCachedDuaCategories();
      log('📝 Valid cached data: ${cachedData.length} items');
      
      // Try to get expired data
      final expiredData = await getExpiredCachedDuaCategories();
      log('📝 Expired cached data: ${expiredData.length} items');
      
      log('✅ Quick cache test completed');
    } catch (e) {
      log('❌ Quick cache test failed: $e');
    }
  }

  /// Test cache persistence across app restarts
  static Future<void> testCachePersistence() async {
    try {
      log('🧪 Testing cache persistence...');
      
      // First, add some data
      await addSampleDataForTesting();
      
      // Check initial state
      final initialInfo = await getCacheInfo();
      log('📊 Initial cache state:');
      log('   - Items: ${initialInfo['itemCount']}');
      log('   - Last update: ${initialInfo['lastUpdate']}');
      
      // Simulate app restart by closing and reopening boxes
      log('🔄 Simulating app restart...');
      if (Hive.isBoxOpen(_duaCategoriesBoxName)) {
        await Hive.box(_duaCategoriesBoxName).close();
      }
      if (Hive.isBoxOpen(_lastUpdateKey)) {
        await Hive.box(_lastUpdateKey).close();
      }
      
      // Wait a moment
      await Future.delayed(Duration(milliseconds: 100));
      
      // Try to retrieve data after "restart"
      final afterRestartData = await getExpiredCachedDuaCategories();
      log('📝 Data after simulated restart: ${afterRestartData.length} items');
      
      // Check final state
      final finalInfo = await getCacheInfo();
      log('📊 Final cache state:');
      log('   - Items: ${finalInfo['itemCount']}');
      log('   - Last update: ${finalInfo['lastUpdate']}');
      
      if (afterRestartData.length > 0) {
        log('✅ Cache persistence test PASSED');
      } else {
        log('❌ Cache persistence test FAILED');
      }
      
    } catch (e) {
      log('❌ Cache persistence test failed: $e');
    }
  }

  /// Get cache info
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      // Ensure boxes are opened
      if (!Hive.isBoxOpen(_duaCategoriesBoxName)) {
        await Hive.openBox<DuaCategoryModel>(_duaCategoriesBoxName);
      }
      if (!Hive.isBoxOpen(_lastUpdateKey)) {
        await Hive.openBox(_lastUpdateKey);
      }
      
      final box = Hive.box<DuaCategoryModel>(_duaCategoriesBoxName);
      final lastUpdateBox = Hive.box(_lastUpdateKey);
      
      final lastUpdate = lastUpdateBox.get(_lastUpdateKey);
      final itemCount = box.length;
      
      return {
        'itemCount': itemCount,
        'lastUpdate': lastUpdate != null 
            ? DateTime.fromMillisecondsSinceEpoch(lastUpdate).toString()
            : 'Never',
        'isValid': await isCacheValid(),
      };
    } catch (e) {
      log('❌ Error getting cache info: $e');
      return {
        'itemCount': 0,
        'lastUpdate': 'Error',
        'isValid': false,
      };
    }
  }
}
