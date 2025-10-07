import 'package:equatable/equatable.dart';

abstract class HadithState extends Equatable {
  const HadithState();
  
  @override
  List<Object?> get props => [];
}

class HadithInitial extends HadithState {}

class HadithLoading extends HadithState {}

class HadithLoaded extends HadithState {
  final List<HadithBook> books;
  final List<HadithCollection> collection;
  final List<Bookmark> bookmarks;
  final String? searchQuery;
  final List<HadithCollection> originalCollection; // Store original data
  
  const HadithLoaded({
    required this.books,
    required this.collection,
    required this.bookmarks,
    this.searchQuery,
    required this.originalCollection,
  });
  
  @override
  List<Object?> get props => [books, collection, bookmarks, searchQuery, originalCollection];
  
  HadithLoaded copyWith({
    List<HadithBook>? books,
    List<HadithCollection>? collection,
    List<Bookmark>? bookmarks,
    String? searchQuery,
    List<HadithCollection>? originalCollection,
  }) {
    return HadithLoaded(
      books: books ?? this.books,
      collection: collection ?? this.collection,
      bookmarks: bookmarks ?? this.bookmarks,
      searchQuery: searchQuery ?? this.searchQuery,
      originalCollection: originalCollection ?? this.originalCollection,
    );
  }
}

class HadithError extends HadithState {
  final String message;
  
  const HadithError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Data Models
class HadithBook {
  final String id;
  final String title;
  final String type;
  final int count;
  final String lastRead;
  
  const HadithBook({
    required this.id,
    required this.title,
    required this.type,
    required this.count,
    required this.lastRead,
  });
}

class HadithCollection {
  final String id;
  final String title;
  final String description;
  final String bookImage;
  final String bookTitle;
  
  const HadithCollection({
    required this.id,
    required this.title,
    required this.description,
    required this.bookImage,
    required this.bookTitle,
  });
}

class Bookmark {
  final String id;
  final String hadithId;
  final String bookTitle;
  final String lessonName;
  final int lessonNumber;
  final int chapterNumber;
  
  const Bookmark({
    required this.id,
    required this.hadithId,
    required this.bookTitle,
    required this.lessonName,
    required this.lessonNumber,
    required this.chapterNumber,
  });
}
