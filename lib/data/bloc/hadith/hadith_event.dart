import 'package:equatable/equatable.dart';

abstract class HadithEvent extends Equatable {
  const HadithEvent();

  @override
  List<Object?> get props => [];
}

class LoadHadithBooks extends HadithEvent {}

class LoadHadithCollection extends HadithEvent {
  final String? searchQuery;
  
  const LoadHadithCollection({this.searchQuery});
  
  @override
  List<Object?> get props => [searchQuery];
}

class LoadBookmarks extends HadithEvent {}

class AddBookmark extends HadithEvent {
  final String hadithId;
  final String bookTitle;
  final String lessonName;
  final int lessonNumber;
  final int chapterNumber;
  
  const AddBookmark({
    required this.hadithId,
    required this.bookTitle,
    required this.lessonName,
    required this.lessonNumber,
    required this.chapterNumber,
  });
  
  @override
  List<Object?> get props => [hadithId, bookTitle, lessonName, lessonNumber, chapterNumber];
}

class RemoveBookmark extends HadithEvent {
  final String bookmarkId;
  
  const RemoveBookmark({required this.bookmarkId});
  
  @override
  List<Object?> get props => [bookmarkId];
}

class SearchHadith extends HadithEvent {
  final String query;
  
  const SearchHadith({required this.query});
  
  @override
  List<Object?> get props => [query];
}
