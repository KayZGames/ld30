part of client;

class TileRenderingSystem extends EntityProcessingSystem {
  ComponentMapper<Tile> tileMapper;
  ComponentMapper<Transform> tm;

  CanvasRenderingContext2D ctx;
  CanvasElement tileBuffer;
  CanvasRenderingContext2D bufferCtx;
  SpriteSheet sheet;
  TileRenderingSystem(this.ctx, this.sheet) : super(Aspect.getAspectForAllOf([Tile, Redraw]));

  @override
  void initialize() {
    tileBuffer = new CanvasElement(width: TILES_X * TILE_SIZE, height: TILES_Y * TILE_SIZE);
    bufferCtx = tileBuffer.context2D;
  }

  @override
  void processEntity(Entity entity) {
    var tile = tileMapper.get(entity);
    var t = tm.get(entity);
    var sprite = sheet.sprites['ground_${tile.faction}_${tile.variant}'];
    bufferCtx.drawImageScaledFromSource(sheet.image, sprite.src.left, sprite.src.top, sprite.src.width, sprite.src.height, t.x * TILE_SIZE, t.y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
    entity..removeComponent(Redraw)
          ..changedInWorld();
  }

  @override
  void end() {
    ctx.drawImage(tileBuffer, 0, 0);
  }

  @override
  bool checkProcessing() => !gameState.menu;
}
