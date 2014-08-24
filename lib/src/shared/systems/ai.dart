part of shared;

class AiSystem extends VoidEntitySystem {
  final directions = <List<int>>[[1, 0], [-1, 0], [0, 1], [0, -1]];

  ComponentMapper<Transform> tm;

  UnitManager unitManager;
  TurnManager turnManager;
  FogOfWarManager fowManager;

  ComponentMapper<Unit> um;

  Map<String, Bag<int>> targetTiles = {F_HELL: new Bag<int>(),
                                       F_HEAVEN: new Bag<int>(),
                                       F_ICE: new Bag<int>(),
                                       F_FIRE: new Bag<int>(),
                                       };

  @override
  void processSystem() {
    var entity = unitManager.getSelectedUnit(gameState.currentFaction);
    if (entity == null || um.get(entity).movesLeft <= 0) {
      entity = unitManager.getNextUnit(gameState.currentFaction);
    }
    if (null == entity) {
      turnManager.nextTurn();
    } else {
      var t = tm.get(entity);
      var target = null;
      if (targetTiles[gameState.currentFaction].isIndexWithinBounds(entity.id)) {
        target = targetTiles[gameState.currentFaction][entity.id];
      }
      if (target == null || target ~/ TILES_X == t.x && target % TILES_Y == t.y) {
        var visibleTiles = fowManager.tiles[gameState.currentFaction];
        var visited = new Set<int>.from([t.x * TILES_X + t.y]);
        target = getNextHiddenTile(visibleTiles, t.x, t.y, visited);
        targetTiles[gameState.currentFaction][entity.id] = target;
        print('found next target for ${entity.id} of ${gameState.currentFaction}: ${target ~/ TILES_X}:${target % TILES_Y}');
      }

      var direction = directions[random.nextInt(directions.length)];
      entity..addComponent(new Move(direction[0], direction[1]))
            ..changedInWorld();
    }
  }

  int getNextHiddenTile(List<List<bool>> visibleTiles, int x, int y, Set<int> visited) {
    if (visibleTiles[x][y] == false) {
      return x * TILES_X + y;
    }
    var target = null;
    var randomDirections = new List.from(directions)..shuffle(random);
    for (List<int> direction in randomDirections) {
      var nextX = x + direction[0];
      var nextY = y + direction[1];
      var tile = nextX * TILES_X + nextY;
      if (!visited.contains(tile) && nextX >= 0 && nextY >= 0 && nextX < TILES_X && nextY < TILES_Y) {
        visited.add(tile);
        target = getNextHiddenTile(visibleTiles, nextX, nextY, visited);
        if (null != target) {
          return target;
        }
      }
    }
    return null;
  }

  @override
  bool checkProcessing() => gameState.currentFaction != gameState.playerFaction;
}