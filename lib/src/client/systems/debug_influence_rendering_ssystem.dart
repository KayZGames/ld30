part of client;

class DebugInfluenceRenderingSsystem extends VoidEntitySystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<Tile> tileMapper;
  TileManager tileManager;
  TagManager tagManager;

  CanvasRenderingContext2D ctx;
  DebugInfluenceRenderingSsystem(this.ctx);

  @override
  void begin() {
    ctx.save();
  }

  @override
  void end() {
    ctx.restore();
  }

  @override
  void processSystem() {
    var camereaEntity = tagManager.getEntity('camera');
    var cameraTransform = tm.get(camereaEntity);
    int minX = cameraTransform.x ~/ TILE_SIZE;
    int minY = cameraTransform.y ~/ TILE_SIZE;
    for (int y = minY; y < minY + 8; y++) {
      for (int x = minX; x < minX + 10; x++) {
        ctx..fillStyle = 'cyan'
           ..fillText('${tileMapper.get(tileManager.tilesByCoord[x][y]).influence.toStringAsFixed(2)}', x * TILE_SIZE, 20 + y * TILE_SIZE);
      }
    }
  }
}