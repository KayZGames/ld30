part of shared;

class AiSystem extends VoidEntitySystem {
  final directions = <List<int>>[[1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [-1, -1], [1, -1], [-1, 1]];

  ComponentMapper<Transform> tm;
  ComponentMapper<Move> mm;
  ComponentMapper<Attacker> am;
  ComponentMapper<Defender> dm;

  UnitManager unitManager;
  TurnManager turnManager;
  FogOfWarManager fowManager;
  GameManager gameManager;

  ComponentMapper<Unit> um;

  Bag<int> targetTiles = new Bag<int>();
  Bag<Queue<TerrainTile>> targetPath = new Bag<Queue<TerrainTile>>();
  TerrainMap terrainMap;

  @override
  void initialize() {
    terrainMap = new TerrainMap(gameManager, unitManager);
  }

  @override
  void begin() {
    world.processEntityChanges();
  }

  @override
  void processSystem() {
    var faction = gameManager.currentFaction;
    var entity = unitManager.getSelectedUnit(faction);
    if (entity == null || um.get(entity).movesLeft <= 0) {
      entity = unitManager.getNextUnit(faction);
    }
    if (null == entity) {
      turnManager.nextTurn();
    } else if (mm.has(entity) || am.has(entity) || dm.has(entity)) {
      // entity is still occupied
      return;
    } else {
      var t = tm.get(entity);
      var target = null;
      if (targetTiles.isIndexWithinBounds(entity.id)) {
        target = targetTiles[entity.id];
      }
      if (target == null || unitManager.isFriendlyUnit(faction, target % gameManager.sizeX, target ~/ gameManager.sizeX)) {
        targetPath[entity.id] = null;
        var visibleTiles = fowManager.tiles[faction];
        var visited = new Set<int>.from([t.y * gameManager.sizeX + t.x]);
        target = getNextTarget(visibleTiles, t.x, t.y, new Queue<int>(), visited);
        targetTiles[entity.id] = target;
      }
      var path = null;
      if (targetPath.isIndexWithinBounds(entity.id)) {
        path = targetPath[entity.id];
      }
      if (null == path && null != target) {
        terrainMap.reset();
        var pathFinder = new AStar<TerrainTile>(terrainMap);
        path = pathFinder.findPathSync(terrainMap.nodes[t.y * gameManager.sizeX + t.x], terrainMap.nodes[target]);
        if (path.length > 1) {
          path.removeFirst();
          targetPath[entity.id] = path;
        }
      }
      if (null == path) {
        // no path, no target, no enemy, game over
        turnManager.nextTurn();
      } else if (path.length > 0) {
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
    if (visibleTiles[x][y] == true && !unitManager.isTileEmpty(x, y) && !unitManager.isFriendlyUnit(gameManager.currentFaction, x, y)) {
      return y * gameManager.sizeX + x;
    } else if (visibleTiles[x][y] == false) {
      return y * gameManager.sizeX + x;
    }
    var target = null;
    var randomDirections = new List.from(directions)..shuffle(random);
    for (List<int> direction in randomDirections) {
      var nextX = x + direction[0];
      var nextY = y + direction[1];
      var tile = nextY * gameManager.sizeX + nextX;
      if (!unvisited.contains(tile) && !visited.contains(tile) && nextX >= 0 && nextY >= 0 && nextX < gameManager.sizeX && nextY < gameManager.sizeY) {
        unvisited.add(tile);
      }
    }
    if (unvisited.length == 0) {
      return null;
    }
    target = unvisited.removeFirst();
    visited.add(target);
    return getNextTarget(visibleTiles, target % gameManager.sizeX, target ~/ gameManager.sizeX, unvisited, visited);
  }

  @override
  bool checkProcessing() => gameManager.currentFaction != gameManager.playerFaction && !gameManager.menu;
}
