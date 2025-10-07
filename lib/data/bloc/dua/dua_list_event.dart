abstract class DuaListEvent {
  const DuaListEvent();
}

class LoadDuasByCategory extends DuaListEvent {
  final String categoryId;

  const LoadDuasByCategory(this.categoryId);
}

class RefreshDuasByCategory extends DuaListEvent {
  final String categoryId;

  const RefreshDuasByCategory(this.categoryId);
}
