part of shared;

class TerrainTile extends Object with Node {
  int x, y;
  TerrainTile(this.x, this.y);
}


class TerrainMap implements Graph<TerrainTile> {
  UnitManager unitManager;
  GameManager gameManager;
  var nodes;
  TerrainMap(GameManager gameManager, this.unitManager) : gameManager = gameManager,
      nodes = new List<TerrainTile>.generate(gameManager.sizeX * gameManager.sizeY, (index) => new TerrainTile(index % gameManager.sizeX, index ~/ gameManager.sizeY));

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
      neighbours.add(nodes[node.y * gameManager.sizeX + node.x - 1]);
    }
    // east
    if (node.x < gameManager.sizeX - 1) {
      neighbours.add(nodes[node.y * gameManager.sizeX + node.x + 1]);
    }
    // north
    if (node.y > 0) {
      neighbours.add(nodes[node.y * gameManager.sizeX + node.x - gameManager.sizeX]);
    }
    // south
    if (node.y < gameManager.sizeY - 1) {
      neighbours.add(nodes[node.y * gameManager.sizeX + node.x + gameManager.sizeX]);
    }

    // northwest
    if (node.x > 0 && node.y > 0) {
      neighbours.add(nodes[node.y * gameManager.sizeX + node.x - gameManager.sizeX - 1]);
    }
    // northeast
    if (node.y > 0 && node.x < gameManager.sizeX - 1) {
      neighbours.add(nodes[node.y * gameManager.sizeX + node.x - gameManager.sizeX + 1]);
    }
    // southwest
    if (node.y < gameManager.sizeY - 1 && node.x > 0) {
      neighbours.add(nodes[node.y * gameManager.sizeX + node.x + gameManager.sizeX - 1]);
    }
    // southeast
    if (node.x < gameManager.sizeX - 1 && node.y < gameManager.sizeY - 1) {
      neighbours.add(nodes[node.y * gameManager.sizeX + node.x + gameManager.sizeX + 1]);
    }
    return neighbours;
  }

  void reset() {
    nodes = new List<TerrainTile>.generate(gameManager.sizeX * gameManager.sizeY, (index) => new TerrainTile(index % gameManager.sizeX, index ~/ gameManager.sizeX));
  }
}