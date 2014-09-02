part of client;

class TileRenderingSystem extends EntityProcessingSystem {
  ComponentMapper<Tile> tileMapper;
  ComponentMapper<Transform> tm;
  TagManager tagManager;
  TileManager tileManager;

  Map<String, CanvasElement> factionTileMasks = new Map.fromIterable(FACTIONS, key: (key) => key, value: (_) => new CanvasElement(width: TILES_X, height: TILES_Y));
  Map<String, CanvasElement> factionTiles = new Map.fromIterable(FACTIONS, key: (key) => key, value: (_) => new CanvasElement(width: TILES_X * TILE_SIZE, height: TILES_Y * TILE_SIZE));
  Map<String, CanvasElement> factionTileBuffer = new Map.fromIterable(FACTIONS, key: (key) => key, value: (_) => new CanvasElement(width: TILES_X * TILE_SIZE, height: TILES_Y * TILE_SIZE));
  bool changes = true;

  CanvasRenderingContext2D ctx;
  CanvasElement neutralTileBuffer;
  CanvasRenderingContext2D neutralTileBufferCtx;
  CanvasElement buffer;
  CanvasRenderingContext2D bufferCtx;
  SpriteSheet sheet;
  TileRenderingSystem(this.ctx, this.sheet) : super(Aspect.getAspectForAllOf([Tile, Redraw]));

  @override
  void initialize() {
    neutralTileBuffer = new CanvasElement(width: TILES_X * TILE_SIZE, height: TILES_Y * TILE_SIZE);
    neutralTileBufferCtx = neutralTileBuffer.context2D;
    buffer = new CanvasElement(width: TILES_X * TILE_SIZE, height: TILES_Y * TILE_SIZE);
    bufferCtx = buffer.context2D;
    factionTileMasks.values.forEach((canvas) => canvas.context2D.fillStyle = 'black');
  }

  void initTileBuffers() {
    tileManager.tiles.forEach((entity) {
      var tile = tileMapper.get(entity);
        var t = tm.get(entity);
        var sprite = sheet.sprites['ground_neutral_${tile.variant}'];
        neutralTileBufferCtx.drawImageScaledFromSource(sheet.image, sprite.src.left, sprite.src.top, sprite.src.width, sprite.src.height, t.x * TILE_SIZE, t.y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
        factionTiles.forEach((faction, canvas) {
          sprite = sheet.sprites['ground_${faction}_${tile.variant}'];
          canvas.context2D.drawImageScaledFromSource(sheet.image, sprite.src.left, sprite.src.top, sprite.src.width, sprite.src.height, t.x * TILE_SIZE, t.y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
        });
    });
  }

  @override
  void processEntity(Entity entity) {
    var tile = tileMapper.get(entity);
    var t = tm.get(entity);
    factionTileMasks.forEach((faction, canvas) {
      if (faction == tile.faction) {
        canvas.context2D.fillRect(t.x, t.y, 1, 1);
      } else {
        canvas.context2D.clearRect(t.x, t.y, 1, 1);
      }
    });
    changes = true;
    entity..removeComponent(Redraw)
          ..changedInWorld();
  }

  @override
  void end() {
    var cameraEntity = tagManager.getEntity('camera');
    var cameraTransform = tm.get(cameraEntity);
    var cameraRect = new Rectangle(cameraTransform.x, cameraTransform.y, 800, 600);
    if (changes) {
      changes = false;
      factionTileBuffer.forEach((faction, canvas) {
        canvas.context2D..clearRect(0, 0, TILES_X * TILE_SIZE, TILES_Y * TILE_SIZE)
                        ..drawImageScaledFromSource(factionTileMasks[faction], 0, 0, TILES_X, TILES_Y, 0, 0, TILES_X * TILE_SIZE, TILES_Y * TILE_SIZE)
                        ..globalCompositeOperation = 'source-atop'
                        ..drawImage(factionTiles[faction], 0, 0)
                        ..globalCompositeOperation = 'source-over';
      });
      bufferCtx.drawImage(neutralTileBuffer, 0, 0);
      factionTileBuffer.forEach((faction, canvas) {
        bufferCtx.drawImage(canvas, 0, 0);
      });
    }
    ctx.drawImageToRect(buffer, cameraRect, sourceRect: cameraRect);
  }

  @override
  bool checkProcessing() => !gameState.menu;
}
