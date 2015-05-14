part of client;

class BufferToCanvasRenderingSystem extends EntityProcessingSystem {
  Mapper<Transform> tm;
  GameManager gameManager;

  CanvasRenderingContext2D ctx;
  CanvasElement buffer;
  BufferToCanvasRenderingSystem(this.ctx, this.buffer) : super(Aspect.getAspectForAllOf([Camera, Transform]));

  @override
  void processEntity(Entity entity) {
    var t = tm[entity];
    ctx.drawImageScaledFromSource(buffer, t.x, t.y, 800, 600, 0, 0, 800, 600);
  }

  @override
  bool checkProcessing() => gameManager.gameIsRunning;
}
