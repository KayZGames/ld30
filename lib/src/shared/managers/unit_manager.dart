part of shared;

class UnitManager extends Manager {
  ComponentMapper<Unit> um;
  ComponentMapper<Selected> sm;
  ComponentMapper<Transform> tm;
  ComponentMapper<Move> mm;
  GameManager gameManager;
  List<List<Entity>> unitCoords;
  Map<String, Map<int, Entity>> factionUnits = {F_HELL: <int, Entity>{},
                                          F_HEAVEN: <int, Entity>{},
                                          F_FIRE: <int, Entity>{},
                                          F_ICE: <int, Entity>{},
                                          F_NEUTRAL: <int, Entity>{}};

  @override
  void initialize() {
    eventBus.on(gameStartedEvent).listen((_) {
      unitCoords = new List.generate(gameManager.sizeX, (_) => new List(gameManager.sizeY));
    });
  }


  @override
  void added(Entity entity) {
    if (um.has(entity)) {
      var t = tm.get(entity);
      var u = um.get(entity);
      unitCoords[t.x][t.y] = entity;
      factionUnits[u.faction][entity.id] = entity;
    }
  }

  @override
  void deleted(Entity entity) {
    if (um.has(entity)) {
      var t = tm.get(entity);
      var u = um.get(entity);
      unitCoords[t.x][t.y] = null;
      factionUnits[u.faction].remove(entity.id);
    }
  }

  @override
  void changed(Entity entity) {
    if (mm.has(entity)) {

    }
  }

  bool isTileEmpty(int x, int y) {
    if (x < 0 || y < 0 || x >= gameManager.sizeX || y >= gameManager.sizeY) return false;
    return unitCoords[x][y] == null;
  }

  Entity getNextUnit(String faction) {
    Entity selected = getSelectedUnit(faction);
    if (null == selected) {
      return factionUnits[faction].values.firstWhere(canMove, orElse: () => null);
    }
    selected..removeComponent(Selected)
            ..changedInWorld();
    return factionUnits[faction].values
        .skipWhile((entity) => entity != selected)
        .firstWhere((entity) => entity != selected && canMove(entity),
          orElse: () => factionUnits[faction].values.firstWhere(canMove, orElse: () => selected));
  }

  bool canMove(Entity entity) => um.get(entity).movesLeft > 0;


  Entity getSelectedUnit(String faction) =>
    factionUnits[faction].values.firstWhere((entity) => sm.has(entity), orElse: () => null);

  Entity getEntity(int x, int y) => unitCoords[x][y];

  bool isFriendlyUnit(String faction, int x, int y) {
    var entity = unitCoords[x][y];
    if (null != entity) {
      return um.get(entity).faction == faction;
    }
    return false;
  }
}
