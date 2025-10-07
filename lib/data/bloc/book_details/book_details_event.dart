import 'package:equatable/equatable.dart';

abstract class BookDetailsEvent extends Equatable {
  const BookDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadBookDetails extends BookDetailsEvent {
  final String bookId;
  final String bookName;
  
  const LoadBookDetails({
    required this.bookId,
    required this.bookName,
  });
  
  @override
  List<Object?> get props => [bookId, bookName];
}

class LoadBookChapters extends BookDetailsEvent {
  final String bookId;
  
  const LoadBookChapters({required this.bookId});
  
  @override
  List<Object?> get props => [bookId];
}

class LoadBookBookmarks extends BookDetailsEvent {
  final String bookId;
  
  const LoadBookBookmarks({required this.bookId});
  
  @override
  List<Object?> get props => [bookId];
}

class SearchBookChapters extends BookDetailsEvent {
  final String query;
  final String bookName;
  
  const SearchBookChapters({
    required this.query,
    required this.bookName,
  });
  
  @override
  List<Object?> get props => [query, bookName];
}

class AddBookBookmark extends BookDetailsEvent {
  final String chapterId;
  final String chapterName;
  final String bookName;
  final int chapterNumber;
  final int pageStart;
  final int pageEnd;
  
  const AddBookBookmark({
    required this.chapterId,
    required this.chapterName,
    required this.bookName,
    required this.chapterNumber,
    required this.pageStart,
    required this.pageEnd,
  });
  
  @override
  List<Object?> get props => [chapterId, chapterName, bookName, chapterNumber, pageStart, pageEnd];
}

class RemoveBookBookmark extends BookDetailsEvent {
  final String bookmarkId;
  
  const RemoveBookBookmark({required this.bookmarkId});
  
  @override
  List<Object?> get props => [bookmarkId];
}
