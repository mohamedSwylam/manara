import 'package:hive/hive.dart';

part 'quran_bookmark_model.g.dart';

@HiveType(typeId: 1)
class QuranBookmarkModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String surahId;

  @HiveField(2)
  final String surahName;

  @HiveField(3)
  final int pageNumber;

  @HiveField(4)
  final int juzNumber;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final String? note;

  QuranBookmarkModel({
    required this.id,
    required this.surahId,
    required this.surahName,
    required this.pageNumber,
    required this.juzNumber,
    required this.createdAt,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surahId': surahId,
      'surahName': surahName,
      'pageNumber': pageNumber,
      'juzNumber': juzNumber,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }

  factory QuranBookmarkModel.fromJson(Map<String, dynamic> json) {
    return QuranBookmarkModel(
      id: json['id'] ?? '',
      surahId: json['surahId'] ?? '',
      surahName: json['surahName'] ?? '',
      pageNumber: json['pageNumber'] ?? 0,
      juzNumber: json['juzNumber'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      note: json['note'],
    );
  }
}
