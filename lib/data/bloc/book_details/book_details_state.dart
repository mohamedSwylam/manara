import 'package:equatable/equatable.dart';

abstract class BookDetailsState extends Equatable {
  const BookDetailsState();
  
  @override
  List<Object?> get props => [];
}

class BookDetailsInitial extends BookDetailsState {}

class BookDetailsLoading extends BookDetailsState {}

class BookDetailsLoaded extends BookDetailsState {
  final String bookName;
  final List<BookChapter> chapters;
  final List<BookBookmark> bookmarks;
  final String? searchQuery;
  final List<BookChapter> originalChapters; // Store original data
  
  const BookDetailsLoaded({
    required this.bookName,
    required this.chapters,
    required this.bookmarks,
    this.searchQuery,
    required this.originalChapters,
  });
  
  @override
  List<Object?> get props => [bookName, chapters, bookmarks, searchQuery, originalChapters];
  
  BookDetailsLoaded copyWith({
    String? bookName,
    List<BookChapter>? chapters,
    List<BookBookmark>? bookmarks,
    String? searchQuery,
    List<BookChapter>? originalChapters,
  }) {
    return BookDetailsLoaded(
      bookName: bookName ?? this.bookName,
      chapters: chapters ?? this.chapters,
      bookmarks: bookmarks ?? this.bookmarks,
      searchQuery: searchQuery ?? this.searchQuery,
      originalChapters: originalChapters ?? this.originalChapters,
    );
  }
}

class BookDetailsError extends BookDetailsState {
  final String message;
  
  const BookDetailsError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Data Models
class BookChapter {
  final String id;
  final String name;
  final int chapterNumber;
  final int pageStart;
  final int pageEnd;
  
  const BookChapter({
    required this.id,
    required this.name,
    required this.chapterNumber,
    required this.pageStart,
    required this.pageEnd,
  });
}

class BookBookmark {
  final String id;
  final String chapterId;
  final String chapterName;
  final String bookName;
  final int chapterNumber;
  final int pageStart;
  final int pageEnd;
  
  const BookBookmark({
    required this.id,
    required this.chapterId,
    required this.chapterName,
    required this.bookName,
    required this.chapterNumber,
    required this.pageStart,
    required this.pageEnd,
  });
}
