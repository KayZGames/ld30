part of shared;

class TileManager extends Manager {
  ComponentMapper<Tile> tileMapper;
  ComponentMapper<Transform> tm;
  ComponentMapper<Unit> um;
  SpawnerManager spawnerManager;

  List<Entity> tiles = new List(gameState.sizeX * gameState.sizeY);
  List<List<Entity>> tilesByCoord = new List.generate(gameState.sizeX, (_) => new List(gameState.sizeY));

  @override
  void added(Entity entity) {
    if (tileMapper.has(entity)) {
      var t = tm.get(entity);
      var x = t.x;
      var y = t.y;
      tilesByCoord[x][y] = entity;
      tiles[y * gameState.sizeX + x] = entity;
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
    var open = new Queue<int>()..add(t.y * gameState.sizeX + t.x);
    while (open.isNotEmpty) {
      var currentTileId = open.removeFirst();
      var currentTile = tileMapper.get(tiles[currentTileId]);
      var distance = ((currentTileId % gameState.sizeX - t.x).abs() + (currentTileId ~/ gameState.sizeX - t.y).abs()) + 1;
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
    FACTIONS.forEach((faction) => spawnerManager.factionSpawner[faction].values.forEach((entity) => growInfluence(entity, faction, captured: true)));
  }

  void visitTile(int tileId, List<int> visited, Queue<int> open, AddToQueueCondition addToQueueCondition, AddToQueueAction addToQueueAction) {
    visited.add(tileId);
    var directions = <int>[-gameState.sizeX, gameState.sizeX];
    if (tileId % gameState.sizeX != 0) {
      directions.add(-1);
    }
    if (tileId % gameState.sizeX != gameState.sizeX - 1) {
      directions.add(1);
    }
    for (var direction in directions) {
      var target = tileId + direction;
      if (target < 0 || target >= gameState.maxTiles) {
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
