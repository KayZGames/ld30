part of client;

class TileRenderingSystem extends EntityProcessingSystem {
  Mapper<Tile> tileMapper;
  Mapper<Transform> tm;
  TagManager tagManager;
  TileManager tileManager;
  GameManager gameManager;

  Map<String, CanvasElement> factionTileMasks;
  Map<String, CanvasElement> factionTiles;
  Map<String, CanvasElement> factionTileBuffer;
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
    eventBus.on(GameStartedEvent).listen((_) {
      factionTileMasks = new Map.fromIterable(FACTIONS, key: (key) => key, value: (_) => new CanvasElement(width: gameManager.sizeX, height: gameManager.sizeY));
      factionTiles = new Map.fromIterable(FACTIONS, key: (key) => key, value: (_) => new CanvasElement(width: gameManager.sizeX * TILE_SIZE, height: gameManager.sizeY * TILE_SIZE));
      factionTileBuffer = new Map.fromIterable(FACTIONS, key: (key) => key, value: (_) => new CanvasElement(width: gameManager.sizeX * TILE_SIZE, height: gameManager.sizeY * TILE_SIZE));
      neutralTileBuffer = new CanvasElement(width: gameManager.sizeX * TILE_SIZE, height: gameManager.sizeY * TILE_SIZE);
      neutralTileBufferCtx = neutralTileBuffer.context2D;
      buffer = new CanvasElement(width: gameManager.sizeX * TILE_SIZE, height: gameManager.sizeY * TILE_SIZE);
      bufferCtx = buffer.context2D;
      factionTileMasks.values.forEach((canvas) => canvas.context2D.fillStyle = 'black');
      initTileBuffers();
    });
  }

  void initTileBuffers() {
    for (int y = 0; y < gameManager.sizeY; y++) {
      for (int x = 0; x < gameManager.sizeX; x++) {
        var variant = random.nextInt(7);
        var counter = 0;
        // make tile 6 a bit more rare
        while (variant == 6 && ++counter < 20) {
          variant = random.nextInt(7);
        }
        var sprite = sheet.sprites['ground_neutral_${variant}'];
        neutralTileBufferCtx.drawImageScaledFromSource(sheet.image, sprite.src.left, sprite.src.top, sprite.src.width, sprite.src.height, x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
        factionTiles.forEach((faction, canvas) {
          sprite = sheet.sprites['ground_${faction}_${variant}'];
          canvas.context2D.drawImageScaledFromSource(sheet.image, sprite.src.left, sprite.src.top, sprite.src.width, sprite.src.height, x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
        });
      }
    }
  }

  @override
  void processEntity(Entity entity) {
    var tile = tileMapper[entity];
    var t = tm[entity];
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
    var cameraTransform = tm[cameraEntity];
    var cameraRect = new Rectangle(cameraTransform.x, cameraTransform.y, 800, 600);
    if (changes) {
      changes = false;
      factionTileBuffer.forEach((faction, canvas) {
        canvas.context2D..clearRect(0, 0, gameManager.sizeX * TILE_SIZE, gameManager.sizeY * TILE_SIZE)
                        ..drawImageScaledFromSource(factionTileMasks[faction], 0, 0, gameManager.sizeX, gameManager.sizeY, 0, 0, gameManager.sizeX * TILE_SIZE, gameManager.sizeY * TILE_SIZE)
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
  bool checkProcessing() => gameManager.gameIsRunning;
}
