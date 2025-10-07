import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import 'bookmark_event.dart';
import 'bookmark_state.dart';
import '../../models/quran/quran_ayah_bookmark_model.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final Uuid _uuid = const Uuid();
  static const String _bookmarkBoxName = 'quran_ayah_bookmarks'; // Changed from 'quran_bookmarks' to avoid conflict

  BookmarkBloc() : super(BookmarkInitial()) {
    on<LoadBookmarks>(_onLoadBookmarks);
    on<AddPageBookmark>(_onAddPageBookmark);
    on<AddAyahBookmark>(_onAddAyahBookmark);
    on<RemoveBookmark>(_onRemoveBookmark);
    on<CheckBookmarkStatus>(_onCheckBookmarkStatus);
  }

  Future<void> _onLoadBookmarks(
    LoadBookmarks event,
    Emitter<BookmarkState> emit,
  ) async {
    // Only show loading if we don't have any bookmarks yet
    if (state is! BookmarkLoaded || (state as BookmarkLoaded).bookmarks.isEmpty) {
      emit(BookmarkLoading());
    }
    
    try {
      print('DEBUG: Loading bookmarks from Hive...');
      final box = await Hive.openBox<QuranAyahBookmarkModel>(_bookmarkBoxName);
      final bookmarks = box.values.toList();
      
      // Sort by creation date (newest first)
      bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      print('DEBUG: Successfully loaded ${bookmarks.length} bookmarks');
      emit(BookmarkLoaded(bookmarks: bookmarks));
    } catch (e) {
      print('ERROR: Failed to load bookmarks: $e');
      print('ERROR: Stack trace: ${StackTrace.current}');
      
      // Don't emit error state, just log to console
      emit(BookmarkLoaded(bookmarks: []));
    }
  }

  Future<void> _onAddPageBookmark(
    AddPageBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      print('DEBUG: Adding page bookmark for surahId: ${event.surahId}, surahName: ${event.surahName}');
      
      final box = await Hive.openBox<QuranAyahBookmarkModel>(_bookmarkBoxName);
      
      // Check if page bookmark already exists
      final existingBookmark = box.values.where((bookmark) =>
        bookmark.surahId == event.surahId &&
        bookmark.type == BookmarkType.page
      ).firstOrNull;

      if (existingBookmark != null) {
        print('DEBUG: Removing existing page bookmark');
        // Remove existing bookmark
        await existingBookmark.delete();
      }

      // Create new page bookmark
      final bookmark = QuranAyahBookmarkModel(
        id: _uuid.v4(),
        surahId: event.surahId,
        surahName: event.surahName,
        surahNumber: event.surahNumber,
        ayahNumber: 0, // Not applicable for page bookmarks
        ayahText: '', // Not applicable for page bookmarks
        ayahTranslation: '', // Not applicable for page bookmarks
        pageNumber: event.pageNumber,
        juzNumber: event.juzNumber,
        createdAt: DateTime.now(),
        type: BookmarkType.page,
        note: event.note,
      );

      await box.add(bookmark);
      print('DEBUG: Successfully added page bookmark with ID: ${bookmark.id}');
      
      // Reload bookmarks
      final bookmarks = box.values.toList();
      bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      emit(BookmarkLoaded(
        bookmarks: bookmarks,
        isPageBookmarked: true,
      ));
    } catch (e) {
      print('ERROR: Failed to add page bookmark: $e');
      print('ERROR: Stack trace: ${StackTrace.current}');
      
      // Don't emit error state, just log to console
      emit(BookmarkLoaded(
        bookmarks: [],
        isPageBookmarked: false,
        isAyahBookmarked: false,
      ));
    }
  }

  Future<void> _onAddAyahBookmark(
    AddAyahBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      print('DEBUG: Adding ayah bookmark for surahId: ${event.surahId}, ayahNumber: ${event.ayahNumber}');
      
      final box = await Hive.openBox<QuranAyahBookmarkModel>(_bookmarkBoxName);
      
      // Check if ayah bookmark already exists
      final existingBookmark = box.values.where((bookmark) =>
        bookmark.surahId == event.surahId &&
        bookmark.ayahNumber == event.ayahNumber &&
        bookmark.type == BookmarkType.ayah
      ).firstOrNull;

      if (existingBookmark != null) {
        print('DEBUG: Removing existing ayah bookmark');
        // Remove existing bookmark
        await existingBookmark.delete();
      }

      // Create new ayah bookmark
      final bookmark = QuranAyahBookmarkModel(
        id: _uuid.v4(),
        surahId: event.surahId,
        surahName: event.surahName,
        surahNumber: event.surahNumber,
        ayahNumber: event.ayahNumber,
        ayahText: event.ayahText,
        ayahTranslation: event.ayahTranslation,
        pageNumber: event.pageNumber,
        juzNumber: event.juzNumber,
        createdAt: DateTime.now(),
        type: BookmarkType.ayah,
        note: event.note,
        scrollPosition: event.scrollPosition,
      );

      await box.add(bookmark);
      print('DEBUG: Successfully added ayah bookmark with ID: ${bookmark.id}');
      
      // Reload bookmarks
      final bookmarks = box.values.toList();
      bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      emit(BookmarkLoaded(
        bookmarks: bookmarks,
        isAyahBookmarked: true,
      ));
    } catch (e) {
      print('ERROR: Failed to add ayah bookmark: $e');
      print('ERROR: Stack trace: ${StackTrace.current}');
      
      // Don't emit error state, just log to console
      emit(BookmarkLoaded(
        bookmarks: [],
        isPageBookmarked: false,
        isAyahBookmarked: false,
      ));
    }
  }

  Future<void> _onRemoveBookmark(
    RemoveBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      print('DEBUG: Removing bookmark with ID: ${event.bookmarkId}');
      
      final box = await Hive.openBox<QuranAyahBookmarkModel>(_bookmarkBoxName);
      
      final bookmark = box.values.where((b) => b.id == event.bookmarkId).firstOrNull;
      if (bookmark != null) {
        await bookmark.delete();
        print('DEBUG: Successfully removed bookmark');
      } else {
        print('DEBUG: Bookmark not found for removal');
      }
      
      // Reload bookmarks
      final bookmarks = box.values.toList();
      bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      emit(BookmarkLoaded(bookmarks: bookmarks));
    } catch (e) {
      print('ERROR: Failed to remove bookmark: $e');
      print('ERROR: Stack trace: ${StackTrace.current}');
      
      // Don't emit error state, just log to console
      emit(BookmarkLoaded(bookmarks: []));
    }
  }

  Future<void> _onCheckBookmarkStatus(
    CheckBookmarkStatus event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      print('DEBUG: Checking bookmark status for surahId: ${event.surahId}, ayahNumber: ${event.ayahNumber}');
      
      final box = await Hive.openBox<QuranAyahBookmarkModel>(_bookmarkBoxName);
      final bookmarks = box.values.toList();
      
      print('DEBUG: Found ${bookmarks.length} total bookmarks');
      
      bool isPageBookmarked = false;
      bool isAyahBookmarked = false;

      if (event.ayahNumber != null) {
        // Check for ayah bookmark
        isAyahBookmarked = bookmarks.any((bookmark) =>
          bookmark.surahId == event.surahId &&
          bookmark.ayahNumber == event.ayahNumber &&
          bookmark.type == BookmarkType.ayah
        );
        print('DEBUG: Ayah bookmark check result: $isAyahBookmarked');
      } else {
        // Check for page bookmark
        isPageBookmarked = bookmarks.any((bookmark) =>
          bookmark.surahId == event.surahId &&
          bookmark.type == BookmarkType.page
        );
        print('DEBUG: Page bookmark check result: $isPageBookmarked');
      }
      
      bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      emit(BookmarkLoaded(
        bookmarks: bookmarks,
        isPageBookmarked: isPageBookmarked,
        isAyahBookmarked: isAyahBookmarked,
      ));
      
      print('DEBUG: Bookmark status check completed successfully');
    } catch (e) {
      print('ERROR: Failed to check bookmark status: $e');
      print('ERROR: Stack trace: ${StackTrace.current}');
      
      // Don't emit error state, just log to console
      // This prevents UI errors from being shown
      emit(BookmarkLoaded(
        bookmarks: [],
        isPageBookmarked: false,
        isAyahBookmarked: false,
      ));
    }
  }
}
