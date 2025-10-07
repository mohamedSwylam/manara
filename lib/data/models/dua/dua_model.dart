class DuaModel {
  final String id;
  final String duaArabic;
  final String duaEnglish;
  final String duaTurkish;
  final String duaUrdu;
  final String duaBangla;
  final String duaHindi;
  final String duaFrench;
  final String titleArabic;
  final String titleEnglish;
  final String titleTurkish;
  final String titleUrdu;
  final String titleBangla;
  final String titleHindi;
  final String titleFrench;
  final String categoryId;
  final String timestamp;
  final String categoryArabic;
  final String categoryEnglish;
  final String categoryTurkish;
  final String categoryUrdu;
  final String categoryBangla;
  final String categoryHindi;
  final String categoryFrench;

  DuaModel({
    required this.id,
    required this.duaArabic,
    required this.duaEnglish,
    required this.duaTurkish,
    required this.duaUrdu,
    required this.duaBangla,
    required this.duaHindi,
    required this.duaFrench,
    required this.titleArabic,
    required this.titleEnglish,
    required this.titleTurkish,
    required this.titleUrdu,
    required this.titleBangla,
    required this.titleHindi,
    required this.titleFrench,
    required this.categoryId,
    required this.timestamp,
    required this.categoryArabic,
    required this.categoryEnglish,
    required this.categoryTurkish,
    required this.categoryUrdu,
    required this.categoryBangla,
    required this.categoryHindi,
    required this.categoryFrench,
  });

  factory DuaModel.fromJson(Map<String, dynamic> json) {
    return DuaModel(
      id: json['_id'] ?? '',
      duaArabic: json['duaArabic'] ?? '',
      duaEnglish: json['duaEnglish'] ?? '',
      duaTurkish: json['duaTurkish'] ?? '',
      duaUrdu: json['duaUrdu'] ?? '',
      duaBangla: json['duaBangla'] ?? '',
      duaHindi: json['duaHindi'] ?? '',
      duaFrench: json['duaFrench'] ?? '',
      titleArabic: json['titleArabic'] ?? '',
      titleEnglish: json['titleEnglish'] ?? '',
      titleTurkish: json['titleTurkish'] ?? '',
      titleUrdu: json['titleUrdu'] ?? '',
      titleBangla: json['titleBangla'] ?? '',
      titleHindi: json['titleHindi'] ?? '',
      titleFrench: json['titleFrench'] ?? '',
      categoryId: json['category_id'] ?? '',
      timestamp: json['timestamp'] ?? '',
      categoryArabic: json['categoryArabic'] ?? '',
      categoryEnglish: json['categoryEnglish'] ?? '',
      categoryTurkish: json['categoryTurkish'] ?? '',
      categoryUrdu: json['categoryUrdu'] ?? '',
      categoryBangla: json['categoryBangla'] ?? '',
      categoryHindi: json['categoryHindi'] ?? '',
      categoryFrench: json['categoryFrench'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'duaArabic': duaArabic,
      'duaEnglish': duaEnglish,
      'duaTurkish': duaTurkish,
      'duaUrdu': duaUrdu,
      'duaBangla': duaBangla,
      'duaHindi': duaHindi,
      'duaFrench': duaFrench,
      'titleArabic': titleArabic,
      'titleEnglish': titleEnglish,
      'titleTurkish': titleTurkish,
      'titleUrdu': titleUrdu,
      'titleBangla': titleBangla,
      'titleHindi': titleHindi,
      'titleFrench': titleFrench,
      'category_id': categoryId,
      'timestamp': timestamp,
      'categoryArabic': categoryArabic,
      'categoryEnglish': categoryEnglish,
      'categoryTurkish': categoryTurkish,
      'categoryUrdu': categoryUrdu,
      'categoryBangla': categoryBangla,
      'categoryHindi': categoryHindi,
      'categoryFrench': categoryFrench,
    };
  }

  // Helper method to get dua text based on current locale
  String getDuaText(String locale) {
    switch (locale.toLowerCase()) {
      case 'ar':
        return duaArabic;
      case 'tr':
        return duaTurkish;
      case 'ur':
        return duaUrdu;
      case 'bn':
        return duaBangla != 'N/A' ? duaBangla : duaEnglish;
      case 'hi':
        return duaHindi != 'N/A' ? duaHindi : duaEnglish;
      case 'fr':
        return duaFrench != 'N/A' ? duaFrench : duaEnglish;
      default:
        return duaEnglish;
    }
  }

  // Helper method to get title based on current locale
  String getTitle(String locale) {
    switch (locale.toLowerCase()) {
      case 'ar':
        return titleArabic;
      case 'tr':
        return titleTurkish;
      case 'ur':
        return titleUrdu;
      case 'bn':
        return titleBangla != 'N/A' ? titleBangla : titleEnglish;
      case 'hi':
        return titleHindi != 'N/A' ? titleHindi : titleEnglish;
      case 'fr':
        return titleFrench != 'N/A' ? titleFrench : titleEnglish;
      default:
        return titleEnglish;
    }
  }
}
