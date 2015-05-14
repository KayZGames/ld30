part of client;

class UnitStatusRenderingSystem extends EntityProcessingSystem {
  Mapper<Transform> tm;
  Mapper<Unit> um;
  GameManager gameManager;

  CanvasRenderingContext2D ctx;
  UnitStatusRenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([Transform, Unit]));

  @override
  void begin() {
    ctx..save()
       ..strokeStyle = 'black'
       ..lineWidth = 1;
  }

  @override
  void end() {
    ctx.restore();
  }

  @override
  void processEntity(Entity entity) {
    var t = tm[entity];
    var u = um[entity];

    var ratio = u.health / u.maxHealth;
    ctx..setFillColorRgb((255 * (1-ratio)).toInt(), (255 * ratio).toInt(), (100 * ratio).toInt())
       ..fillRect(t.x * TILE_SIZE, t.y * TILE_SIZE, ratio * TILE_SIZE, 4)
       ..strokeRect(t.x * TILE_SIZE, t.y * TILE_SIZE, TILE_SIZE, 5);
    if (u.faction == gameManager.playerFaction && u.movesLeft > 0) {
      var moves = '${u.movesLeft}';
      var textWidth = ctx.measureText(moves).width;
      ctx..setFillColorRgb(0, 255, 255)
         ..fillText(moves, (t.x+1) * TILE_SIZE - textWidth, t.y * TILE_SIZE + 20);
    }
  }

  @override
  bool checkProcessing() => gameManager.gameIsRunning;
}
