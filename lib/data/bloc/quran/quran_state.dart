import 'package:equatable/equatable.dart';

abstract class QuranState extends Equatable {
  const QuranState();

  @override
  List<Object?> get props => [];
}

class QuranInitial extends QuranState {}

class QuranLoading extends QuranState {}

class QuranLoaded extends QuranState {
  final List<QuranSurah> surahs;
  final List<QuranJuz> juzs;
  final List<QuranBookmark> bookmarks;
  final List<QuranSurah> filteredSurahs;
  final String? lastReadSurah;
  final int? lastReadPage;
  final int? lastReadJuz;
  final String? lastBookmarkSurah;
  final int? lastBookmarkPage;
  final int? lastBookmarkJuz;

  const QuranLoaded({
    required this.surahs,
    required this.juzs,
    required this.bookmarks,
    required this.filteredSurahs,
    this.lastReadSurah,
    this.lastReadPage,
    this.lastReadJuz,
    this.lastBookmarkSurah,
    this.lastBookmarkPage,
    this.lastBookmarkJuz,
  });

  QuranLoaded copyWith({
    List<QuranSurah>? surahs,
    List<QuranJuz>? juzs,
    List<QuranBookmark>? bookmarks,
    List<QuranSurah>? filteredSurahs,
    String? lastReadSurah,
    int? lastReadPage,
    int? lastReadJuz,
    String? lastBookmarkSurah,
    int? lastBookmarkPage,
    int? lastBookmarkJuz,
  }) {
    return QuranLoaded(
      surahs: surahs ?? this.surahs,
      juzs: juzs ?? this.juzs,
      bookmarks: bookmarks ?? this.bookmarks,
      filteredSurahs: filteredSurahs ?? this.filteredSurahs,
      lastReadSurah: lastReadSurah ?? this.lastReadSurah,
      lastReadPage: lastReadPage ?? this.lastReadPage,
      lastReadJuz: lastReadJuz ?? this.lastReadJuz,
      lastBookmarkSurah: lastBookmarkSurah ?? this.lastBookmarkSurah,
      lastBookmarkPage: lastBookmarkPage ?? this.lastBookmarkPage,
      lastBookmarkJuz: lastBookmarkJuz ?? this.lastBookmarkJuz,
    );
  }

  @override
  List<Object?> get props => [
        surahs,
        juzs,
        bookmarks,
        filteredSurahs,
        lastReadSurah,
        lastReadPage,
        lastReadJuz,
        lastBookmarkSurah,
        lastBookmarkPage,
        lastBookmarkJuz,
      ];
}

class QuranError extends QuranState {
  final String message;

  const QuranError(this.message);

  @override
  List<Object?> get props => [message];
}

// Data Models
class QuranSurah extends Equatable {
  final int number;
  final String name;
  final String arabicName;
  final String englishName;
  final String revelationType;
  final int numberOfAyahs;
  final int juz;
  final int page;

  const QuranSurah({
    required this.number,
    required this.name,
    required this.arabicName,
    required this.englishName,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.juz,
    required this.page,
  });

  @override
  List<Object?> get props => [
        number,
        name,
        arabicName,
        englishName,
        revelationType,
        numberOfAyahs,
        juz,
        page,
      ];
}

class QuranJuz extends Equatable {
  final int number;
  final int startPage;
  final int endPage;
  final List<QuranSurah> surahs;
  final List<QuranQuarter> quarters;

  const QuranJuz({
    required this.number,
    required this.startPage,
    required this.endPage,
    required this.surahs,
    required this.quarters,
  });

  @override
  List<Object?> get props => [number, startPage, endPage, surahs, quarters];
}

class QuranQuarter extends Equatable {
  final int juzNumber;
  final int hizbInJuz; // 1 or 2
  final String quarterName; // "1/4", "1/2", "3/4", "End"
  final int surahNumber;
  final String surahName;
  final int startAyah;
  final int pageNumber;

  const QuranQuarter({
    required this.juzNumber,
    required this.hizbInJuz,
    required this.quarterName,
    required this.surahNumber,
    required this.surahName,
    required this.startAyah,
    required this.pageNumber,
  });

  @override
  List<Object?> get props => [juzNumber, hizbInJuz, quarterName, surahNumber, surahName, startAyah, pageNumber];
}

class QuranBookmark extends Equatable {
  final String id;
  final String surahId;
  final String surahName;
  final int pageNumber;
  final int juzNumber;
  final DateTime createdAt;

  const QuranBookmark({
    required this.id,
    required this.surahId,
    required this.surahName,
    required this.pageNumber,
    required this.juzNumber,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        surahId,
        surahName,
        pageNumber,
        juzNumber,
        createdAt,
      ];
}
