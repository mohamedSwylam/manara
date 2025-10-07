import 'package:equatable/equatable.dart';
import '../../models/quran/quran_ayah_bookmark_model.dart';

abstract class BookmarkEvent extends Equatable {
  const BookmarkEvent();

  @override
  List<Object?> get props => [];
}

class LoadBookmarks extends BookmarkEvent {}

class AddPageBookmark extends BookmarkEvent {
  final String surahId;
  final String surahName;
  final int surahNumber;
  final int pageNumber;
  final int juzNumber;
  final String? note;

  const AddPageBookmark({
    required this.surahId,
    required this.surahName,
    required this.surahNumber,
    required this.pageNumber,
    required this.juzNumber,
    this.note,
  });

  @override
  List<Object?> get props => [surahId, surahName, surahNumber, pageNumber, juzNumber, note];
}

class AddAyahBookmark extends BookmarkEvent {
  final String surahId;
  final String surahName;
  final int surahNumber;
  final int ayahNumber;
  final String ayahText;
  final String ayahTranslation;
  final int pageNumber;
  final int juzNumber;
  final String? note;
  final double? scrollPosition;

  const AddAyahBookmark({
    required this.surahId,
    required this.surahName,
    required this.surahNumber,
    required this.ayahNumber,
    required this.ayahText,
    required this.ayahTranslation,
    required this.pageNumber,
    required this.juzNumber,
    this.note,
    this.scrollPosition,
  });

  @override
  List<Object?> get props => [
    surahId, 
    surahName, 
    surahNumber, 
    ayahNumber, 
    ayahText, 
    ayahTranslation, 
    pageNumber, 
    juzNumber, 
    note,
    scrollPosition,
  ];
}

class RemoveBookmark extends BookmarkEvent {
  final String bookmarkId;

  const RemoveBookmark({required this.bookmarkId});

  @override
  List<Object?> get props => [bookmarkId];
}

class CheckBookmarkStatus extends BookmarkEvent {
  final String surahId;
  final int? ayahNumber;

  const CheckBookmarkStatus({
    required this.surahId,
    this.ayahNumber,
  });

  @override
  List<Object?> get props => [surahId, ayahNumber];
}
