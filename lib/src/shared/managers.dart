part of shared;

class UnitManager extends Manager {
  ComponentMapper<Unit> um;
  ComponentMapper<Selected> sm;
  ComponentMapper<Transform> tm;
  ComponentMapper<Move> mm;
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
      playerUnits[u.faction][entity.id] = entity;
    }
  }

  @override
  void deleted(Entity entity) {
    if (um.has(entity)) {
      var t = tm.get(entity);
      var u = um.get(entity);
      unitCoords[t.x][t.y] = null;
      playerUnits[u.faction][entity.id] = null;
    }
  }

  @override
  void changed(Entity entity) {
    if (mm.has(entity)) {

    }
  }

  bool isTileEmpty(int x, int y) => unitCoords[x][y] == null;

  Entity getNextUnit(String faction) {
    Entity selected;
    try {
      selected = getSelectedUnit(faction);
    } on StateError catch (_) {
      return playerUnits[faction].where(isEntity).firstWhere(canMove);
    }
    selected..removeComponent(Selected)
            ..changedInWorld();
    return playerUnits[faction].where(isEntity)
        .skipWhile((entity) => entity != selected)
        .firstWhere((entity) => entity != selected && canMove(entity),
          orElse: () => playerUnits[faction].where(isEntity).firstWhere(canMove));
  }

  bool isEntity(Entity entity) => entity != null;
  bool canMove(Entity entity) => um.get(entity).movesLeft > 0;


  Entity getSelectedUnit(String faction) =>
    playerUnits[faction].where(isEntity).firstWhere((entity) => sm.has(entity));

  void nextTurn() {
    playerUnits.forEach((_, entities) => entities.where(isEntity).forEach((entity) => um.get(entity).nextTurn()));
  }

  Entity getEntity(int x, int y) => unitCoords[x][y];

}