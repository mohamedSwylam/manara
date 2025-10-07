import 'package:equatable/equatable.dart';
import '../../models/quran/quran_ayah_bookmark_model.dart';

abstract class BookmarkState extends Equatable {
  const BookmarkState();

  @override
  List<Object?> get props => [];
}

class BookmarkInitial extends BookmarkState {}

class BookmarkLoading extends BookmarkState {}

class BookmarkLoaded extends BookmarkState {
  final List<QuranAyahBookmarkModel> bookmarks;
  final bool isPageBookmarked;
  final bool isAyahBookmarked;

  const BookmarkLoaded({
    required this.bookmarks,
    this.isPageBookmarked = false,
    this.isAyahBookmarked = false,
  });

  @override
  List<Object?> get props => [bookmarks, isPageBookmarked, isAyahBookmarked];

  BookmarkLoaded copyWith({
    List<QuranAyahBookmarkModel>? bookmarks,
    bool? isPageBookmarked,
    bool? isAyahBookmarked,
  }) {
    return BookmarkLoaded(
      bookmarks: bookmarks ?? this.bookmarks,
      isPageBookmarked: isPageBookmarked ?? this.isPageBookmarked,
      isAyahBookmarked: isAyahBookmarked ?? this.isAyahBookmarked,
    );
  }
}

class BookmarkError extends BookmarkState {
  final String message;

  const BookmarkError(this.message);

  @override
  List<Object?> get props => [message];
}
