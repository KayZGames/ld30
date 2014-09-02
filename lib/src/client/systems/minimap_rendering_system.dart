part of client;

class MinimapRenderingSystem extends EntityProcessingSystem {
  final baseX = 800 - TILES_X * 2;
  final baseY = 600 - TILES_Y * 2;
  ComponentMapper<Unit> um;
  ComponentMapper<Transform> tm;
  TagManager tagManager;
  FogOfWarRenderingSystem fowrs;

  CanvasRenderingContext2D ctx;

  MinimapRenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([Unit, Transform]));

  @override
  void begin() {
    ctx..save()
       ..setFillColorRgb(50, 50, 50)
       ..fillRect(baseX, baseY, TILES_X * 2, TILES_Y * 2);
  }

  @override
  void end() {
    ctx.drawImageScaled(fowrs.fogOfWarMini, baseX, baseY, TILES_X * 2, TILES_Y * 2);

    var camera = tagManager.getEntity('camera');
    var cameraTransform = tm.get(camera);
    ctx..setStrokeColorRgb(150, 150, 150)
       ..lineWidth = 1
       ..strokeRect(1+baseX + cameraTransform.x / TILE_SIZE * 2, 1+baseY + cameraTransform.y / TILE_SIZE * 2, 800 / TILE_SIZE * 2, 600 / TILE_SIZE * 2)
       ..restore();
  }


  @override
  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var u = um.get(entity);

    if (u.faction == gameState.playerFaction) {
      ctx.setFillColorRgb(0, 255, 0);
    } else if (u.faction == 'neutral') {
      ctx.setFillColorRgb(150, 150, 150);
    } else {
      ctx.setFillColorRgb(255, 0, 0);
    }
    ctx.fillRect(baseX + t.x * 2, baseY + t.y * 2, 2, 2);
  }

  @override
  bool checkProcessing() => !gameState.menu;
}
