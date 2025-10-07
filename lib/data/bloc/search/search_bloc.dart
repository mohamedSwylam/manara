import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../../services/quran_api_service.dart';
import '../../models/quran/quran_surah_model.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchCategoryChanged>(_onSearchCategoryChanged);
    on<ClearSearch>(_onClearSearch);
    on<LoadSearchHistory>(_onLoadSearchHistory);
    on<SaveSearchHistory>(_onSaveSearchHistory);
  }

  static const List<String> _searchHistory = [];
  
  // Cache for search results to improve performance
  final Map<String, List<SearchCategoryResult>> _searchCache = {};

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(SearchLoaded(
        query: '',
        selectedCategory: event.category,
        categoryResults: [],
        searchHistory: _searchHistory,
      ));
      return;
    }

    // Minimum query length for Arabic text (prevent single letter searches)
    if (event.query.trim().length < 3) {
      emit(SearchLoaded(
        query: event.query,
        selectedCategory: event.category,
        categoryResults: [],
        searchHistory: _searchHistory,
      ));
      return;
    }

    // Check if we already have results for this query in cache
    final cacheKey = '${event.query}_${event.category}';
    if (_searchCache.containsKey(cacheKey)) {
      emit(SearchLoaded(
        query: event.query,
        selectedCategory: event.category,
        categoryResults: _searchCache[cacheKey]!,
        searchHistory: _searchHistory,
      ));
      return;
    }

    // Simple debouncing - just wait a bit
    await Future.delayed(const Duration(milliseconds: 300));
    
    emit(SearchLoading());

    try {
      final results = await _performSearch(event.query, event.category);
      
      // Cache the results
      _searchCache[cacheKey] = results;
      
      emit(SearchLoaded(
        query: event.query,
        selectedCategory: event.category,
        categoryResults: results,
        searchHistory: _searchHistory,
      ));
    } catch (e) {
      print('DEBUG: Search error: $e');
      emit(SearchError(e.toString()));
    }
  }

  void _onSearchCategoryChanged(
    SearchCategoryChanged event,
    Emitter<SearchState> emit,
  ) {
    if (state is SearchLoaded) {
      final currentState = state as SearchLoaded;
      // Only update category, don't trigger new search
      emit(currentState.copyWith(selectedCategory: event.category));
    }
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) {
    // Clear cache when clearing search
    _searchCache.clear();
    emit(SearchLoaded(
      query: '',
      selectedCategory: 'all',
      categoryResults: [],
      searchHistory: _searchHistory,
    ));
  }

  Future<void> _onLoadSearchHistory(
    LoadSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    print('DEBUG: LoadSearchHistory event received');
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('search_history') ?? [];
      
      print('DEBUG: Loaded search history: $history');
      
      if (state is SearchLoaded) {
        final currentState = state as SearchLoaded;
        emit(currentState.copyWith(searchHistory: history));
      } else {
        print('DEBUG: Emitting initial SearchLoaded state');
        emit(SearchLoaded(
          query: '',
          selectedCategory: 'all',
          categoryResults: [],
          searchHistory: history,
        ));
      }
    } catch (e) {
      print('DEBUG: Error loading search history: $e');
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onSaveSearchHistory(
    SaveSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('search_history') ?? [];
      
      // Remove if already exists and add to front
      history.remove(event.query);
      history.insert(0, event.query);
      
      // Keep only last 10 searches
      if (history.length > 10) {
        history.removeRange(10, history.length);
      }
      
      await prefs.setStringList('search_history', history);
      
      if (state is SearchLoaded) {
        final currentState = state as SearchLoaded;
        emit(currentState.copyWith(searchHistory: history));
      }
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<List<SearchCategoryResult>> _performSearch(
    String query,
    String category,
  ) async {
    // Simulate search delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    final results = <SearchCategoryResult>[];
    final queryLower = query.toLowerCase().trim();

    if (category == 'all' || category == 'quran') {
      final surahResults = await _searchSurahs(queryLower);
      if (surahResults.isNotEmpty) {
        results.add(SearchCategoryResult(
          category: 'surahs',
          title: 'Suras: ${surahResults.length} results',
          results: surahResults,
        ));
      }

      final ayahResults = await _searchAyahs(queryLower);
      if (ayahResults.isNotEmpty) {
        results.add(SearchCategoryResult(
          category: 'quran_text',
          title: 'Quran text: ${ayahResults.length} results',
          results: ayahResults,
        ));
      }
    }

    if (category == 'all' || category == 'tafsir') {
      final tafsirResults = await _searchTafsir(queryLower);
      if (tafsirResults.isNotEmpty) {
        results.add(SearchCategoryResult(
          category: 'tafsir',
          title: 'Tafsir: ${tafsirResults.length} results',
          results: tafsirResults,
        ));
      }
    }

    if (category == 'all' || category == 'others') {
      final otherResults = await _searchOthers(queryLower);
      if (otherResults.isNotEmpty) {
        results.add(SearchCategoryResult(
          category: 'others',
          title: 'Others: ${otherResults.length} results',
          results: otherResults,
        ));
      }
    }
    
    return results;
  }

    Future<List<SearchResult>> _searchSurahs(String query) async {
    try {
      // Get all surahs from the Quran API service
      final surahs = await QuranApiService.getAllSurahs();
      
      // Remove duplicates based on surah number (since a surah can appear in multiple Juz)
      final uniqueSurahs = <int, QuranSurahModel>{};
      for (final surah in surahs) {
        if (!uniqueSurahs.containsKey(surah.number)) {
          uniqueSurahs[surah.number] = surah;
        }
      }
      
      final results = <SearchResult>[];
      
      for (final surah in uniqueSurahs.values) {
        // Also check if the query matches the surah name without diacritics
        final arabicNameWithoutDiacritics = surah.arabicName.replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]'), '');
        
        // Check if any part of the surah name contains the query
        bool nameContainsQuery = false;
        
        // For English queries, prioritize English name matches
        if (RegExp(r'[a-zA-Z]').hasMatch(query)) {
          nameContainsQuery = surah.englishName.toLowerCase().contains(query) ||
                             surah.englishName.toLowerCase().split(' ').any((word) => word.contains(query)) ||
                             surah.englishName.toLowerCase().split(' ').any((word) => word == query) ||
                             surah.name.toLowerCase().contains(query) ||
                             surah.number.toString().contains(query);
                 } else {
           // For Arabic queries, prioritize Arabic name matches
           // Check if the query is a common prefix that should be ignored
           if (query == 'ال' || query == 'ا') {
             nameContainsQuery = false; // Don't search for common prefixes
           } else {
             // For Arabic queries, check for better matches
             nameContainsQuery = surah.arabicName.contains(query) ||
                                arabicNameWithoutDiacritics.contains(query) ||
                                surah.name.toLowerCase().contains(query) ||
                                surah.englishName.toLowerCase().contains(query) ||
                                surah.number.toString().contains(query) ||
                                // Check if query matches the beginning of Arabic name (without ال)
                                surah.arabicName.replaceAll('ال', '').startsWith(query.replaceAll('ال', ''));
           }
         }
        
        if (nameContainsQuery) {
          print('DEBUG: Found surah match - ${surah.name} (${surah.englishName}) for query: $query');
          results.add(SearchResult(
            id: 'surah_${surah.number}',
            title: '${surah.number}. ${surah.name}',
            subtitle: surah.arabicName,
            content: '${surah.numberOfAyahs} verses • ${surah.revelationType}',
            type: 'surah',
            surahNumber: surah.number,
            surahName: surah.name,
            englishName: surah.englishName,
          ));
          
          // Limit results to first 20 for better performance
          if (results.length >= 20) {
            break;
          }
        }
      }
      
      return results;
    } catch (e) {
      print('DEBUG: Error in surah search: $e');
      return [];
    }
  }

  Future<List<SearchResult>> _searchAyahs(String query) async {
    try {
      // Get all surahs to search through their ayahs
      final surahs = await QuranApiService.getAllSurahs();
      
      // Remove duplicates based on surah number
      final uniqueSurahs = <int, QuranSurahModel>{};
      for (final surah in surahs) {
        if (!uniqueSurahs.containsKey(surah.number)) {
          uniqueSurahs[surah.number] = surah;
        }
      }
      
      final results = <SearchResult>[];
      
      // Search through first few surahs for performance (limit to first 10 surahs)
      final surahsToSearch = uniqueSurahs.values.take(10).toList();
      
      for (final surah in surahsToSearch) {
        try {
          // Get surah details to access ayahs
          final surahDetails = await QuranApiService.getSurahDetails(surah.number);
          
          if (surahDetails['data'] != null && surahDetails['data']['ayahs'] != null) {
            final ayahs = surahDetails['data']['ayahs'] as List;
            
            for (final ayah in ayahs) {
              final ayahNumber = ayah['numberInSurah'] ?? 0;
              final ayahText = ayah['text'] ?? '';
              
              // Search in Arabic text (case insensitive)
              bool textMatch = false;
              bool translationMatch = false;
              
              // For English queries, prioritize translation matches
              if (RegExp(r'[a-zA-Z]').hasMatch(query)) {
                if (ayah['translation'] != null && ayah['translation']['en'] != null) {
                  final translation = ayah['translation']['en'] as String;
                  translationMatch = translation.toLowerCase().contains(query) ||
                                   translation.toLowerCase().split(' ').any((word) => word.contains(query)) ||
                                   translation.toLowerCase().split(' ').any((word) => word == query);
                }
                // Also check Arabic text for English queries (less priority)
                textMatch = ayahText.toLowerCase().contains(query);
                             } else {
                 // For Arabic queries, prioritize Arabic text matches
                 // Skip common prefixes that would match too many results
                 if (query != 'ال' && query != 'ا') {
                   textMatch = ayahText.toLowerCase().contains(query);
                   // Also check translation for Arabic queries (less priority)
                   if (ayah['translation'] != null && ayah['translation']['en'] != null) {
                     final translation = ayah['translation']['en'] as String;
                     translationMatch = translation.toLowerCase().contains(query);
                   }
                 }
               }
              
              if (textMatch || translationMatch) {
                print('DEBUG: Found ayah match - ${surah.name} $ayahNumber for query: $query');
                                 results.add(SearchResult(
                   id: 'ayah_${surah.number}_$ayahNumber',
                   title: '${surah.name} $ayahNumber',
                   subtitle: ayahText,
                   content: ayah['translation']?['en'] ?? 'Translation not available',
                   type: 'ayah',
                   surahNumber: surah.number,
                   ayahNumber: ayahNumber,
                   surahName: surah.name,
                   englishName: surah.englishName,
                 ));
                
                // Limit results to first 10 matches for performance
                if (results.length >= 10) {
                  break;
                }
              }
            }
          }
        } catch (e) {
          continue;
        }
        
        // Limit results to first 10 matches for performance
        if (results.length >= 10) {
          break;
        }
      }
      
      return results;
    } catch (e) {
      return [];
    }
  }

  Future<List<SearchResult>> _searchTafsir(String query) async {
    // For now, return empty list as tafsir data is not yet implemented
    // TODO: Implement tafsir search when tafsir data is available
    return [];
  }

  Future<List<SearchResult>> _searchOthers(String query) async {
    // For now, return empty list as other content is not yet implemented
    // TODO: Implement other content search when data is available
    return [];
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
