part of client;

class SelectionRenderingSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  GameManager gameManager;

  CanvasRenderingContext2D ctx;
  SpriteSheet sheet;
  SelectionRenderingSystem(this.ctx, this.sheet) : super(Aspect.getAspectForAllOf([Transform, Selected]));


  @override
  void processEntity(Entity entity) {
    var t = tm.get(entity);

    var sprite = sheet.sprites['selected_${gameManager.playerFaction}'];
    ctx.drawImageScaledFromSource(sheet.image,
        sprite.src.left, sprite.src.top, sprite.src.width, sprite.src.height,
        t.x * TILE_SIZE + sprite.offset.x + TILE_SIZE/2, t.y * TILE_SIZE + sprite.offset.y + TILE_SIZE/2 - TILE_SIZE + 2 * sin(world.time / 100),
        sprite.dst.width, sprite.dst.height);
  }

  @override
  bool checkProcessing() => gameManager.playerFaction == gameManager.currentFaction && !gameManager.menu;
}
