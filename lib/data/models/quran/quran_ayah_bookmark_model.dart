import 'package:hive/hive.dart';

part 'quran_ayah_bookmark_model.g.dart';

@HiveType(typeId: 2)
class QuranAyahBookmarkModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String surahId;

  @HiveField(2)
  final String surahName;

  @HiveField(3)
  final int surahNumber;

  @HiveField(4)
  final int ayahNumber;

  @HiveField(5)
  final String ayahText;

  @HiveField(6)
  final String ayahTranslation;

  @HiveField(7)
  final int pageNumber;

  @HiveField(8)
  final int juzNumber;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final BookmarkType type;

  @HiveField(11)
  final String? note;

  @HiveField(12)
  final double? scrollPosition;

  QuranAyahBookmarkModel({
    required this.id,
    required this.surahId,
    required this.surahName,
    required this.surahNumber,
    required this.ayahNumber,
    required this.ayahText,
    required this.ayahTranslation,
    required this.pageNumber,
    required this.juzNumber,
    required this.createdAt,
    required this.type,
    this.note,
    this.scrollPosition,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surahId': surahId,
      'surahName': surahName,
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'ayahText': ayahText,
      'ayahTranslation': ayahTranslation,
      'pageNumber': pageNumber,
      'juzNumber': juzNumber,
      'createdAt': createdAt.toIso8601String(),
      'type': type.toString(),
      'note': note,
      'scrollPosition': scrollPosition,
    };
  }

  factory QuranAyahBookmarkModel.fromJson(Map<String, dynamic> json) {
    return QuranAyahBookmarkModel(
      id: json['id'] ?? '',
      surahId: json['surahId'] ?? '',
      surahName: json['surahName'] ?? '',
      surahNumber: json['surahNumber'] ?? 0,
      ayahNumber: json['ayahNumber'] ?? 0,
      ayahText: json['ayahText'] ?? '',
      ayahTranslation: json['ayahTranslation'] ?? '',
      pageNumber: json['pageNumber'] ?? 0,
      juzNumber: json['juzNumber'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      type: BookmarkType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => BookmarkType.page,
      ),
      note: json['note'],
      scrollPosition: json['scrollPosition']?.toDouble(),
    );
  }
}

@HiveType(typeId: 3)
enum BookmarkType {
  @HiveField(0)
  page,
  @HiveField(1)
  ayah,
}
