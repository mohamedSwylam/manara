class AzkarCategoryModel {
  final String id;
  final String categoryArabic;
  final String categoryEnglish;
  final String categoryTurkish;
  final String categoryUrdu;
  final String categoryBangla;
  final String categoryHindi;
  final String categoryFrench;
  final String timestamp;

  AzkarCategoryModel({
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

  factory AzkarCategoryModel.fromJson(Map<String, dynamic> json) {
    return AzkarCategoryModel(
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

  String getTitle(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return categoryArabic;
      case 'tr':
        return categoryTurkish;
      case 'ur':
        return categoryUrdu;
      case 'bn':
        return categoryBangla;
      case 'hi':
        return categoryHindi;
      case 'fr':
        return categoryFrench;
      default:
        return categoryEnglish;
    }
  }
}
