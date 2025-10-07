import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

import 'book_details_event.dart';
import 'book_details_state.dart';

class BookDetailsBloc extends Bloc<BookDetailsEvent, BookDetailsState> {
  final Uuid _uuid = const Uuid();
  
  BookDetailsBloc() : super(BookDetailsInitial()) {
    on<LoadBookDetails>(_onLoadBookDetails);
    on<LoadBookChapters>(_onLoadBookChapters);
    on<LoadBookBookmarks>(_onLoadBookBookmarks);
    on<SearchBookChapters>(_onSearchBookChapters);
    on<AddBookBookmark>(_onAddBookBookmark);
    on<RemoveBookBookmark>(_onRemoveBookBookmark);
  }

  Future<void> _onLoadBookDetails(
    LoadBookDetails event,
    Emitter<BookDetailsState> emit,
  ) async {
    emit(BookDetailsLoading());
    
    try {
      // Simulate API call - replace with actual service call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final chapters = [
        const BookChapter(
          id: '1',
          name: 'The Book of Faith',
          chapterNumber: 1,
          pageStart: 1,
          pageEnd: 7,
        ),
        const BookChapter(
          id: '2',
          name: 'The Book of Knowledge',
          chapterNumber: 2,
          pageStart: 8,
          pageEnd: 15,
        ),
        const BookChapter(
          id: '3',
          name: 'The Book of Prayer',
          chapterNumber: 3,
          pageStart: 16,
          pageEnd: 25,
        ),
        const BookChapter(
          id: '4',
          name: 'The Book of Good Manners',
          chapterNumber: 4,
          pageStart: 26,
          pageEnd: 35,
        ),
        const BookChapter(
          id: '5',
          name: 'The Book of Fasting',
          chapterNumber: 5,
          pageStart: 36,
          pageEnd: 45,
        ),
        const BookChapter(
          id: '6',
          name: 'The Book of Hajj',
          chapterNumber: 6,
          pageStart: 46,
          pageEnd: 55,
        ),
      ];
      
             emit(BookDetailsLoaded(
         bookName: event.bookName,
         chapters: chapters,
         bookmarks: [],
         originalChapters: chapters,
       ));
    } catch (e) {
      emit(BookDetailsError(e.toString()));
    }
  }

  Future<void> _onLoadBookChapters(
    LoadBookChapters event,
    Emitter<BookDetailsState> emit,
  ) async {
    try {
      // Simulate API call - replace with actual service call
      await Future.delayed(const Duration(milliseconds: 300));
      
      final currentState = state;
      if (currentState is BookDetailsLoaded) {
        // Chapters are already loaded in LoadBookDetails
        emit(currentState);
      }
    } catch (e) {
      emit(BookDetailsError(e.toString()));
    }
  }

  Future<void> _onLoadBookBookmarks(
    LoadBookBookmarks event,
    Emitter<BookDetailsState> emit,
  ) async {
    try {
      // Simulate API call - replace with actual service call
      await Future.delayed(const Duration(milliseconds: 300));
      
      final bookmarks = [
        BookBookmark(
          id: '1',
          chapterId: '1',
          chapterName: 'The Book of Faith',
          bookName: 'Sahih al-Bukhari',
          chapterNumber: 1,
          pageStart: 1,
          pageEnd: 7,
        ),
        BookBookmark(
          id: '2',
          chapterId: '3',
          chapterName: 'The Book of Prayer',
          bookName: 'Sahih al-Bukhari',
          chapterNumber: 3,
          pageStart: 16,
          pageEnd: 25,
        ),
      ];
      
      final currentState = state;
      if (currentState is BookDetailsLoaded) {
        emit(currentState.copyWith(bookmarks: bookmarks));
      }
    } catch (e) {
      emit(BookDetailsError(e.toString()));
    }
  }

  Future<void> _onSearchBookChapters(
    SearchBookChapters event,
    Emitter<BookDetailsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is BookDetailsLoaded) {
        // If search query is empty, restore original chapters
        if (event.query.isEmpty) {
          emit(currentState.copyWith(
            chapters: currentState.originalChapters,
            searchQuery: event.query,
          ));
        } else {
          // Filter from original chapters based on search query
          final filteredChapters = currentState.originalChapters
              .where((chapter) => 
                  chapter.name.toLowerCase().contains(event.query.toLowerCase()) ||
                  chapter.chapterNumber.toString().contains(event.query))
              .toList();
          
          emit(currentState.copyWith(
            chapters: filteredChapters,
            searchQuery: event.query,
          ));
        }
      }
    } catch (e) {
      emit(BookDetailsError(e.toString()));
    }
  }

  Future<void> _onAddBookBookmark(
    AddBookBookmark event,
    Emitter<BookDetailsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is BookDetailsLoaded) {
        final newBookmark = BookBookmark(
          id: _uuid.v4(),
          chapterId: event.chapterId,
          chapterName: event.chapterName,
          bookName: event.bookName,
          chapterNumber: event.chapterNumber,
          pageStart: event.pageStart,
          pageEnd: event.pageEnd,
        );
        
        final updatedBookmarks = List<BookBookmark>.from(currentState.bookmarks)
          ..add(newBookmark);
        
        emit(currentState.copyWith(bookmarks: updatedBookmarks));
      }
    } catch (e) {
      emit(BookDetailsError(e.toString()));
    }
  }

  Future<void> _onRemoveBookBookmark(
    RemoveBookBookmark event,
    Emitter<BookDetailsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is BookDetailsLoaded) {
        final updatedBookmarks = currentState.bookmarks
            .where((bookmark) => bookmark.id != event.bookmarkId)
            .toList();
        
        emit(currentState.copyWith(bookmarks: updatedBookmarks));
      }
    } catch (e) {
      emit(BookDetailsError(e.toString()));
    }
  }
}
