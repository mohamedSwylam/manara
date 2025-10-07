class AzkarModel {
  final String id;
  final String azkarEnglish;
  final String azkarArabic;
  final int repeatCount;
  final String azkarTurkish;
  final String azkarUrdu;
  final String azkarBangla;
  final String azkarHindi;
  final String azkarFrench;
  final String categoryId;
  final String timestamp;
  final String categoryArabic;
  final String categoryEnglish;
  final String categoryTurkish;
  final String categoryUrdu;
  final String categoryBangla;
  final String categoryHindi;
  final String categoryFrench;

  AzkarModel({
    required this.id,
    required this.azkarEnglish,
    required this.azkarArabic,
    required this.repeatCount,
    required this.azkarTurkish,
    required this.azkarUrdu,
    required this.azkarBangla,
    required this.azkarHindi,
    required this.azkarFrench,
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

  factory AzkarModel.fromJson(Map<String, dynamic> json) {
    return AzkarModel(
      id: json['_id'] ?? '',
      azkarEnglish: json['azkarEnglish'] ?? '',
      azkarArabic: json['azkarArabic'] ?? '',
      repeatCount: json['repeat_count'] ?? 0,
      azkarTurkish: json['azkarTurkish'] ?? '',
      azkarUrdu: json['azkarUrdu'] ?? '',
      azkarBangla: json['azkarBangla'] ?? '',
      azkarHindi: json['azkarHindi'] ?? '',
      azkarFrench: json['azkarFrench'] ?? '',
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
      'azkarEnglish': azkarEnglish,
      'azkarArabic': azkarArabic,
      'repeat_count': repeatCount,
      'azkarTurkish': azkarTurkish,
      'azkarUrdu': azkarUrdu,
      'azkarBangla': azkarBangla,
      'azkarHindi': azkarHindi,
      'azkarFrench': azkarFrench,
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

  String getAzkarText(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return azkarArabic;
      case 'tr':
        return azkarTurkish;
      case 'ur':
        return azkarUrdu;
      case 'bn':
        return azkarBangla;
      case 'hi':
        return azkarHindi;
      case 'fr':
        return azkarFrench;
      default:
        return azkarEnglish;
    }
  }
}
