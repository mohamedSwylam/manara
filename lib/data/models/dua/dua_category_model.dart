import 'package:hive/hive.dart';

part 'dua_category_model.g.dart';

@HiveType(typeId: 4)
class DuaCategoryModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String categoryArabic;
  @HiveField(2)
  final String categoryEnglish;
  @HiveField(3)
  final String categoryTurkish;
  @HiveField(4)
  final String categoryUrdu;
  @HiveField(5)
  final String categoryBangla;
  @HiveField(6)
  final String categoryHindi;
  @HiveField(7)
  final String categoryFrench;
  @HiveField(8)
  final String timestamp;

  DuaCategoryModel({
    required this.id,
    required this.categoryArabic,
    required this.categoryEnglish,
    required this.categoryTurkish,
    required this.categoryUrdu,
    required this.categoryBangla,
    required this.categoryHindi,
    required this.categoryFrench,
    required this.timestamp,
  });

  factory DuaCategoryModel.fromJson(Map<String, dynamic> json) {
    return DuaCategoryModel(
      id: json['_id'] ?? '',
      categoryArabic: json['categoryArabic'] ?? '',
      categoryEnglish: json['categoryEnglish'] ?? '',
      categoryTurkish: json['categoryTurkish'] ?? '',
      categoryUrdu: json['categoryUrdu'] ?? '',
      categoryBangla: json['categoryBangla'] ?? '',
      categoryHindi: json['categoryHindi'] ?? '',
      categoryFrench: json['categoryFrench'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'categoryArabic': categoryArabic,
      'categoryEnglish': categoryEnglish,
      'categoryTurkish': categoryTurkish,
      'categoryUrdu': categoryUrdu,
      'categoryBangla': categoryBangla,
      'categoryHindi': categoryHindi,
      'categoryFrench': categoryFrench,
      'timestamp': timestamp,
    };
  }

  // Helper method to get category name based on current locale
  String getCategoryName(String locale) {
    switch (locale.toLowerCase()) {
      case 'ar':
        return categoryArabic;
      case 'tr':
        return categoryTurkish;
      case 'ur':
        return categoryUrdu;
      case 'bn':
        return categoryBangla != 'N/A' ? categoryBangla : categoryEnglish;
      case 'hi':
        return categoryHindi != 'N/A' ? categoryHindi : categoryEnglish;
      case 'fr':
        return categoryFrench != 'N/A' ? categoryFrench : categoryEnglish;
      default:
        return categoryEnglish;
    }
  }
}
