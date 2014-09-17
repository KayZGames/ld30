part of client;

class RenderingSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<Renderable> rm;
  ComponentMapper<Unit> um;
  GameManager gameManager;
  TagManager tagManager;

  CanvasRenderingContext2D ctx;
  CanvasElement buffer;
  CanvasRenderingContext2D bufferCtx;
  SpriteSheet sheet;
  RenderingSystem(this.ctx, this.sheet) : super(Aspect.getAspectForAllOf([Transform, Renderable, Unit]));

  @override
  void initialize() {
    eventBus.on(GameStartedEvent).listen((_) {
      buffer = new CanvasElement(width: gameManager.sizeX * TILE_SIZE, height: gameManager.sizeY * TILE_SIZE);
      bufferCtx = buffer.context2D;
    });
  }

  @override
  void begin() {
    bufferCtx.clearRect(0, 0, buffer.width, buffer.height);
  }

  @override
  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var r = rm.get(entity);
    var u = um.get(entity);

    var sprite = sheet.sprites['${r.name}_${u.faction}'];
    bufferCtx.drawImageScaledFromSource(sheet.image, sprite.src.left, sprite.src.top, sprite.src.width, sprite.src.height,
        t.x * TILE_SIZE + sprite.offset.x + TILE_SIZE/2 + t.displacementX,
        t.y * TILE_SIZE + sprite.offset.y + TILE_SIZE/2 + t.displacementY,
        sprite.dst.width, sprite.dst.height);
  }

  @override
  void end() {
    var cameraEntity = tagManager.getEntity('camera');
    var cameraTransform = tm.get(cameraEntity);
    var cameraRect = new Rectangle(cameraTransform.x, cameraTransform.y, 800, 600);
    ctx.drawImageToRect(buffer, cameraRect, sourceRect: cameraRect);
  }

  @override
  bool checkProcessing() => gameManager.gameIsRunning;
}
