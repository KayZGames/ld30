part of shared;

class SpawnerManager extends Manager {
  ComponentMapper<Transform> tm;
  ComponentMapper<Spawner> sm;
  ComponentMapper<Unit> um;
  UnitManager unitManager;
  FogOfWarManager fowManager;
  GameManager gameManager;

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
        if (null == unitManager.getSelectedUnit(gameManager.currentFaction)) {
          components.add(new Selected());
        }
        var spawnedEntity = world.createAndAddEntity(components);
        s.spawnTime = s.maxSpawnTime;
        fowManager.uncoverTiles(spawnedEntity);
      }
    }
  }
}
