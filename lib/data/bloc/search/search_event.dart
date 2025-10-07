import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  final String category; // 'all', 'quran', 'tafsir', 'others'

  const SearchQueryChanged({
    required this.query,
    required this.category,
  });

  @override
  List<Object?> get props => [query, category];
}

class SearchCategoryChanged extends SearchEvent {
  final String category;

  const SearchCategoryChanged({required this.category});

  @override
  List<Object?> get props => [category];
}

class ClearSearch extends SearchEvent {
  const ClearSearch();
}

class LoadSearchHistory extends SearchEvent {
  const LoadSearchHistory();
}

class SaveSearchHistory extends SearchEvent {
  final String query;

  const SaveSearchHistory({required this.query});

  @override
  List<Object?> get props => [query];
}

