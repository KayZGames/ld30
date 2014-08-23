part of client;

class CameraPositionSystem extends GenericInputHandlingSystem {
  final maxX = TILES_X * TILE_SIZE - 800;
  final maxY = TILES_Y * TILE_SIZE - 600;
  ComponentMapper<Transform> tm;
  CameraPositionSystem() : super(Aspect.getAspectForAllOf([Camera, Transform]));

  @override
  void processEntity(Entity entity) {
    int x = 0, y = 0;
    if (keyState[KeyCode.UP] == true) {
      y = -TILE_SIZE ~/ 4;
    } else if (keyState[KeyCode.DOWN] == true) {
      y = TILE_SIZE ~/ 4;
    }
    if (keyState[KeyCode.LEFT] == true) {
      x = -TILE_SIZE ~/ 4;
    } else if (keyState[KeyCode.RIGHT] == true) {
      x = TILE_SIZE ~/ 4;
    }
    var t = tm.get(entity);
    t.x += x;
    t.y += y;
    t.x = max(0, min(maxX, t.x));
    t.y = max(0, min(maxY, t.y));
  }
}