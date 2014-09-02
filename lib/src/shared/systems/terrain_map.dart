part of shared;

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