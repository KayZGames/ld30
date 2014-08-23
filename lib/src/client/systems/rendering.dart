part of client;


class RenderingSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<Renderable> rm;

  CanvasRenderingContext2D ctx;
  SpriteSheet sheet;
  RenderingSystem(this.ctx, this.sheet) : super(Aspect.getAspectForAllOf([Transform, Renderable]));


  @override
  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var r = rm.get(entity);

    var sprite = sheet.sprites[r.name];
    ctx.drawImageScaledFromSource(sheet.image, sprite.src.left, sprite.src.top, sprite.src.width, sprite.src.height, t.x * TILE_SIZE + sprite.offset.x + TILE_SIZE/2, t.y * TILE_SIZE + sprite.offset.y + TILE_SIZE/2, sprite.dst.width, sprite.dst.height);
  }
}

class TileRenderingSystem extends VoidEntitySystem {

  CanvasRenderingContext2D ctx;
  CanvasElement tileBuffer;
  SpriteSheet sheet;
  TileRenderingSystem(this.ctx, this.sheet);

  @override
  void initialize() {
    tileBuffer = new CanvasElement(width: TILES_X * TILE_SIZE, height: TILES_Y * TILE_SIZE);
    var bufferCtx = tileBuffer.context2D;
    for (int y = 0; y < TILES_Y; y++) {
      for (int x = 0; x < TILES_X; x++) {
        var sprite = sheet.sprites['grass_${random.nextInt(7)}'];
        bufferCtx.drawImageScaledFromSource(sheet.image, sprite.src.left, sprite.src.top, sprite.src.width, sprite.src.height, x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
      }
    }
  }

  @override
  void processSystem() {
    ctx.drawImage(tileBuffer, 0, 0);
  }
}

class BufferToCanvasRenderingSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;

  CanvasRenderingContext2D ctx;
  CanvasElement buffer;
  BufferToCanvasRenderingSystem(this.ctx, this.buffer) : super(Aspect.getAspectForAllOf([Camera, Transform]));

  @override
  void processEntity(Entity entity) {
    var t = tm.get(entity);
    ctx.drawImageScaledFromSource(buffer, t.x, t.y, 800, 600, 0, 0, 800, 600);
  }
}

class SelectionRenderingSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;

  CanvasRenderingContext2D ctx;
  SpriteSheet sheet;
  SelectionRenderingSystem(this.ctx, this.sheet) : super(Aspect.getAspectForAllOf([Transform, Selected]));


  @override
  void processEntity(Entity entity) {
    var t = tm.get(entity);

    var sprite = sheet.sprites['selected_${gameState.alignment}'];
    ctx.drawImageScaledFromSource(sheet.image, sprite.src.left, sprite.src.top, sprite.src.width, sprite.src.height, t.x * TILE_SIZE + sprite.offset.x + TILE_SIZE/2, t.y * TILE_SIZE + sprite.offset.y + TILE_SIZE/2 - TILE_SIZE, sprite.dst.width, sprite.dst.height);
  }
}