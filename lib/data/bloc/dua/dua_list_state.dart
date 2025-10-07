import '../../models/dua/dua_model.dart';

abstract class DuaListState {
  const DuaListState();
}

class DuaListInitial extends DuaListState {}

class DuaListLoading extends DuaListState {}

class DuaListLoaded extends DuaListState {
  final List<DuaModel> duas;
  final String categoryId;

  const DuaListLoaded(this.duas, this.categoryId);
}

class DuaListFailure extends DuaListState {
  final String error;

  const DuaListFailure(this.error);
}
