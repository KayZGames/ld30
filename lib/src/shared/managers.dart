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

  @override
  void changed(Entity entity) {
    if (mm.has(entity)) {
      var u = um.get(entity);
      if (u.movesLeft > 0) {
        var t = tm.get(entity);
        var m = mm.get(entity);
        var targetX = t.x + m.x;
        var targetY = t.y + m.y;
        if (targetX >= 0 && targetY >= 0 && targetX < TILES_X && targetY < TILES_Y
            && unitCoords[targetX][targetY] == null) {
          unitCoords[t.x][t.y] = null;
          t.x += m.x;
          t.y += m.y;
          unitCoords[t.x][t.y] = entity;
          u.movesLeft -= 1;
        }
      }
      entity..removeComponent(Move)
            ..changedInWorld();
    }
  }

  bool isTileEmpty(int x, int y) => unitCoords[x][y] == null;

  Entity getNextUnit(String alignment) {
    Entity selected;
    try {
      selected = getSelectedUnit(alignment);
    } on StateError catch (_) {
      return playerUnits[alignment].where(isEntity).firstWhere(canMove);
    }
    selected..removeComponent(Selected)
            ..changedInWorld();
    return playerUnits[alignment].where(isEntity)
        .skipWhile((entity) => entity != selected)
        .firstWhere((entity) => entity != selected && canMove(entity),
          orElse: () => playerUnits[alignment].where(isEntity).firstWhere(canMove));
  }

  bool isEntity(Entity entity) => entity != null;
  bool canMove(Entity entity) => um.get(entity).movesLeft > 0;


  Entity getSelectedUnit(String alignment) =>
    playerUnits[alignment].where(isEntity).firstWhere((entity) => sm.has(entity));

  void nextTurn() {
    playerUnits.forEach((_, entities) => entities.where(isEntity).forEach((entity) => um.get(entity).nextTurn()));
  }

}