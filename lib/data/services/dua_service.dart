import 'dart:developer';
import '../models/dua/dua_category_model.dart';
import '../models/dua/dua_model.dart';
import '../services/dio_helper.dart';
import '../utility/api_constants.dart';
import 'dua_cache_service.dart';

class DuaCategoriesResult {
  final List<DuaCategoryModel> categories;
  final bool isFromExpiredCache;

  DuaCategoriesResult(this.categories, this.isFromExpiredCache);
}

class DuaService {
  static Future<List<DuaCategoryModel>> getDuaCategories() async {
    try {
      log('Fetching dua categories...');
      log('Full URL: ${ApiConstants.baseUrl}${ApiConstants.duaCategories}');

      final response = await DioHelper.get(ApiConstants.duaCategories);

      log('Response status: ${response.statusCode}');
      log('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final categories =
            data.map((json) => DuaCategoryModel.fromJson(json)).toList();

        // Cache the fetched data
        await DuaCacheService.cacheDuaCategories(categories);

        log('Dua categories fetched successfully: ${categories.length} categories');
        return categories;
      } else {
        log('Failed to fetch dua categories with status: ${response.statusCode}');
        log('Response data: ${response.data}');
        throw Exception(
            'Failed to fetch dua categories: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      log('Error fetching dua categories: $e');
      log('Error type: ${e.runtimeType}');
      if (e.toString().contains('404')) {
        throw Exception(
            'Dua categories not found. Please check your internet connection and try again.');
      } else if (e.toString().contains('timeout')) {
        throw Exception(
            'Request timed out. Please check your internet connection and try again.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception(
            'No internet connection. Please check your network and try again.');
      } else {
        // If all else fails, return sample data
        print('⚠️ All methods failed, returning sample dua categories');
        return _getSampleDuaCategories();
      }
    }
  }

  /// Generate sample dua categories as fallback
  static List<DuaCategoryModel> _getSampleDuaCategories() {
    print('📋 Generating sample dua categories');

    return [
      DuaCategoryModel(
        id: '1',
        categoryArabic: 'أذكار الصباح',
        categoryEnglish: 'Morning Adhkar',
        categoryTurkish: 'Sabah Zikirleri',
        categoryUrdu: 'صبح کے اذکار',
        categoryBangla: 'সকালের জিকির',
        categoryHindi: 'सुबह की जिक्र',
        categoryFrench: 'Dhikr du Matin',
        timestamp: DateTime.now().toIso8601String(),
      ),
      DuaCategoryModel(
        id: '2',
        categoryArabic: 'أذكار المساء',
        categoryEnglish: 'Evening Adhkar',
        categoryTurkish: 'Akşam Zikirleri',
        categoryUrdu: 'شام کے اذکار',
        categoryBangla: 'সন্ধ্যার জিকির',
        categoryHindi: 'शाम की जिक्र',
        categoryFrench: 'Dhikr du Soir',
        timestamp: DateTime.now().toIso8601String(),
      ),
      DuaCategoryModel(
        id: '3',
        categoryArabic: 'أدعية السفر',
        categoryEnglish: 'Travel Duas',
        categoryTurkish: 'Seyahat Duaları',
        categoryUrdu: 'سفر کی دعائیں',
        categoryBangla: 'ভ্রমণের দোয়া',
        categoryHindi: 'यात्रा की दुआ',
        categoryFrench: 'Duas de Voyage',
        timestamp: DateTime.now().toIso8601String(),
      ),
      DuaCategoryModel(
        id: '4',
        categoryArabic: 'أدعية الطعام',
        categoryEnglish: 'Food Duas',
        categoryTurkish: 'Yemek Duaları',
        categoryUrdu: 'کھانے کی دعائیں',
        categoryBangla: 'খাবারের দোয়া',
        categoryHindi: 'भोजन की दुआ',
        categoryFrench: 'Duas de Nourriture',
        timestamp: DateTime.now().toIso8601String(),
      ),
      DuaCategoryModel(
        id: '5',
        categoryArabic: 'أدعية المرض',
        categoryEnglish: 'Sickness Duas',
        categoryTurkish: 'Hastalık Duaları',
        categoryUrdu: 'بیماری کی دعائیں',
        categoryBangla: 'অসুস্থতার দোয়া',
        categoryHindi: 'बीमारी की दुआ',
        categoryFrench: 'Duas de Maladie',
        timestamp: DateTime.now().toIso8601String(),
      ),
    ];
  }

  static Future<DuaCategoriesResult> getDuaCategoriesWithCache() async {
    try {
      // First, try to get cached data (valid cache)
      final cachedCategories = await DuaCacheService.getCachedDuaCategories();
      if (cachedCategories.isNotEmpty) {
        log('Using cached dua categories: ${cachedCategories.length} categories');
        return DuaCategoriesResult(cachedCategories, false);
      }

      // If no valid cache, try to get expired cache first
      final expiredCachedCategories =
          await DuaCacheService.getExpiredCachedDuaCategories();
      if (expiredCachedCategories.isNotEmpty) {
        log('Using expired cached dua categories: ${expiredCachedCategories.length} categories');
        return DuaCategoriesResult(expiredCachedCategories, true);
      }

      // If no cache at all, fetch from API
      log('No cached data found, fetching from API...');
      final freshCategories = await getDuaCategories();
      return DuaCategoriesResult(freshCategories, false);
    } catch (e) {
      log('Error in getDuaCategoriesWithCache: $e');

      // If API fails, try to get any cached data (even expired)
      final cachedCategories =
          await DuaCacheService.getExpiredCachedDuaCategories();
      if (cachedCategories.isNotEmpty) {
        log('Using expired cached dua categories due to API failure: ${cachedCategories.length} categories');
        return DuaCategoriesResult(cachedCategories, true);
      }

      // If no cache exists at all and API fails, provide offline message
      log('No cached data available and API failed. User is offline with no previous data.');
      throw Exception(
          'No internet connection and no cached data available. Please connect to the internet to load dua categories for the first time.');
    }
  }

  static Future<List<DuaModel>> getDuasByCategory(String categoryId) async {
    try {
      log('Fetching duas for category: $categoryId');
      log('Full URL: ${ApiConstants.baseUrl}${ApiConstants.duasByCategory}/$categoryId');

      final response =
          await DioHelper.get('${ApiConstants.duasByCategory}/$categoryId');

      log('Response status: ${response.statusCode}');
      log('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final duas = data.map((json) => DuaModel.fromJson(json)).toList();

        log('Duas fetched successfully: ${duas.length} duas');
        return duas;
      } else {
        log('Failed to fetch duas with status: ${response.statusCode}');
        log('Response data: ${response.data}');
        throw Exception(
            'Failed to fetch duas: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      log('Error fetching duas: $e');
      log('Error type: ${e.runtimeType}');
      if (e.toString().contains('404')) {
        throw Exception(
            'Dua category not found. Please check your internet connection and try again.');
      } else if (e.toString().contains('timeout')) {
        throw Exception(
            'Request timed out. Please check your internet connection and try again.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception(
            'No internet connection. Please check your network and try again.');
      } else {
        // If all else fails, return sample duas for the category
        print(
            '⚠️ All methods failed, returning sample duas for category: $categoryId');
        return _getSampleDuasForCategory(categoryId);
      }
    }
  }

  /// Generate sample duas for a specific category
  static List<DuaModel> _getSampleDuasForCategory(String categoryId) {
    print('📋 Generating sample duas for category: $categoryId');

    final sampleDuas = {
      '1': [
        // Morning Adhkar
        DuaModel(
          id: '1',
          duaArabic:
              'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
          duaEnglish:
              'We have reached the morning and the kingdom belongs to Allah, and all praise is due to Allah. There is no god but Allah alone, with no partner',
          duaTurkish:
              'Sabah oldu ve mülk Allah\'a aittir, hamd Allah\'a mahsustur, Allah\'tan başka ilah yoktur, O tektir ve ortağı yoktur',
          duaUrdu:
              'ہم صبح کو پہنچ گئے اور بادشاہت اللہ کی ہے، اور تمام تعریف اللہ کے لیے ہے، اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے اور اس کا کوئی شریک نہیں',
          duaBangla:
              'আমরা সকালে পৌঁছেছি এবং রাজত্ব আল্লাহর, এবং সমস্ত প্রশংসা আল্লাহর, আল্লাহ ছাড়া কোন উপাস্য নেই, তিনি একক এবং তাঁর কোন অংশীদার নেই',
          duaHindi:
              'हम सुबह पहुंच गए और राज्य अल्लाह का है, और सभी प्रशंसा अल्लाह के लिए है, अल्लाह के अलावा कोई पूज्य नहीं है, वह अकेला है और उसका कोई साझीदार नहीं है',
          duaFrench:
              'Nous avons atteint le matin et le royaume appartient à Allah, et toute louange est due à Allah, il n\'y a pas d\'autre dieu qu\'Allah seul, sans associé',
          titleArabic: 'أذكار الصباح',
          titleEnglish: 'Morning Adhkar',
          titleTurkish: 'Sabah Zikirleri',
          titleUrdu: 'صبح کے اذکار',
          titleBangla: 'সকালের জিকির',
          titleHindi: 'सुबह की जिक्र',
          titleFrench: 'Dhikr du Matin',
          categoryId: '1',
          timestamp: DateTime.now().toIso8601String(),
          categoryArabic: 'أذكار الصباح',
          categoryEnglish: 'Morning Adhkar',
          categoryTurkish: 'Sabah Zikirleri',
          categoryUrdu: 'صبح کے اذکار',
          categoryBangla: 'সকালের জিকির',
          categoryHindi: 'सुबह की जिक्र',
          categoryFrench: 'Dhikr du Matin',
        ),
      ],
      '2': [
        // Evening Adhkar
        DuaModel(
          id: '2',
          duaArabic:
              'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
          duaEnglish:
              'We have reached the evening and the kingdom belongs to Allah, and all praise is due to Allah. There is no god but Allah alone, with no partner',
          duaTurkish:
              'Akşam oldu ve mülk Allah\'a aittir, hamd Allah\'a mahsustur, Allah\'tan başka ilah yoktur, O tektir ve ortağı yoktur',
          duaUrdu:
              'ہم شام کو پہنچ گئے اور بادشاہت اللہ کی ہے، اور تمام تعریف اللہ کے لیے ہے، اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے اور اس کا کوئی شریک نہیں',
          duaBangla:
              'আমরা সন্ধ্যায় পৌঁছেছি এবং রাজত্ব আল্লাহর, এবং সমস্ত প্রশংসা আল্লাহর, আল্লাহ ছাড়া কোন উপাস্য নেই, তিনি একক এবং তাঁর কোন অংশীদার নেই',
          duaHindi:
              'हम शाम पहुंच गए और राज्य अल्लाह का है, और सभी प्रशंसा अल्लाह के लिए है, अल्लाह के अलावा कोई पूज्य नहीं है, वह अकेला है और उसका कोई साझीदार नहीं है',
          duaFrench:
              'Nous avons atteint le soir et le royaume appartient à Allah, et toute louange est due à Allah, il n\'y a pas d\'autre dieu qu\'Allah seul, sans associé',
          titleArabic: 'أذكار المساء',
          titleEnglish: 'Evening Adhkar',
          titleTurkish: 'Akşam Zikirleri',
          titleUrdu: 'شام کے اذکار',
          titleBangla: 'সন্ধ্যার জিকির',
          titleHindi: 'शाम की जिक्र',
          titleFrench: 'Dhikr du Soir',
          categoryId: '2',
          timestamp: DateTime.now().toIso8601String(),
          categoryArabic: 'أذكار المساء',
          categoryEnglish: 'Evening Adhkar',
          categoryTurkish: 'Akşam Zikirleri',
          categoryUrdu: 'شام کے اذکار',
          categoryBangla: 'সন্ধ্যার জিকির',
          categoryHindi: 'शाम की जिक्र',
          categoryFrench: 'Dhikr du Soir',
        ),
      ],
      '3': [
        // Travel Duas
        DuaModel(
          id: '3',
          duaArabic:
              'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَى رَبِّنَا لَمُنقَلِبُونَ',
          duaEnglish:
              'Glory to Him who has subjected this to us, and we could not have done it by ourselves. And indeed, to our Lord we will return',
          duaTurkish:
              'Bunu bize boyun eğdiren ve biz bunu kendimiz yapamayacakken yapan Allah\'a hamd olsun. Şüphesiz biz Rabbimize döneceğiz',
          duaUrdu:
              'اس کی تعریف ہے جس نے یہ ہمارے لیے مسخر کیا اور ہم اسے خود نہیں کر سکتے تھے، اور بے شک ہم اپنے رب کی طرف لوٹنے والے ہیں',
          duaBangla:
              'যিনি এটা আমাদের জন্য বশীভূত করেছেন তাঁর প্রশংসা, এবং আমরা এটা নিজেরা করতে পারতাম না, এবং নিশ্চয়ই আমরা আমাদের প্রভুর কাছে ফিরে যাব',
          duaHindi:
              'उसकी प्रशंसा है जिसने इसे हमारे लिए वश में किया और हम इसे स्वयं नहीं कर सकते थे, और निश्चित रूप से हम अपने रब की ओर लौटने वाले हैं',
          duaFrench:
              'Gloire à Celui qui nous a soumis cela et nous n\'aurions pas pu le faire nous-mêmes. Et en effet, nous retournerons vers notre Seigneur',
          titleArabic: 'دعاء السفر',
          titleEnglish: 'Travel Dua',
          titleTurkish: 'Seyahat Duası',
          titleUrdu: 'سفر کی دعا',
          titleBangla: 'ভ্রমণের দোয়া',
          titleHindi: 'यात्रा की दुआ',
          titleFrench: 'Dua de Voyage',
          categoryId: '3',
          timestamp: DateTime.now().toIso8601String(),
          categoryArabic: 'أدعية السفر',
          categoryEnglish: 'Travel Duas',
          categoryTurkish: 'Seyahat Duaları',
          categoryUrdu: 'سفر کی دعائیں',
          categoryBangla: 'ভ্রমণের দোয়া',
          categoryHindi: 'यात्रा की दुआ',
          categoryFrench: 'Duas de Voyage',
        ),
      ],
    };

    return sampleDuas[categoryId] ??
        [
          DuaModel(
            id: 'default',
            duaArabic:
                'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
            duaEnglish:
                'Glory to Allah and praise to Him, Glory to Allah the Great',
            duaTurkish: 'Allah\'a hamd ve övgü olsun, Yüce Allah\'a hamd olsun',
            duaUrdu: 'اللہ کی تعریف اور اس کی حمد، عظیم اللہ کی تعریف',
            duaBangla: 'আল্লাহর প্রশংসা এবং তাঁর হামদ, মহান আল্লাহর প্রশংসা',
            duaHindi: 'अल्लाह की प्रशंसा और उसकी हम्द, महान अल्लाह की प्रशंसा',
            duaFrench:
                'Gloire à Allah et louange à Lui, Gloire à Allah le Grand',
            titleArabic: 'تسبيح',
            titleEnglish: 'Tasbih',
            titleTurkish: 'Tesbih',
            titleUrdu: 'تسبیح',
            titleBangla: 'তাসবিহ',
            titleHindi: 'तस्बीह',
            titleFrench: 'Tasbih',
            categoryId: categoryId,
            timestamp: DateTime.now().toIso8601String(),
            categoryArabic: 'عام',
            categoryEnglish: 'General',
            categoryTurkish: 'Genel',
            categoryUrdu: 'عام',
            categoryBangla: 'সাধারণ',
            categoryHindi: 'सामान्य',
            categoryFrench: 'Général',
          ),
        ];
  }
}
