import 'package:equatable/equatable.dart';

abstract class QuranEvent extends Equatable {
  const QuranEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuranData extends QuranEvent {
  const LoadQuranData();
}

class SearchQuran extends QuranEvent {
  final String query;

  const SearchQuran({required this.query});

  @override
  List<Object?> get props => [query];
}

class LoadBookmarks extends QuranEvent {
  const LoadBookmarks();
}

class AddBookmark extends QuranEvent {
  final String surahId;
  final String surahName;
  final int pageNumber;
  final int juzNumber;

  const AddBookmark({
    required this.surahId,
    required this.surahName,
    required this.pageNumber,
    required this.juzNumber,
  });

  @override
  List<Object?> get props => [surahId, surahName, pageNumber, juzNumber];
}

class RemoveBookmark extends QuranEvent {
  final String bookmarkId;

  const RemoveBookmark({required this.bookmarkId});

  @override
  List<Object?> get props => [bookmarkId];
}
