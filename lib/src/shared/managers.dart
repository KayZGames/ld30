part of shared;


class UnitManager extends Manager {
  ComponentMapper<Unit> um;
  ComponentMapper<Selected> sm;
  ComponentMapper<Transform> tm;
  ComponentMapper<Move> mm;
  List<List<Entity>> unitCoords = new List.generate(TILES_X, (_) => new List(TILES_Y));
  Map<String, Map<int, Entity>> factionUnits = {F_HELL: <int, Entity>{},
                                          F_HEAVEN: <int, Entity>{},
                                          F_FIRE: <int, Entity>{},
                                          F_ICE: <int, Entity>{},
                                          F_NEUTRAL: <int, Entity>{}};


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
    if (x < 0 || y < 0 || x >= TILES_X || y >= TILES_Y) return false;
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

class SpawnerManager extends Manager {
  ComponentMapper<Transform> tm;
  ComponentMapper<Spawner> sm;
  ComponentMapper<Unit> um;
  UnitManager unitManager;
  FogOfWarManager fowManager;

  final spawnArea = <List<int>>[[0, -1], [1, -1], [-1, -1], [-1, 0], [1, 0], [0, 1], [1, 1], [-1, 1]];

  Map<String, Map<int, Entity>> factionSpawner = {F_HELL: <int, Entity>{},
                                             F_HEAVEN: <int, Entity>{},
                                             F_FIRE: <int, Entity>{},
                                             F_ICE: <int, Entity>{},
                                             F_NEUTRAL: <int, Entity>{},
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
      factionSpawner[u.faction].remove(entity.id);
    }
  }

  void spawn(Entity entity) {
    var s = sm.get(entity);
    if (s.spawnTime <= 0) {
      var t = tm.get(entity);
      var coords = spawnArea.firstWhere((xy) => unitManager.isTileEmpty(t.x + xy[0], t.y + xy[1]), orElse: () => <int>[]);
      if (coords.isNotEmpty) {
        var unit = um.get(entity);
        var components = [new Transform(t.x + coords[0], t.y + coords[1]),
                          new Unit(unit.faction, 5, unit.level, 2),
                          new Renderable('peasant')];
        if (null == unitManager.getSelectedUnit(gameState.currentFaction)) {
          components.add(new Selected());
        }
        var spawnedEntity = world.createAndAddEntity(components);
        s.spawnTime = s.maxSpawnTime;
        fowManager.uncoverTiles(spawnedEntity);
      }
    }
  }
}


class TurnManager extends Manager {
  ComponentMapper<Unit> um;
  ComponentMapper<Spawner> sm;
  ComponentMapper<Conquerable> cm;
  UnitManager unitManager;
  TileManager tileManager;
  SpawnerManager spawnerManager;

  void nextTurn() {
    unitManager.factionUnits[gameState.currentFaction]..values.forEach((entity) => um.get(entity).nextTurn());
    spawnerManager.factionSpawner[gameState.currentFaction].values.forEach((entity) => sm.get(entity).spawnTime--);

    gameState.nextFaction();

    unitManager.factionUnits[gameState.currentFaction].values.forEach(recoverConquarable);
    spawnerManager.factionSpawner[gameState.currentFaction].values.forEach(spawnerManager.spawn);
    tileManager.spreadFactionInfluence(gameState.currentFaction);

    world.createAndAddEntity([new NextTurnInfo()]);
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
                                         F_ICE: new List.generate(TILES_X, (_) => new List.generate(TILES_Y, (_) => false)),
                                         F_NEUTRAL: new List.generate(TILES_X, (_) => new List.generate(TILES_Y, (_) => false)),
                                        };

  void uncoverTiles(Entity entity) {
    var t = tm.get(entity);
    var u = um.get(entity);

    for (int y = -u.viewRange; y <= u.viewRange; y++) {
      for (int x = -u.viewRange; x <= u.viewRange; x++) {
        if (x.abs() + y.abs() <= u.viewRange && t.x + x >= 0 && t.x + x < TILES_X && t.y + y >= 0 && t.y + y < TILES_Y) {
          tiles[u.faction][t.x + x][t.y + y] = true;
        }
      }
    }
    hasChanges = true;
  }
}

class TileManager extends Manager {
  ComponentMapper<Tile> tileMapper;
  ComponentMapper<Transform> tm;
  ComponentMapper<Unit> um;
  SpawnerManager spawnerManager;

  List<Entity> tiles = new List(TILES_X * TILES_Y);
  List<List<Entity>> tilesByCoord = new List.generate(TILES_X, (_) => new List(TILES_Y));

  @override
  void added(Entity entity) {
    if (tileMapper.has(entity)) {
      var t = tm.get(entity);
      var x = t.x;
      var y = t.y;
      tilesByCoord[x][y] = entity;
      tiles[y * TILES_X + x] = entity;
      entity.addComponent(new Redraw());
    }
  }


  void growInfluence(Entity unitEntity, String faction, {bool captured: false}) {
    var t = tm.get(unitEntity);
    var tile = tilesByCoord[t.x][t.y];
    var unit = um.get(unitEntity);
    var currentFaction = tileMapper.get(tile).faction;
    if (!captured) {
      unit.influenceWeight += 0.1;
    } else {
      tileMapper.get(tile).faction = faction;
      tileMapper.get(tile).influence = unit.influence;
      unit.influenceWeight = 1.0;
      tile..addComponent(new Redraw())
          ..changedInWorld();
    }
    var baseInfluence = unit.influence * unit.influenceWeight;
    tileMapper.get(tile).influence = baseInfluence;

    var visited = <int>[];
    var open = new Queue<int>()..add(t.y * TILES_X + t.x);
    while (open.isNotEmpty) {
      var currentTileId = open.removeFirst();
      var currentTile = tileMapper.get(tiles[currentTileId]);
      var distance = ((currentTileId % TILES_X - t.x).abs() + (currentTileId ~/ TILES_X - t.y).abs()) + 1;
      var newInfluence = baseInfluence * INFLUENCE_FACTOR / (distance * distance);
      visitTile(currentTileId, visited, open, (nextTileId) {
        var nextTile = tileMapper.get(tiles[nextTileId]);
        if (faction != currentTile.faction) {
          return false;
        }
        return true;
      }, (nextTileId) {
        var nextTileEntity = tiles[nextTileId];
        var nextTile = tileMapper.get(nextTileEntity);
        var oldFaction = nextTile.faction;
        if (oldFaction != faction) {
          if (nextTile.influence < newInfluence) {
            nextTile.influence = newInfluence;
            nextTile.faction = faction;
            nextTileEntity..addComponent(new Redraw())
                          ..changedInWorld();
          } else {
            nextTile.influence -= newInfluence;
          }
        } else {
          if (nextTile.influence < newInfluence) {
            nextTile.influence = newInfluence;
          } else {
            nextTile.influence += 0.1 * newInfluence;
          }
        }
      });
    }
  }

  void spreadFactionInfluence(String faction) {
    spawnerManager.factionSpawner[faction].values.forEach((entity) {
      growInfluence(entity, faction);
    });
  }

  void initInfluence() {
//    spawnerManager.factionSpawner.values.expand((entityMap) => entityMap.values).map((entity) {
//      var t = tm.get(entity);
//      tileMapper.get(tilesByCoord[t.x][t.y]).influenceWeight = 1.0;
//      return entity;
//    }).forEach((entity) {
//      var u = um.get(entity);
//      var t = tm.get(entity);
//      var visited = <int>[];
//      var open = new Queue<int>()..add(t.y * TILES_X + t.x);
//      while (open.isNotEmpty) {
//        var currentTileId = open.removeFirst();
//        var currentTile = tileMapper.get(tiles[currentTileId]);
//        visitTile(currentTileId, visited, open, (nextTileId) {
//          var nextTile = tileMapper.get(tiles[nextTileId]);
//          if (nextTile.influenceWeight < currentTile.influenceWeight * INFLUENCE_FACTOR) {
//            return true;
//          }
//          return false;
//        }, (nextTileId) {
//          tileMapper.get(tiles[nextTileId]).influenceWeight = currentTile.influenceWeight * INFLUENCE_FACTOR;
//        });
//      }
//    });
    FACTIONS.forEach((faction) => spawnerManager.factionSpawner[faction].values.forEach((entity) => growInfluence(entity, faction, captured: true)));
  }

  void visitTile(int tileId, List<int> visited, Queue<int> open, AddToQueueCondition addToQueueCondition, AddToQueueAction addToQueueAction) {
    visited.add(tileId);
    var directions = <int>[-TILES_X, TILES_X];
    if (tileId % TILES_X != 0) {
      directions.add(-1);
    }
    if (tileId % TILES_X != TILES_X - 1) {
      directions.add(1);
    }
    for (var direction in directions) {
      var target = tileId + direction;
      if (target < 0 || target >= MAX_TILES) {
        continue;
      }
      if (!visited.contains(target)
          && !open.contains(target)
          && addToQueueCondition(target)) {
        addToQueueAction(target);
        open.add(target);
      }
    }
  }
}
