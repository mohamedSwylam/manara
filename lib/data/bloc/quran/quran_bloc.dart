import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

import 'quran_event.dart';
import 'quran_state.dart';
import '../../services/quran_api_service.dart';
import '../../services/last_read_service.dart';
import '../../models/quran/quran_surah_model.dart';
import '../../models/quran/quran_bookmark_model.dart';

class QuranBloc extends Bloc<QuranEvent, QuranState> {
  final Uuid _uuid = const Uuid();
  
  QuranBloc() : super(QuranInitial()) {
    on<LoadQuranData>(_onLoadQuranData);
    on<SearchQuran>(_onSearchQuran);
    on<LoadBookmarks>(_onLoadBookmarks);
    on<AddBookmark>(_onAddBookmark);
    on<RemoveBookmark>(_onRemoveBookmark);
  }

  Future<void> _onLoadQuranData(
    LoadQuranData event,
    Emitter<QuranState> emit,
  ) async {
    emit(QuranLoading());
    
    try {
      // First, check if processed cache exists
      final hasProcessedCache = await QuranApiService.hasValidProcessedCache();
      print('DEBUG: Has valid processed cache: $hasProcessedCache');
      
      if (hasProcessedCache) {
        // Load processed data from cache
        final cachedProcessedSurahs = await QuranApiService.loadProcessedSurahsFromCache();
        final cachedProcessedJuzs = await QuranApiService.loadProcessedJuzsFromCache();
        
        print('DEBUG: Cached processed surahs: ${cachedProcessedSurahs.length}');
        print('DEBUG: Cached processed juzs: ${cachedProcessedJuzs.length}');
        
        if (cachedProcessedSurahs.isNotEmpty && cachedProcessedJuzs.isNotEmpty) {
        print('=== LOADING PROCESSED DATA FROM CACHE ===');
        
        // Load bookmarks
        final apiBookmarks = await QuranApiService.getBookmarks();
        final bookmarks = apiBookmarks.map((apiBookmark) => QuranBookmark(
          id: apiBookmark.id,
          surahId: apiBookmark.surahId,
          surahName: apiBookmark.surahName,
          pageNumber: apiBookmark.pageNumber,
          juzNumber: apiBookmark.juzNumber,
          createdAt: apiBookmark.createdAt,
        )).toList();
        
        // Load last read data
        final lastRead = await LastReadService.getLastRead();
        
        emit(QuranLoaded(
          surahs: cachedProcessedSurahs,
          juzs: cachedProcessedJuzs,
          bookmarks: bookmarks,
          filteredSurahs: cachedProcessedSurahs,
                  lastReadSurah: lastRead?['surahName'],
        lastReadPage: lastRead?['pageNumber'],
        lastReadJuz: lastRead?['juzNumber'],
          lastBookmarkSurah: bookmarks.isNotEmpty ? bookmarks.first.surahName : 'Aal-e-Imran',
          lastBookmarkPage: bookmarks.isNotEmpty ? bookmarks.first.pageNumber : 2,
          lastBookmarkJuz: bookmarks.isNotEmpty ? bookmarks.first.juzNumber : 1,
        ));
        return;
      }
      }
      
      print('=== PROCESSING FRESH DATA ===');
      
      // Load surahs from API or cache
      final apiSurahs = await QuranApiService.getAllSurahs();
      
      // Create distributed surahs for display (each surah appears in all its Juz)
      final distributedSurahs = <QuranSurah>[];
      for (final apiSurah in apiSurahs) {
        // Use the Juz data from the API directly
        final surah = QuranSurah(
          number: apiSurah.number,
          name: apiSurah.name,
          arabicName: apiSurah.arabicName,
          englishName: apiSurah.englishName,
          revelationType: apiSurah.revelationType,
          numberOfAyahs: apiSurah.numberOfAyahs,
          juz: apiSurah.juz, // Use the correct Juz from API
          page: apiSurah.page,
        );
        distributedSurahs.add(surah);
      }
      
      // Generate juzs from distributed surahs
      final juzs = await _generateJuzsFromSurahs(distributedSurahs);
      
      // Cache the processed data for future use
      await QuranApiService.cacheProcessedSurahs(distributedSurahs);
      await QuranApiService.cacheProcessedJuzs(juzs);
      
      // Debug: Print Juz distribution
      final juzDistribution = <int, int>{};
      for (final surah in distributedSurahs) {
        juzDistribution[surah.juz] = (juzDistribution[surah.juz] ?? 0) + 1;
      }
      print('BLoC Juz distribution: $juzDistribution');
      
      // Load bookmarks
      final apiBookmarks = await QuranApiService.getBookmarks();
      final bookmarks = apiBookmarks.map((apiBookmark) => QuranBookmark(
        id: apiBookmark.id,
        surahId: apiBookmark.surahId,
        surahName: apiBookmark.surahName,
        pageNumber: apiBookmark.pageNumber,
        juzNumber: apiBookmark.juzNumber,
        createdAt: apiBookmark.createdAt,
      )).toList();
      
      // Load last read data
      final lastRead = await LastReadService.getLastRead();
      
      emit(QuranLoaded(
        surahs: distributedSurahs,
        juzs: juzs,
        bookmarks: bookmarks,
        filteredSurahs: distributedSurahs,
        lastReadSurah: lastRead?['surahName'],
        lastReadPage: lastRead?['pageNumber'],
        lastReadJuz: lastRead?['juzNumber'],
        lastBookmarkSurah: bookmarks.isNotEmpty ? bookmarks.first.surahName : 'Aal-e-Imran',
        lastBookmarkPage: bookmarks.isNotEmpty ? bookmarks.first.pageNumber : 2,
        lastBookmarkJuz: bookmarks.isNotEmpty ? bookmarks.first.juzNumber : 1,
      ));
    } catch (e) {
      emit(QuranError(e.toString()));
    }
  }

  void _onSearchQuran(
    SearchQuran event,
    Emitter<QuranState> emit,
  ) {
    if (state is QuranLoaded) {
      final currentState = state as QuranLoaded;
      final query = event.query.toLowerCase().trim();
      
      if (query.isEmpty) {
        emit(currentState.copyWith(filteredSurahs: currentState.surahs));
      } else {
        // Optimize search by using more efficient filtering
        final filteredSurahs = currentState.surahs.where((surah) {
          return surah.name.toLowerCase().contains(query) ||
                 surah.englishName.toLowerCase().contains(query) ||
                 surah.arabicName.contains(query) ||
                 surah.number.toString().contains(query);
        }).toList();
        
        emit(currentState.copyWith(filteredSurahs: filteredSurahs));
      }
    }
  }

  Future<void> _onLoadBookmarks(
    LoadBookmarks event,
    Emitter<QuranState> emit,
  ) async {
    if (state is QuranLoaded) {
      final currentState = state as QuranLoaded;
      try {
        final apiBookmarks = await QuranApiService.getBookmarks();
        final bookmarks = apiBookmarks.map((apiBookmark) => QuranBookmark(
          id: apiBookmark.id,
          surahId: apiBookmark.surahId,
          surahName: apiBookmark.surahName,
          pageNumber: apiBookmark.pageNumber,
          juzNumber: apiBookmark.juzNumber,
          createdAt: apiBookmark.createdAt,
        )).toList();
        emit(currentState.copyWith(bookmarks: bookmarks));
      } catch (e) {
        emit(QuranError(e.toString()));
      }
    }
  }

  Future<void> _onAddBookmark(
    AddBookmark event,
    Emitter<QuranState> emit,
  ) async {
    if (state is QuranLoaded) {
      final currentState = state as QuranLoaded;
      try {
        final newBookmark = QuranBookmarkModel(
          id: _uuid.v4(),
          surahId: event.surahId,
          surahName: event.surahName,
          pageNumber: event.pageNumber,
          juzNumber: event.juzNumber,
          createdAt: DateTime.now(),
        );
        
        // Save to Hive
        await QuranApiService.addBookmark(newBookmark);
        
        // Update state
        final updatedBookmarks = [...currentState.bookmarks, QuranBookmark(
          id: newBookmark.id,
          surahId: newBookmark.surahId,
          surahName: newBookmark.surahName,
          pageNumber: newBookmark.pageNumber,
          juzNumber: newBookmark.juzNumber,
          createdAt: newBookmark.createdAt,
        )];
        emit(currentState.copyWith(bookmarks: updatedBookmarks));
      } catch (e) {
        emit(QuranError(e.toString()));
      }
    }
  }

  Future<void> _onRemoveBookmark(
    RemoveBookmark event,
    Emitter<QuranState> emit,
  ) async {
    if (state is QuranLoaded) {
      final currentState = state as QuranLoaded;
      try {
        // Remove from Hive
        await QuranApiService.removeBookmark(event.bookmarkId);
        
        // Update state
        final updatedBookmarks = currentState.bookmarks
            .where((bookmark) => bookmark.id != event.bookmarkId)
            .toList();
        
        emit(currentState.copyWith(bookmarks: updatedBookmarks));
      } catch (e) {
        emit(QuranError(e.toString()));
      }
    }
  }

  // Helper method to generate juzs from surahs
  Future<List<QuranJuz>> _generateJuzsFromSurahs(List<QuranSurah> surahs) async {
    // Create a map to store surahs for each Juz
    final Map<int, List<QuranSurah>> juzMap = {};
    
    // Initialize all 30 Juz
    for (int i = 1; i <= 30; i++) {
      juzMap[i] = [];
    }
    
    // Distribute surahs to their correct Juz
    for (final surah in surahs) {
      final juzNumber = surah.juz; // Use the correct Juz from the surah data
      if (juzMap.containsKey(juzNumber)) {
        juzMap[juzNumber]!.add(surah);
      }
    }
    
    // Create juz objects with proper page ranges and quarters
    final juzs = <QuranJuz>[];
    for (int juzNumber = 1; juzNumber <= 30; juzNumber++) {
      final juzSurahs = juzMap[juzNumber]!;
      
      // Always create Juz objects, even if they don't have surahs that start in them
      // because they might contain continuations of surahs from previous Juz
      if (juzSurahs.isNotEmpty) {
        // Sort surahs by page number
        juzSurahs.sort((a, b) => a.page.compareTo(b.page));
        
        // Calculate start and end pages
        final startPage = juzSurahs.first.page;
        final lastSurah = juzSurahs.last;
        final endPage = lastSurah.page + (lastSurah.numberOfAyahs / 10).ceil();
        
        // Generate quarters for this Juz from API
        final quarters = await _generateQuartersForJuz(juzNumber, juzSurahs);
        
        juzs.add(QuranJuz(
          number: juzNumber,
          startPage: startPage,
          endPage: endPage,
          surahs: juzSurahs,
          quarters: quarters,
        ));
      } else {
        // Create empty Juz for Juz that don't have surahs starting in them
        // but might contain continuations (like Juz 2 and 5)
        final quarters = await _generateQuartersForJuz(juzNumber, []);
        
        juzs.add(QuranJuz(
          number: juzNumber,
          startPage: 0, // Will be calculated based on quarters
          endPage: 0,   // Will be calculated based on quarters
          surahs: [],
          quarters: quarters,
        ));
      }
    }
    
    // Sort by juz number
    juzs.sort((a, b) => a.number.compareTo(b.number));
    
    return juzs;
  }

  // Helper method to generate quarters for a Juz
  Future<List<QuranQuarter>> _generateQuartersForJuz(int juzNumber, List<QuranSurah> juzSurahs) async {
    // Get quarters from the API
    return await QuranApiService.getQuartersForJuz(juzNumber);
  }
}
