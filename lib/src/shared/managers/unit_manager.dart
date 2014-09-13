part of shared;

class UnitManager extends Manager {
  ComponentMapper<Unit> um;
  ComponentMapper<Selected> sm;
  ComponentMapper<Transform> tm;
  ComponentMapper<Move> mm;
  ComponentMapper<Attacker> am;
  ComponentMapper<Defender> defenderMapper;
  ComponentMapper<Defeated> defeatedMapper;
  GameManager gameManager;
  List<List<Entity>> unitCoords;
  Map<String, Map<int, Entity>> factionUnits = {F_HELL: <int, Entity>{},
                                          F_HEAVEN: <int, Entity>{},
                                          F_FIRE: <int, Entity>{},
                                          F_ICE: <int, Entity>{},
                                          F_NEUTRAL: <int, Entity>{}};

  @override
  void initialize() {
    eventBus.on(GameStartedEvent).listen((_) {
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
      checkForDefeat(u.faction);
    }
  }

  void switchFaction(Entity entity, String faction) {
    var u = um.get(entity);
    var oldFaction = u.faction;
    factionUnits[u.faction].remove(entity.id);
    factionUnits[faction][entity.id] = entity;
    u.faction = faction;
    checkForDefeat(oldFaction);
  }

  void checkForDefeat(String faction) {
    if (factionUnits[faction].length == 0) {
      gameManager.factionLost(faction);
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

  bool isOccupied(Entity entity) => mm.has(entity) || am.has(entity) || defeatedMapper.has(entity)|| defenderMapper.has(entity);
}
