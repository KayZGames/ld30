part of shared;

class UnitManager extends Manager {
  ComponentMapper<Unit> um;
  ComponentMapper<Transform> tm;
  List<List<Entity>> unitCoords = new List.generate(TILES_X, (_) => new List(TILES_Y));

  @override
  void added(Entity entity) {
    if (um.has(entity)) {
      var t = tm.get(entity);
      unitCoords[t.x][t.y] = entity;
    }
  }

  @override
  void deleted(Entity entity) {
    if (um.has(entity)) {
      var t = tm.get(entity);
      unitCoords[t.x][t.y] = null;
    }
  }

  bool isTileEmpty(int x, int y) => unitCoords[x][y] == null;

}