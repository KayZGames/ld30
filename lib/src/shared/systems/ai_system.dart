part of shared;

class AiSystem extends VoidEntitySystem {
  final directions = <List<int>>[[1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [-1, -1], [1, -1], [-1, 1]];

  ComponentMapper<Transform> tm;

  UnitManager unitManager;
  TurnManager turnManager;
  FogOfWarManager fowManager;

  ComponentMapper<Unit> um;

  Bag<int> targetTiles = new Bag<int>();
  Bag<Queue<TerrainTile>> targetPath = new Bag<Queue<TerrainTile>>();
  TerrainMap terrainMap;

  @override
  void initialize() {
    terrainMap = new TerrainMap(unitManager);
  }

  @override
  void processSystem() {
    var faction = gameState.currentFaction;
    var entity = unitManager.getSelectedUnit(faction);
    if (entity == null || um.get(entity).movesLeft <= 0) {
      entity = unitManager.getNextUnit(faction);
    }
    if (null == entity) {
      turnManager.nextTurn();
    } else {
      var t = tm.get(entity);
      var target = null;
      if (targetTiles.isIndexWithinBounds(entity.id)) {
        target = targetTiles[entity.id];
      }
      if (target == null || unitManager.isFriendlyUnit(faction, target % gameState.sizeX, target ~/ gameState.sizeX)) {
        targetPath[entity.id] = null;
        var visibleTiles = fowManager.tiles[faction];
        var visited = new Set<int>.from([t.y * gameState.sizeX + t.x]);
        target = getNextTarget(visibleTiles, t.x, t.y, new Queue<int>(), visited);
        targetTiles[entity.id] = target;
      }
      var path = null;
      if (targetPath.isIndexWithinBounds(entity.id)) {
        path = targetPath[entity.id];
      }
      if (null == path) {
        terrainMap.reset();
        var pathFinder = new AStar<TerrainTile>(terrainMap);
        path = pathFinder.findPathSync(terrainMap.nodes[t.y * gameState.sizeX + t.x], terrainMap.nodes[target]);
        if (path.length > 1) {
          path.removeFirst();
          targetPath[entity.id] = path;
        }
      }
      if (path.length > 0) {
        var tile = path.removeFirst();
        entity..addComponent(new Move(tile.x - t.x, tile.y - t.y))
              ..changedInWorld();
      } else {
        var direction = directions[random.nextInt(directions.length)];
        entity..addComponent(new Move(direction[0], direction[1]))
              ..changedInWorld();
      }
    }
  }

  int getNextTarget(List<List<bool>> visibleTiles, int x, int y, Queue<int> unvisited, Set<int> visited) {
    if (visibleTiles[x][y] == true && !unitManager.isTileEmpty(x, y) && !unitManager.isFriendlyUnit(gameState.currentFaction, x, y)) {
      return y * gameState.sizeX + x;
    } else if (visibleTiles[x][y] == false) {
      return y * gameState.sizeX + x;
    }
    var target = null;
    var randomDirections = new List.from(directions)..shuffle(random);
    for (List<int> direction in randomDirections) {
      var nextX = x + direction[0];
      var nextY = y + direction[1];
      var tile = nextY * gameState.sizeX + nextX;
      if (!unvisited.contains(tile) && !visited.contains(tile) && nextX >= 0 && nextY >= 0 && nextX < gameState.sizeX && nextY < gameState.sizeY) {
        unvisited.add(tile);
      }
    }
    target = unvisited.removeFirst();
    visited.add(target);
    return getNextTarget(visibleTiles, target % gameState.sizeX, target ~/ gameState.sizeX, unvisited, visited);
  }

  @override
  bool checkProcessing() => gameState.currentFaction != gameState.playerFaction && !gameState.menu;
}
