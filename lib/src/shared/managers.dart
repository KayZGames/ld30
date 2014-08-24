part of shared;

bool isEntity(Entity entity) => entity != null;

class UnitManager extends Manager {
  ComponentMapper<Unit> um;
  ComponentMapper<Selected> sm;
  ComponentMapper<Transform> tm;
  ComponentMapper<Move> mm;
  List<List<Entity>> unitCoords = new List.generate(TILES_X, (_) => new List(TILES_Y));
  Map<String, Bag<Entity>> factionUnits = {F_HELL: new Bag<Entity>(),
                                          F_HEAVEN: new Bag<Entity>(),
                                          F_FIRE: new Bag<Entity>(),
                                          F_ICE: new Bag<Entity>(),
                                          F_NEUTRAL: new Bag<Entity>()};


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
      factionUnits[u.faction][entity.id] = null;
    }
  }

  @override
  void changed(Entity entity) {
    if (mm.has(entity)) {

    }
  }

  bool isTileEmpty(int x, int y) {
    if (x < 0 || y < 0 || x >= TILES_X || y >= TILES_Y) return false;
    return unitCoords[x][y] == null;
  }

  Entity getNextUnit(String faction) {
    Entity selected = getSelectedUnit(faction);
    if (null == selected) {
      return factionUnits[faction].where(isEntity).firstWhere(canMove, orElse: () => null);
    }
    selected..removeComponent(Selected)
            ..changedInWorld();
    return factionUnits[faction].where(isEntity)
        .skipWhile((entity) => entity != selected)
        .firstWhere((entity) => entity != selected && canMove(entity),
          orElse: () => factionUnits[faction].where(isEntity).firstWhere(canMove, orElse: () => selected));
  }

  bool canMove(Entity entity) => um.get(entity).movesLeft > 0;


  Entity getSelectedUnit(String faction) =>
    factionUnits[faction].where(isEntity).firstWhere((entity) => sm.has(entity), orElse: () => null);

  Entity getEntity(int x, int y) => unitCoords[x][y];

}

class SpawnerManager extends Manager {
  ComponentMapper<Transform> tm;
  ComponentMapper<Spawner> sm;
  ComponentMapper<Unit> um;
  UnitManager unitManager;

  final spawnArea = <List<int>>[[0, -1], [1, -1], [-1, -1], [-1, 0], [1, 0], [0, 1], [1, 1], [-1, 1]];

  Map<String, Bag<Entity>> factionSpawner = {F_HELL: new Bag<Entity>(),
                                             F_HEAVEN: new Bag<Entity>(),
                                             F_FIRE: new Bag<Entity>(),
                                             F_ICE: new Bag<Entity>(),
                                             F_NEUTRAL: new Bag<Entity>(),
                                             };

  @override
  void added(Entity entity) {
    if (sm.has(entity)) {
      var u = um.get(entity);
      factionSpawner[u.faction][entity.id] = entity;
    }
  }

  @override
  void deleted(Entity entity) {
    if (sm.has(entity)) {
      var u = um.get(entity);
      factionSpawner[u.faction][entity.id] = null;
    }
  }

  void spawn(Entity entity) {
    var s = sm.get(entity);
    if (s.spawnTime <= 0) {
      var t = tm.get(entity);
      var coords = spawnArea.firstWhere((xy) => unitManager.isTileEmpty(t.x + xy[0], t.y + xy[1]), orElse: () => <int>[]);
      if (coords.isNotEmpty) {
        var unit = um.get(entity);
        world.createAndAddEntity([new Transform(t.x + coords[0], t.y + coords[1]),
                                  new Unit(unit.faction, 10, unit.level),
                                  new Renderable('peasant')]);
        s.spawnTime = s.maxSpawnTime;
      }
    }
  }
}


class TurnManager extends Manager {
  ComponentMapper<Unit> um;
  ComponentMapper<Spawner> sm;
  ComponentMapper<Conquerable> cm;
  UnitManager unitManager;
  SpawnerManager spawnerManager;

  void nextTurn() {
    unitManager.factionUnits[gameState.currentFaction].where(isEntity).forEach((entity) => um.get(entity).nextTurn());
    spawnerManager.factionSpawner[gameState.currentFaction].where(isEntity).forEach((entity) => sm.get(entity).spawnTime--);

    gameState.nextFaction();

    unitManager.factionUnits[gameState.currentFaction].where(isEntity).forEach(recoverConquarable);
    spawnerManager.factionSpawner[gameState.currentFaction].where(isEntity).forEach(spawnerManager.spawn);
  }

  void recoverConquarable(Entity entity) {
    if (cm.has(entity)) {
      var u = um.get(entity);
      if (u.health < u.maxHealth) {
        u.health = min(u.health + u.maxHealth * 0.2, u.maxHealth);
      }
    }
  }
}

class FogOfWarManager extends Manager {
  ComponentMapper<Unit> um;
  ComponentMapper<Transform> tm;
  bool hasChanges = false;

  Map<String, List<List<bool>>> tiles = {F_HELL: new List.generate(TILES_X, (_) => new List.generate(TILES_Y, (_) => false)),
                                         F_HEAVEN: new List.generate(TILES_X, (_) => new List.generate(TILES_Y, (_) => false)),
                                         F_FIRE: new List.generate(TILES_X, (_) => new List.generate(TILES_Y, (_) => false)),
                                         F_ICE: new List.generate(TILES_X, (_) => new List.generate(TILES_Y, (_) => false))
                                        };

  void uncoverTiles(Entity entity) {
    var t = tm.get(entity);
    var u = um.get(entity);

    for (int y = -u.viewRange; y <= u.viewRange; y++) {
      for (int x = -u.viewRange; x <= u.viewRange; x++) {
        if (x.abs() + y.abs() <= u.viewRange && t.x + x > 0 && t.x + x < TILES_X && t.y + y > 0 && t.y + y < TILES_Y) {
          tiles[u.faction][t.x + x][t.y + y] = true;
        }
      }
    }
    hasChanges = true;
  }

}