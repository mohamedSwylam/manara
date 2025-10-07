import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavoriteStatus extends FavoritesEvent {
  final List<String> duaIds;

  const LoadFavoriteStatus(this.duaIds);

  @override
  List<Object?> get props => [duaIds];
}

class ToggleDuaFavorite extends FavoritesEvent {
  final String duaId;

  const ToggleDuaFavorite(this.duaId);

  @override
  List<Object?> get props => [duaId];
}

class ClearFavorites extends FavoritesEvent {}
