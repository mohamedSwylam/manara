import 'package:equatable/equatable.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final Set<String> favoritedDuas;

  const FavoritesLoaded(this.favoritedDuas);

  @override
  List<Object?> get props => [favoritedDuas];

  bool isDuaFavorited(String duaId) {
    return favoritedDuas.contains(duaId);
  }
}

class FavoritesFailure extends FavoritesState {
  final String error;

  const FavoritesFailure(this.error);

  @override
  List<Object?> get props => [error];
}
