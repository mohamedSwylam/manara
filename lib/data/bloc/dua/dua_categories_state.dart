import '../../models/dua/dua_category_model.dart';

abstract class DuaCategoriesState {
  const DuaCategoriesState();
}

class DuaCategoriesInitial extends DuaCategoriesState {}

class DuaCategoriesLoading extends DuaCategoriesState {}

class DuaCategoriesLoaded extends DuaCategoriesState {
  final List<DuaCategoryModel> categories;

  const DuaCategoriesLoaded(this.categories);
}

class DuaCategoriesFailure extends DuaCategoriesState {
  final String error;

  const DuaCategoriesFailure(this.error);
}

class DuaCategoriesOffline extends DuaCategoriesState {
  final String message;

  const DuaCategoriesOffline(this.message);
}

class DuaCategoriesLoadedOffline extends DuaCategoriesState {
  final List<DuaCategoryModel> categories;
  final String message;

  const DuaCategoriesLoadedOffline(this.categories, this.message);
}
