import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

import 'hadith_event.dart';
import 'hadith_state.dart';

class HadithBloc extends Bloc<HadithEvent, HadithState> {
  final Uuid _uuid = const Uuid();
  
  HadithBloc() : super(HadithInitial()) {
    on<LoadHadithBooks>(_onLoadHadithBooks);
    on<LoadHadithCollection>(_onLoadHadithCollection);
    on<LoadBookmarks>(_onLoadBookmarks);
    on<AddBookmark>(_onAddBookmark);
    on<RemoveBookmark>(_onRemoveBookmark);
    on<SearchHadith>(_onSearchHadith);
  }

  Future<void> _onLoadHadithBooks(
    LoadHadithBooks event,
    Emitter<HadithState> emit,
  ) async {
    emit(HadithLoading());
    
    try {
      // Simulate API call - replace with actual service call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final books = [
        HadithBook(
          id: '1',
          title: 'Sahih al-Bukhari',
          type: 'revelation'.tr,
          count: 1,
          lastRead: 'LAST READ',
        ),
        HadithBook(
          id: '2',
          title: 'Sahih Muslim',
          type: 'knowledge'.tr,
          count: 59,
          lastRead: 'LAST BOOKMARK',
        ),
        HadithBook(
          id: '3',
          title: 'Abu Dawud',
          type: 'belief'.tr,
          count: 23,
          lastRead: 'LAST READ',
        ),
        HadithBook(
          id: '4',
          title: 'Tirmidhi',
          type: 'prayer'.tr,
          count: 45,
          lastRead: 'LAST BOOKMARK',
        ),
      ];
      
             emit(HadithLoaded(
         books: books,
         collection: [],
         bookmarks: [],
         originalCollection: [],
       ));
    } catch (e) {
      emit(HadithError(e.toString()));
    }
  }

  Future<void> _onLoadHadithCollection(
    LoadHadithCollection event,
    Emitter<HadithState> emit,
  ) async {
    try {
      // Simulate API call - replace with actual service call
      await Future.delayed(const Duration(milliseconds: 300));
      
      final collection = [
        const HadithCollection(
          id: '1',
          title: 'The Book of Faith',
          description: 'Narrated Abu Huraira: The Prophet said, "Faith has over seventy branches..."',
          bookImage: 'assets/images/hadith_book_1.png',
          bookTitle: 'Sahih al-Bukhari',
        ),
        const HadithCollection(
          id: '2',
          title: 'The Book of Knowledge',
          description: 'Narrated Anas: The Prophet said, "Seeking knowledge is obligatory..."',
          bookImage: 'assets/images/hadith_book_2.png',
          bookTitle: 'Sahih Muslim',
        ),
        const HadithCollection(
          id: '3',
          title: 'The Book of Prayer',
          description: 'Narrated Abu Huraira: The Prophet said, "The first thing for which..."',
          bookImage: 'assets/images/hadith_book_3.png',
          bookTitle: 'Abu Dawud',
        ),
        const HadithCollection(
          id: '4',
          title: 'The Book of Good Manners',
          description: 'Narrated Abu Huraira: The Prophet said, "The most perfect believer..."',
          bookImage: 'assets/images/hadith_book_4.png',
          bookTitle: 'Tirmidhi',
        ),
      ];
      
             final currentState = state;
       if (currentState is HadithLoaded) {
         emit(currentState.copyWith(
           collection: collection,
           originalCollection: collection, // Store original data
           searchQuery: event.searchQuery,
         ));
       }
    } catch (e) {
      emit(HadithError(e.toString()));
    }
  }

  Future<void> _onLoadBookmarks(
    LoadBookmarks event,
    Emitter<HadithState> emit,
  ) async {
    try {
      // Simulate API call - replace with actual service call
      await Future.delayed(const Duration(milliseconds: 300));
      
      final bookmarks = [
        Bookmark(
          id: '1',
          hadithId: '1',
          bookTitle: 'Sahih al-Bukhari',
          lessonName: 'belief'.tr,
          lessonNumber: 2,
          chapterNumber: 15,
        ),
        Bookmark(
          id: '2',
          hadithId: '2',
          bookTitle: 'Sahih Muslim',
          lessonName: 'knowledge'.tr,
          lessonNumber: 5,
          chapterNumber: 8,
        ),
        Bookmark(
          id: '3',
          hadithId: '3',
          bookTitle: 'Abu Dawud',
          lessonName: 'prayer'.tr,
          lessonNumber: 1,
          chapterNumber: 12,
        ),
      ];
      
      final currentState = state;
      if (currentState is HadithLoaded) {
        emit(currentState.copyWith(bookmarks: bookmarks));
      }
    } catch (e) {
      emit(HadithError(e.toString()));
    }
  }

  Future<void> _onAddBookmark(
    AddBookmark event,
    Emitter<HadithState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is HadithLoaded) {
        final newBookmark = Bookmark(
          id: _uuid.v4(),
          hadithId: event.hadithId,
          bookTitle: event.bookTitle,
          lessonName: event.lessonName,
          lessonNumber: event.lessonNumber,
          chapterNumber: event.chapterNumber,
        );
        
        final updatedBookmarks = List<Bookmark>.from(currentState.bookmarks)
          ..add(newBookmark);
        
        emit(currentState.copyWith(bookmarks: updatedBookmarks));
      }
    } catch (e) {
      emit(HadithError(e.toString()));
    }
  }

  Future<void> _onRemoveBookmark(
    RemoveBookmark event,
    Emitter<HadithState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is HadithLoaded) {
        final updatedBookmarks = currentState.bookmarks
            .where((bookmark) => bookmark.id != event.bookmarkId)
            .toList();
        
        emit(currentState.copyWith(bookmarks: updatedBookmarks));
      }
    } catch (e) {
      emit(HadithError(e.toString()));
    }
  }

  Future<void> _onSearchHadith(
    SearchHadith event,
    Emitter<HadithState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is HadithLoaded) {
        // If search query is empty, restore original collection
        if (event.query.isEmpty) {
          emit(currentState.copyWith(
            collection: currentState.originalCollection,
            searchQuery: event.query,
          ));
        } else {
          // Filter from original collection based on search query
          final filteredCollection = currentState.originalCollection
              .where((hadith) => 
                  hadith.title.toLowerCase().contains(event.query.toLowerCase()) ||
                  hadith.description.toLowerCase().contains(event.query.toLowerCase()) ||
                  hadith.bookTitle.toLowerCase().contains(event.query.toLowerCase()))
              .toList();
          
          emit(currentState.copyWith(
            collection: filteredCollection,
            searchQuery: event.query,
          ));
        }
      }
    } catch (e) {
      emit(HadithError(e.toString()));
    }
  }
}
