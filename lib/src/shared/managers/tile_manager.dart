part of shared;

class TileManager extends Manager {
  Mapper<Tile> tileMapper;
  Mapper<Transform> tm;
  Mapper<Unit> um;
  SpawnerManager spawnerManager;
  GameManager gameManager;

  List<Entity> tiles;
  List<List<Entity>> tilesByCoord;

  @override
  void initialize() {
    eventBus.on(GameStartedEvent).listen((_) {
      tiles = new List(gameManager.sizeX * gameManager.sizeY);
      tilesByCoord = new List.generate(gameManager.sizeX, (_) => new List(gameManager.sizeY));
    });
  }

  @override
  void added(Entity entity) {
    if (tileMapper.has(entity)) {
      var t = tm[entity];
      var x = t.x;
      var y = t.y;
      tilesByCoord[x][y] = entity;
      tiles[y * gameManager.sizeX + x] = entity;
      entity.addComponent(new Redraw());
    }
  }


  void growInfluence(Entity unitEntity, String faction, {bool captured: false}) {
    var t = tm[unitEntity];
    var tile = tilesByCoord[t.x][t.y];
    var unit = um[unitEntity];
    if (!captured) {
      unit.influenceWeight += 0.1;
    } else {
      tileMapper[tile].faction = faction;
      tileMapper[tile].influence = unit.influence;
      unit.influenceWeight = 1.0;
      tile..addComponent(new Redraw())
          ..changedInWorld();
    }
    var baseInfluence = unit.influence * unit.influenceWeight;
    tileMapper[tile].influence = baseInfluence;

    var visited = <int>[];
    var open = new Queue<int>()..add(t.y * gameManager.sizeX + t.x);
    while (open.isNotEmpty) {
      var currentTileId = open.removeFirst();
      var currentTile = tileMapper[tiles[currentTileId]];
      var distance = ((currentTileId % gameManager.sizeX - t.x).abs() + (currentTileId ~/ gameManager.sizeX - t.y).abs()) + 1;
      var newInfluence = baseInfluence * INFLUENCE_FACTOR / (distance * distance);
      visitTile(currentTileId, visited, open, (nextTileId) {
        if (faction != currentTile.faction) {
          return false;
        }
        return true;
      }, (nextTileId) {
        var nextTileEntity = tiles[nextTileId];
        var nextTile = tileMapper[nextTileEntity];
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
    FACTIONS.forEach((faction) => spawnerManager.factionSpawner[faction].values.forEach((entity) => growInfluence(entity, faction, captured: true)));
  }

  void visitTile(int tileId, List<int> visited, Queue<int> open, AddToQueueCondition addToQueueCondition, AddToQueueAction addToQueueAction) {
    visited.add(tileId);
    var directions = <int>[-gameManager.sizeX, gameManager.sizeX];
    if (tileId % gameManager.sizeX != 0) {
      directions.add(-1);
    }
    if (tileId % gameManager.sizeX != gameManager.sizeX - 1) {
      directions.add(1);
    }
    for (var direction in directions) {
      var target = tileId + direction;
      if (target < 0 || target >= gameManager.maxTiles) {
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
