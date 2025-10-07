import 'package:equatable/equatable.dart';

class SearchResult extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String content;
  final String type; // 'surah', 'ayah', 'tafsir', 'other'
  final int? surahNumber;
  final int? ayahNumber;
  final String? surahName;
  final String? englishName;

  const SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.type,
    this.surahNumber,
    this.ayahNumber,
    this.surahName,
    this.englishName,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        content,
        type,
        surahNumber,
        ayahNumber,
        surahName,
        englishName,
      ];

  SearchResult copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? content,
    String? type,
    int? surahNumber,
    int? ayahNumber,
    String? surahName,
    String? englishName,
  }) {
    return SearchResult(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      content: content ?? this.content,
      type: type ?? this.type,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      surahName: surahName ?? this.surahName,
      englishName: englishName ?? this.englishName,
    );
  }
}

class SearchCategoryResult extends Equatable {
  final String category;
  final String title;
  final List<SearchResult> results;

  const SearchCategoryResult({
    required this.category,
    required this.title,
    required this.results,
  });

  @override
  List<Object?> get props => [category, title, results];

  SearchCategoryResult copyWith({
    String? category,
    String? title,
    List<SearchResult>? results,
  }) {
    return SearchCategoryResult(
      category: category ?? this.category,
      title: title ?? this.title,
      results: results ?? this.results,
    );
  }
}

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final String query;
  final String selectedCategory;
  final List<SearchCategoryResult> categoryResults;
  final List<String> searchHistory;

  const SearchLoaded({
    required this.query,
    required this.selectedCategory,
    required this.categoryResults,
    required this.searchHistory,
  });

  @override
  List<Object?> get props => [
        query,
        selectedCategory,
        categoryResults,
        searchHistory,
      ];

  SearchLoaded copyWith({
    String? query,
    String? selectedCategory,
    List<SearchCategoryResult>? categoryResults,
    List<String>? searchHistory,
  }) {
    return SearchLoaded(
      query: query ?? this.query,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categoryResults: categoryResults ?? this.categoryResults,
      searchHistory: searchHistory ?? this.searchHistory,
    );
  }
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
