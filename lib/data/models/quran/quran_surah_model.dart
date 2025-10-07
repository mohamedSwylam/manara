import 'package:hive/hive.dart';

part 'quran_surah_model.g.dart';

@HiveType(typeId: 0)
class QuranSurahModel extends HiveObject {
  @HiveField(0)
  final int number;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String arabicName;

  @HiveField(3)
  final String englishName;

  @HiveField(4)
  final String revelationType;

  @HiveField(5)
  final int numberOfAyahs;

  @HiveField(6)
  final int juz;

  @HiveField(7)
  final int page;

  @HiveField(8)
  final String? translation;

  @HiveField(9)
  final String? transliteration;

  @HiveField(10)
  final DateTime lastUpdated;

  QuranSurahModel({
    required this.number,
    required this.name,
    required this.arabicName,
    required this.englishName,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.juz,
    required this.page,
    this.translation,
    this.transliteration,
    required this.lastUpdated,
  });

  factory QuranSurahModel.fromJson(Map<String, dynamic> json) {
    return QuranSurahModel(
      number: json['number'] ?? 0,
      name: json['name'] ?? '', // Direct name field
      arabicName: json['name'] ?? '', // Same as name for Arabic
      englishName: json['englishName'] ?? '', // Direct englishName field
      revelationType: json['revelationType'] ?? '', // Direct revelationType field
      numberOfAyahs: json['numberOfAyahs'] ?? 0,
      juz: json['juz'] ?? 1,
      page: json['page'] ?? 1,
      translation: json['englishNameTranslation'], // Use translation field
      transliteration: json['englishName'], // Use englishName as transliteration
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': {
        'short': name,
        'arabic': arabicName,
        'transliteration': {'en': englishName}, // Changed to transliteration
      },
      'revelation': {'en': revelationType}, // Fixed: use 'en' instead of 'type'
      'numberOfVerses': numberOfAyahs,
      'juz': juz,
      'page': page,
      'translation': translation != null ? {'en': translation} : null,
      'transliteration': transliteration != null ? {'en': transliteration} : null,
    };
  }
}
