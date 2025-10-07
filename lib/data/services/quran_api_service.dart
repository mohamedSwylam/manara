import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import '../models/quran/quran_surah_model.dart';
import '../models/quran/quran_bookmark_model.dart';
import '../bloc/quran/quran_state.dart';

class QuranApiService {
  static const String baseUrl = 'https://api.alquran.cloud/v1';
  static const String surahBoxName = 'quran_surahs';
  static const String bookmarkBoxName = 'quran_bookmarks';
  static const String lastReadBoxName = 'quran_last_read';

  // Predefined page numbers for surahs (approximate)
  static const Map<int, int> surahToPage = {
    1: 1, 2: 2, 3: 50, 4: 77, 5: 106, 6: 128, 7: 151, 8: 177, 9: 187, 10: 208,
    11: 221, 12: 235, 13: 249, 14: 255, 15: 262, 16: 267, 17: 282, 18: 293, 19: 305, 20: 312,
    21: 322, 22: 332, 23: 342, 24: 350, 25: 359, 26: 367, 27: 377, 28: 385, 29: 396, 30: 404,
    31: 411, 32: 415, 33: 418, 34: 428, 35: 434, 36: 440, 37: 446, 38: 453, 39: 458, 40: 467,
    41: 477, 42: 483, 43: 489, 44: 496, 45: 499, 46: 502, 47: 507, 48: 511, 49: 515, 50: 518,
    51: 520, 52: 523, 53: 526, 54: 528, 55: 531, 56: 534, 57: 537, 58: 542, 59: 545, 60: 549,
    61: 551, 62: 553, 63: 554, 64: 556, 65: 558, 66: 560, 67: 562, 68: 564, 69: 566, 70: 568,
    71: 570, 72: 572, 73: 574, 74: 575, 75: 577, 76: 578, 77: 580, 78: 582, 79: 583, 80: 585,
    81: 586, 82: 587, 83: 587, 84: 589, 85: 590, 86: 591, 87: 591, 88: 592, 89: 593, 90: 594,
    91: 595, 92: 595, 93: 596, 94: 596, 95: 597, 96: 597, 97: 598, 98: 598, 99: 599, 100: 599,
    101: 600, 102: 600, 103: 601, 104: 601, 105: 601, 106: 602, 107: 602, 108: 602, 109: 603, 110: 603,
    111: 603, 112: 604, 113: 604, 114: 604,
  };

  // Get accurate quarters for a specific Juz from API
  static Future<List<QuranQuarter>> getQuartersForJuz(int juzNumber) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/juz/$juzNumber'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final quarters = <QuranQuarter>[];
        
        if (data['data'] != null && data['data']['ayahs'] != null) {
          final ayahs = data['data']['ayahs'] as List;
          
          // Group ayahs into quarters (every 1/4 of the Juz)
          final totalAyahs = ayahs.length;
          final quarterSize = (totalAyahs / 8).ceil(); // 8 quarters per Juz (2 hizb × 4 quarters)
          
          for (int i = 0; i < 8; i++) {
            final startIndex = i * quarterSize;
            if (startIndex < ayahs.length) {
              final ayah = ayahs[startIndex];
              final quarterName = _getQuarterName(i + 1);
              final hizbInJuz = (i < 4) ? 1 : 2;
              
              quarters.add(QuranQuarter(
                juzNumber: juzNumber,
                hizbInJuz: hizbInJuz,
                quarterName: quarterName,
                surahNumber: ayah['surah']['number'],
                surahName: ayah['surah']['name'],
                startAyah: ayah['numberInSurah'],
                pageNumber: ayah['page'],
              ));
            }
          }
        }
        
        return quarters;
      } else {
        throw Exception('Failed to load Juz data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting quarters for Juz $juzNumber: $e');
      // Fallback to empty list if API fails
      return [];
    }
  }

  // Get quarters for a specific Hizb within a Juz
  static Future<List<QuranQuarter>> getQuartersForHizb(int juzNumber, int hizbInJuz) async {
    final allQuarters = await getQuartersForJuz(juzNumber);
    return allQuarters.where((quarter) => quarter.hizbInJuz == hizbInJuz).toList();
  }

  // Helper method to get quarter name
  static String _getQuarterName(int quarterIndex) {
    switch (quarterIndex) {
      case 1: return "1/4";
      case 2: return "1/2";
      case 3: return "3/4";
      case 4: return "End";
      case 5: return "1/4";
      case 6: return "1/2";
      case 7: return "3/4";
      case 8: return "End";
      default: return "1/4";
    }
  }

  // Helper method to get Juz information for a surah from API
  static Future<List<int>> _getJuzForSurahFromAPI(int surahNumber) async {
    try {
      // Complete mapping based on Quran structure
      // This maps each surah to the juz where it appears
      switch (surahNumber) {
        case 1: return [1]; // Al-Fatiha
        case 2: return [1, 2, 3]; // Al-Baqarah spans Juz 1, 2, 3
        case 3: return [3, 4]; // Aal-Imran spans Juz 3, 4
        case 4: return [4, 5, 6]; // An-Nisa spans Juz 4, 5, 6
        case 5: return [6, 7]; // Al-Ma'idah spans Juz 6, 7
        case 6: return [7, 8]; // Al-An'am spans Juz 7, 8
        case 7: return [8, 9]; // Al-A'raf spans Juz 8, 9
        case 8: return [9, 10]; // Al-Anfal spans Juz 9, 10
        case 9: return [10, 11]; // At-Tawbah spans Juz 10, 11
        case 10: return [11]; // Yunus
        case 11: return [11, 12]; // Hud spans Juz 11, 12
        case 12: return [12, 13]; // Yusuf spans Juz 12, 13
        case 13: return [13]; // Ar-Ra'd
        case 14: return [13]; // Ibrahim
        case 15: return [14]; // Al-Hijr
        case 16: return [14, 15]; // An-Nahl spans Juz 14, 15
        case 17: return [15, 16]; // Al-Isra spans Juz 15, 16
        case 18: return [15, 16]; // Al-Kahf spans Juz 15, 16
        case 19: return [16]; // Maryam
        case 20: return [16]; // Ta-Ha
        case 21: return [17]; // Al-Anbya
        case 22: return [17]; // Al-Hajj
        case 23: return [18]; // Al-Mu'minun
        case 24: return [18]; // An-Nur
        case 25: return [19]; // Al-Furqan
        case 26: return [19]; // Ash-Shu'ara
        case 27: return [19, 20]; // An-Naml spans Juz 19, 20
        case 28: return [20]; // Al-Qasas
        case 29: return [20, 21]; // Al-Ankabut spans Juz 20, 21
        case 30: return [21]; // Ar-Rum
        case 31: return [21]; // Luqman
        case 32: return [21]; // As-Sajdah
        case 33: return [21, 22]; // Al-Ahzab spans Juz 21, 22
        case 34: return [22]; // Saba
        case 35: return [22]; // Fatir
        case 36: return [22, 23]; // Ya-Sin spans Juz 22, 23
        case 37: return [23]; // As-Saffat
        case 38: return [23]; // Sad
        case 39: return [23, 24]; // Az-Zumar spans Juz 23, 24
        case 40: return [24, 25]; // Ghafir spans Juz 24, 25
        case 41: return [25]; // Fussilat
        case 42: return [25]; // Ash-Shuraa
        case 43: return [25]; // Az-Zukhruf
        case 44: return [25]; // Ad-Dukhan
        case 45: return [25]; // Al-Jathiyah
        case 46: return [26]; // Al-Ahqaf
        case 47: return [26]; // Muhammad
        case 48: return [26]; // Al-Fath
        case 49: return [26]; // Al-Hujurat
        case 50: return [26]; // Qaf
        case 51: return [26, 27]; // Adh-Dhariyat spans Juz 26, 27
        case 52: return [27]; // At-Tur
        case 53: return [27]; // An-Najm
        case 54: return [27]; // Al-Qamar
        case 55: return [27]; // Ar-Rahman
        case 56: return [27]; // Al-Waqi'ah
        case 57: return [27]; // Al-Hadid
        case 58: return [28]; // Al-Mujadila
        case 59: return [28]; // Al-Hashr
        case 60: return [28]; // Al-Mumtahanah
        case 61: return [28]; // As-Saf
        case 62: return [28]; // Al-Jumu'ah
        case 63: return [28]; // Al-Munafiqun
        case 64: return [28]; // At-Taghabun
        case 65: return [28]; // At-Talaq
        case 66: return [28]; // At-Tahrim
        case 67: return [29]; // Al-Mulk
        case 68: return [29]; // Al-Qalam
        case 69: return [29]; // Al-Haqqah
        case 70: return [29]; // Al-Ma'arij
        case 71: return [29]; // Nuh
        case 72: return [29]; // Al-Jinn
        case 73: return [29]; // Al-Muzzammil
        case 74: return [29]; // Al-Muddathir
        case 75: return [29]; // Al-Qiyamah
        case 76: return [29]; // Al-Insan
        case 77: return [29]; // Al-Mursalat
        case 78: return [30]; // An-Naba
        case 79: return [30]; // An-Nazi'at
        case 80: return [30]; // Abasa
        case 81: return [30]; // At-Takwir
        case 82: return [30]; // Al-Infitar
        case 83: return [30]; // Al-Mutaffifin
        case 84: return [30]; // Al-Inshiqaq
        case 85: return [30]; // Al-Buruj
        case 86: return [30]; // At-Tariq
        case 87: return [30]; // Al-A'la
        case 88: return [30]; // Al-Ghashiyah
        case 89: return [30]; // Al-Fajr
        case 90: return [30]; // Al-Balad
        case 91: return [30]; // Ash-Shams
        case 92: return [30]; // Al-Layl
        case 93: return [30]; // Ad-Duha
        case 94: return [30]; // Ash-Sharh
        case 95: return [30]; // At-Tin
        case 96: return [30]; // Al-Alaq
        case 97: return [30]; // Al-Qadr
        case 98: return [30]; // Al-Bayyinah
        case 99: return [30]; // Az-Zalzalah
        case 100: return [30]; // Al-Adiyat
        case 101: return [30]; // Al-Qari'ah
        case 102: return [30]; // At-Takathur
        case 103: return [30]; // Al-Asr
        case 104: return [30]; // Al-Humazah
        case 105: return [30]; // Al-Fil
        case 106: return [30]; // Quraysh
        case 107: return [30]; // Al-Ma'un
        case 108: return [30]; // Al-Kawthar
        case 109: return [30]; // Al-Kafirun
        case 110: return [30]; // An-Nasr
        case 111: return [30]; // Al-Masad
        case 112: return [30]; // Al-Ikhlas
        case 113: return [30]; // Al-Falaq
        case 114: return [30]; // An-Nas
        default: return [1]; // Default fallback
      }
    } catch (e) {
      print('Error getting Juz for surah $surahNumber: $e');
      return [1]; // Default fallback
    }
  }

  // Initialize Hive boxes
  static Future<void> initializeHive() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(QuranSurahModelAdapter());
    Hive.registerAdapter(QuranBookmarkModelAdapter());
    
    // Open boxes
    await Hive.openBox<QuranSurahModel>(surahBoxName);
    await Hive.openBox<QuranBookmarkModel>(bookmarkBoxName);
    await Hive.openBox(lastReadBoxName);
    await Hive.openBox('ayah_texts');
    await Hive.openBox('processed_surahs');
    await Hive.openBox('processed_juzs');
  }

  // Get all surahs from API with correct Juz mapping
  static Future<List<QuranSurahModel>> getAllSurahs() async {
    try {
      // First, try to load from cache
      final cachedSurahs = await _loadSurahsFromCache();
      if (cachedSurahs.isNotEmpty) {
        print('=== LOADING FROM CACHE ===');
        print('Loaded ${cachedSurahs.length} surahs from cache');
        return cachedSurahs;
      }
      
      print('=== FETCHING FRESH DATA FROM API ===');
      
      // Fetch from API
      final response = await http.get(Uri.parse('$baseUrl/surah'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        print('API returned ${data['data'].length} surahs');
        
        // Use API to get accurate Juz mapping for each surah
        final apiSurahs = <QuranSurahModel>[];
        
        for (final surahData in data['data']) {
          final surahNumber = surahData['number'] ?? 0;
          final pageNumber = surahToPage[surahNumber] ?? 1;
          
          // Get Juz information from API for each surah
          final juzInfo = await _getJuzForSurahFromAPI(surahNumber);
          
          print('Surah $surahNumber: Mapped to Juz $juzInfo, Page $pageNumber');
          
          // Create a surah for each Juz it appears in
          for (final juzNumber in juzInfo) {
            final surah = QuranSurahModel.fromJson({
              ...surahData,
              'juz': juzNumber,
              'page': pageNumber,
            });
            apiSurahs.add(surah);
           }
         }
        
        // Debug: Check Juz distribution in new data
        final juzDistribution = <int, int>{};
        for (final surah in apiSurahs) {
          juzDistribution[surah.juz] = (juzDistribution[surah.juz] ?? 0) + 1;
        }
        print('New Juz distribution: $juzDistribution');
        
        print('Fetched ${apiSurahs.length} surahs from API');
        
        // Cache the fetched data
        await _cacheSurahs(apiSurahs);
        print('Surahs cached successfully');
        
        return apiSurahs;
      } else {
        throw Exception('Failed to load surahs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading surahs: $e');
      throw Exception('Failed to load surahs: $e');
    }
  }

  // Get specific surah details
  static Future<Map<String, dynamic>> getSurahDetails(int surahNumber) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/surah/$surahNumber'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load surah details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load surah details: $e');
    }
  }

  // Get specific juz information
  static Future<Map<String, dynamic>> getJuzDetails(int juzNumber) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/juz/$juzNumber'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load juz details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load juz details: $e');
    }
  }



  // Load surahs from cache
  static Future<List<QuranSurahModel>> _loadSurahsFromCache() async {
    try {
      final box = Hive.box<QuranSurahModel>(surahBoxName);
      final surahs = <QuranSurahModel>[];
      
      if (box.isEmpty) {
        print('Cache is empty, will fetch from API');
        return [];
      }
      
      // Load all surahs from cache
      for (int i = 0; i < box.length; i++) {
        final surah = box.get(i);
        if (surah != null) {
          surahs.add(surah);
        }
      }
      
      print('Found ${surahs.length} surahs in cache');
      return surahs;
    } catch (e) {
      print('Error loading surahs from cache: $e');
      return [];
    }
  }

  // Cache surahs
  static Future<void> _cacheSurahs(List<QuranSurahModel> surahs) async {
    try {
      final box = Hive.box<QuranSurahModel>(surahBoxName);
      await box.clear();
      
      for (int i = 0; i < surahs.length; i++) {
        await box.put(i, surahs[i]);
      }
      
      // Store timestamp separately
      final timestampBox = Hive.box('quran_timestamp');
      await timestampBox.put('timestamp', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error caching surahs: $e');
    }
  }

  // Clear all Quran-related cache
  static Future<void> clearAllQuranCache() async {
    try {
      // Clear surahs cache
      final surahBox = Hive.box<QuranSurahModel>(surahBoxName);
      await surahBox.clear();
      
      // Clear processed surahs cache
      final processedSurahsBox = Hive.box('processed_surahs');
      await processedSurahsBox.clear();
      
      // Clear processed juzs cache
      final processedJuzsBox = Hive.box('processed_juzs');
      await processedJuzsBox.clear();
      
      // Clear ayah texts cache
      final ayahTextsBox = Hive.box('ayah_texts');
      await ayahTextsBox.clear();
      
      // Clear bookmarks cache
      final bookmarkBox = Hive.box<QuranBookmarkModel>(bookmarkBoxName);
      await bookmarkBox.clear();
      
      // Clear last read cache
      final lastReadBox = Hive.box(lastReadBoxName);
      await lastReadBox.clear();
      
      print('All Quran cache cleared');
    } catch (e) {
      print('Error clearing all Quran cache: $e');
    }
  }

  // Force refresh cache
  static Future<void> forceRefresh() async {
    print('Force refreshing cache...');
    await clearAllQuranCache();
    print('All Quran cache cleared for fresh data');
  }

  // Check if cache exists and is valid
  static Future<bool> hasValidCache() async {
    try {
      final box = Hive.box<QuranSurahModel>(surahBoxName);
      return box.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Check if processed cache exists and is valid
  static Future<bool> hasValidProcessedCache() async {
    try {
      // Ensure boxes are opened
      if (!Hive.isBoxOpen('processed_surahs')) {
        await Hive.openBox('processed_surahs');
      }
      if (!Hive.isBoxOpen('processed_juzs')) {
        await Hive.openBox('processed_juzs');
      }
      
      final surahsBox = Hive.box('processed_surahs');
      final juzsBox = Hive.box('processed_juzs');
      
      return surahsBox.isNotEmpty && juzsBox.isNotEmpty;
    } catch (e) {
      print('Error checking processed cache: $e');
      return false;
    }
  }

  // Cache processed QuranSurah objects
  static Future<void> cacheProcessedSurahs(List<QuranSurah> surahs) async {
    try {
      // Ensure box is opened
      if (!Hive.isBoxOpen('processed_surahs')) {
        await Hive.openBox('processed_surahs');
      }
      final box = Hive.box('processed_surahs');
      await box.clear();
      
      print('DEBUG: Caching ${surahs.length} processed surahs...');
      
      for (int i = 0; i < surahs.length; i++) {
        await box.put(i, {
          'number': surahs[i].number,
          'name': surahs[i].name,
          'arabicName': surahs[i].arabicName,
          'englishName': surahs[i].englishName,
          'revelationType': surahs[i].revelationType,
          'numberOfAyahs': surahs[i].numberOfAyahs,
          'juz': surahs[i].juz,
          'page': surahs[i].page,
        });
      }
      
      print('DEBUG: Processed surahs cached successfully. Box length: ${box.length}');
    } catch (e) {
      print('Error caching processed surahs: $e');
    }
  }

  // Load processed QuranSurah objects from cache
  static Future<List<QuranSurah>> loadProcessedSurahsFromCache() async {
    try {
      // Ensure box is opened
      if (!Hive.isBoxOpen('processed_surahs')) {
        await Hive.openBox('processed_surahs');
      }
      final box = Hive.box('processed_surahs');
      final surahs = <QuranSurah>[];
      
      print('DEBUG: Checking processed surahs cache. Box length: ${box.length}');
      
      if (box.isEmpty) {
        print('DEBUG: Processed surahs cache is empty');
        return [];
      }
      
      for (int i = 0; i < box.length; i++) {
        final data = box.get(i) as Map<dynamic, dynamic>;
        surahs.add(QuranSurah(
          number: data['number'] as int,
          name: data['name'] as String,
          arabicName: data['arabicName'] as String,
          englishName: data['englishName'] as String,
          revelationType: data['revelationType'] as String,
          numberOfAyahs: data['numberOfAyahs'] as int,
          juz: data['juz'] as int,
          page: data['page'] as int,
        ));
      }
      
      print('Loaded ${surahs.length} processed surahs from cache');
      return surahs;
    } catch (e) {
      print('Error loading processed surahs from cache: $e');
      return [];
    }
  }

  // Cache processed juzs
  static Future<void> cacheProcessedJuzs(List<QuranJuz> juzs) async {
    try {
      // Ensure box is opened
      if (!Hive.isBoxOpen('processed_juzs')) {
        await Hive.openBox('processed_juzs');
      }
      final box = Hive.box('processed_juzs');
      await box.clear();
      
      print('DEBUG: Caching ${juzs.length} processed juzs...');
      
      for (int i = 0; i < juzs.length; i++) {
        final juz = juzs[i];
        await box.put(i, {
          'number': juz.number,
          'startPage': juz.startPage,
          'endPage': juz.endPage,
          'surahs': juz.surahs.map((s) => {
            'number': s.number,
            'name': s.name,
            'arabicName': s.arabicName,
            'englishName': s.englishName,
            'revelationType': s.revelationType,
            'numberOfAyahs': s.numberOfAyahs,
            'juz': s.juz,
            'page': s.page,
          }).toList(),
          'quarters': juz.quarters.map((q) => {
            'juzNumber': q.juzNumber,
            'hizbInJuz': q.hizbInJuz,
            'quarterName': q.quarterName,
            'surahNumber': q.surahNumber,
            'surahName': q.surahName,
            'startAyah': q.startAyah,
            'pageNumber': q.pageNumber,
          }).toList(),
        });
      }
      
      print('DEBUG: Processed juzs cached successfully. Box length: ${box.length}');
    } catch (e) {
      print('Error caching processed juzs: $e');
    }
  }

  // Load processed juzs from cache
  static Future<List<QuranJuz>> loadProcessedJuzsFromCache() async {
    try {
      // Ensure box is opened
      if (!Hive.isBoxOpen('processed_juzs')) {
        await Hive.openBox('processed_juzs');
      }
      final box = Hive.box('processed_juzs');
      final juzs = <QuranJuz>[];
      
      print('DEBUG: Checking processed juzs cache. Box length: ${box.length}');
      
      if (box.isEmpty) {
        print('DEBUG: Processed juzs cache is empty');
        return [];
      }
      
      for (int i = 0; i < box.length; i++) {
        final data = box.get(i) as Map<dynamic, dynamic>;
        final surahs = (data['surahs'] as List).map((s) => QuranSurah(
          number: s['number'] as int,
          name: s['name'] as String,
          arabicName: s['arabicName'] as String,
          englishName: s['englishName'] as String,
          revelationType: s['revelationType'] as String,
          numberOfAyahs: s['numberOfAyahs'] as int,
          juz: s['juz'] as int,
          page: s['page'] as int,
        )).toList();
        
        final quarters = (data['quarters'] as List).map((q) => QuranQuarter(
          juzNumber: q['juzNumber'] as int,
          hizbInJuz: q['hizbInJuz'] as int,
          quarterName: q['quarterName'] as String,
          surahNumber: q['surahNumber'] as int,
          surahName: q['surahName'] as String,
          startAyah: q['startAyah'] as int,
          pageNumber: q['pageNumber'] as int,
        )).toList();
        
        juzs.add(QuranJuz(
          number: data['number'],
          startPage: data['startPage'],
          endPage: data['endPage'],
          surahs: surahs,
          quarters: quarters,
        ));
      }
      
      print('Loaded ${juzs.length} processed juzs from cache');
      return juzs;
    } catch (e) {
      print('Error loading processed juzs from cache: $e');
      return [];
    }
  }

  // Get ayah text from API
  static Future<String> getAyahText(int surahNumber, int ayahNumber) async {
    try {
      // For alquran.cloud API, we need to fetch the entire surah and find the specific ayah
      final response = await http.get(
        Uri.parse('$baseUrl/surah/$surahNumber'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final ayahs = data['data']['ayahs'] as List;
        
        // Find the specific ayah
        for (final ayah in ayahs) {
          if (ayah['numberInSurah'] == ayahNumber) {
            // Get text based on app language
            final locale = Get.locale?.languageCode ?? 'en';
            
            String text;
            if (locale == 'ar') {
              // Return Arabic text
              text = ayah['text'] ?? 'نص الآية غير متوفر';
            } else {
              // For now, return Arabic text since translation requires additional API call
              // TODO: Implement translation API call
              text = ayah['text'] ?? 'Ayah text not available';
            }
            
            return text;
          }
        }
      }
      
      return 'Ayah text not available';
    } catch (e) {
      print('Error fetching ayah text: $e');
      return 'Ayah text not available';
    }
  }

  // Cache ayah texts
  static Future<void> cacheAyahText(int surahNumber, int ayahNumber, String text) async {
    try {
      final box = Hive.box('ayah_texts');
      final key = '${surahNumber}_$ayahNumber';
      await box.put(key, text);
    } catch (e) {
      print('Error caching ayah text: $e');
    }
  }

  // Get cached ayah text
  static String? getCachedAyahText(int surahNumber, int ayahNumber) {
    try {
      final box = Hive.box('ayah_texts');
      final key = '${surahNumber}_$ayahNumber';
      return box.get(key);
    } catch (e) {
      print('Error getting cached ayah text: $e');
      return null;
    }
  }

  // Preload ayah texts for quarters (for better performance)
  static Future<void> preloadQuarterAyahTexts() async {
    // No preloading for now - no caching
    print('Skipping ayah text preloading - no caching');
  }

  // Get bookmarks
  static Future<List<QuranBookmarkModel>> getBookmarks() async {
    // Return empty list for now - no caching
    return [];
  }

  // Add bookmark
  static Future<void> addBookmark(QuranBookmarkModel bookmark) async {
    try {
      final box = Hive.box<QuranBookmarkModel>(bookmarkBoxName);
      await box.add(bookmark);
    } catch (e) {
      print('Error adding bookmark: $e');
    }
  }

  // Remove bookmark
  static Future<void> removeBookmark(String bookmarkId) async {
    try {
      final box = Hive.box<QuranBookmarkModel>(bookmarkBoxName);
      final bookmarks = box.values.toList();
      final index = bookmarks.indexWhere((bookmark) => bookmark.id == bookmarkId);
      if (index != -1) {
        await box.deleteAt(index);
      }
    } catch (e) {
      print('Error removing bookmark: $e');
    }
  }

  // Get last read
  static Future<Map<String, dynamic>?> getLastRead() async {
    // Return default values for now - no caching
    return {
      'surahName': 'Al Fatiah',
      'page': 1,
      'juz': 1,
    };
  }

  // Save last read
  static Future<void> saveLastRead(String surahName, int page, int juz) async {
    try {
      final box = Hive.box(lastReadBoxName);
      await box.put('surahName', surahName);
      await box.put('page', page);
      await box.put('juz', juz);
    } catch (e) {
      print('Error saving last read: $e');
    }
  }
}
