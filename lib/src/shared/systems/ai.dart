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
      if (target == null || unitManager.isFriendlyUnit(faction, target % TILES_X, target ~/ TILES_X)) {
        targetPath[entity.id] = null;
        var visibleTiles = fowManager.tiles[faction];
        var visited = new Set<int>.from([t.y * TILES_X + t.x]);
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
        path = pathFinder.findPathSync(terrainMap.nodes[t.y * TILES_X + t.x], terrainMap.nodes[target]);
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
      return y * TILES_X + x;
    } else if (visibleTiles[x][y] == false) {
      return y * TILES_X + x;
    }
    var target = null;
    var randomDirections = new List.from(directions)..shuffle(random);
    for (List<int> direction in randomDirections) {
      var nextX = x + direction[0];
      var nextY = y + direction[1];
      var tile = nextY * TILES_X + nextX;
      if (!unvisited.contains(tile) && !visited.contains(tile) && nextX >= 0 && nextY >= 0 && nextX < TILES_X && nextY < TILES_Y) {
        unvisited.add(tile);
      }
    }
    target = unvisited.removeFirst();
    visited.add(target);
    return getNextTarget(visibleTiles, target % TILES_X, target ~/ TILES_X, unvisited, visited);
  }

  @override
  bool checkProcessing() => gameState.currentFaction != gameState.playerFaction && !gameState.menu;
}

class TerrainTile extends Object with Node {
  int x, y;
  TerrainTile(this.x, this.y);
}

class TerrainMap implements Graph<TerrainTile> {
  UnitManager unitManager;
  var nodes = new List<TerrainTile>.generate(TILES_X * TILES_Y, (index) => new TerrainTile(index % TILES_X, index ~/ TILES_Y));
  TerrainMap(this.unitManager);

  @override
  Iterable<TerrainTile> get allNodes => nodes;

  @override
  num getDistance(TerrainTile a, TerrainTile b) {
    if (unitManager.isTileEmpty(b.x, b.y)) {
      return (a.x - b.x).abs() + (a.y - b.y).abs();
    }
    return 1000.0;
  }

  @override
  num getHeuristicDistance(TerrainTile a, TerrainTile b) => getDistance(a, b);

  @override
  Iterable<TerrainTile> getNeighboursOf(TerrainTile node) {
    List<TerrainTile> neighbours = new List();
    // west
    if (node.x > 0) {
      neighbours.add(nodes[node.y * TILES_X + node.x - 1]);
    }
    // east
    if (node.x < TILES_X - 1) {
      neighbours.add(nodes[node.y * TILES_X + node.x + 1]);
    }
    // north
    if (node.y > 0) {
      neighbours.add(nodes[node.y * TILES_X + node.x - TILES_X]);
    }
    // south
    if (node.y < TILES_Y - 1) {
      neighbours.add(nodes[node.y * TILES_X + node.x + TILES_X]);
    }

    // northwest
    if (node.x > 0 && node.y > 0) {
      neighbours.add(nodes[node.y * TILES_X + node.x - TILES_X - 1]);
    }
    // northeast
    if (node.y > 0 && node.x < TILES_X - 1) {
      neighbours.add(nodes[node.y * TILES_X + node.x - TILES_X + 1]);
    }
    // southwest
    if (node.y < TILES_Y - 1 && node.x > 0) {
      neighbours.add(nodes[node.y * TILES_X + node.x + TILES_X - 1]);
    }
    // southeast
    if (node.x < TILES_X - 1 && node.y < TILES_Y - 1) {
      neighbours.add(nodes[node.y * TILES_X + node.x + TILES_X + 1]);
    }
    return neighbours;
  }

  void reset() {
    nodes = new List<TerrainTile>.generate(TILES_X * TILES_Y, (index) => new TerrainTile(index % TILES_X, index ~/ TILES_X));
  }
}