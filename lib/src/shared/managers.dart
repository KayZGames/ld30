part of shared;

class UnitManager extends Manager {
  ComponentMapper<Unit> um;
  ComponentMapper<Selected> sm;
  ComponentMapper<Transform> tm;
  List<List<Entity>> unitCoords = new List.generate(TILES_X, (_) => new List(TILES_Y));
  Map<String, Bag<Entity>> playerUnits = {P_HELL: new Bag<Entity>(),
                                          P_HEAVEN: new Bag<Entity>(),
                                          P_FIRE: new Bag<Entity>(),
                                          P_ICE: new Bag<Entity>()};


  @override
  void added(Entity entity) {
    if (um.has(entity)) {
      var t = tm.get(entity);
      var u = um.get(entity);
      unitCoords[t.x][t.y] = entity;
      playerUnits[u.alignment][entity.id] = entity;
    }
  }

  @override
  void deleted(Entity entity) {
    if (um.has(entity)) {
      var t = tm.get(entity);
      var u = um.get(entity);
      unitCoords[t.x][t.y] = null;
      playerUnits[u.alignment][entity.id] = null;
    }
  }

  bool isTileEmpty(int x, int y) => unitCoords[x][y] == null;

  Entity getNextUnit(String alignment) =>
    playerUnits[alignment].where((entity) => entity != null).firstWhere((entity) => um.get(entity).movesLeft > 0);

  Entity getSelectedUnit(String alignment) =>
    playerUnits[alignment].where((entity) => entity != null).firstWhere((entity) => sm.has(entity));

}