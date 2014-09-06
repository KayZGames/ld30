part of client;

class RenderingSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<Renderable> rm;
  ComponentMapper<Unit> um;
  GameManager gameManager;

  CanvasRenderingContext2D ctx;
  SpriteSheet sheet;
  RenderingSystem(this.ctx, this.sheet) : super(Aspect.getAspectForAllOf([Transform, Renderable, Unit]));

  @override
  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var r = rm.get(entity);
    var u = um.get(entity);

    var sprite = sheet.sprites['${r.name}_${u.faction}'];
    ctx.drawImageScaledFromSource(sheet.image, sprite.src.left, sprite.src.top, sprite.src.width, sprite.src.height,
        t.x * TILE_SIZE + sprite.offset.x + TILE_SIZE/2 + t.displacementX,
        t.y * TILE_SIZE + sprite.offset.y + TILE_SIZE/2 + t.displacementY,
        sprite.dst.width, sprite.dst.height);
  }

  @override
  bool checkProcessing() => !gameManager.menu;
}
