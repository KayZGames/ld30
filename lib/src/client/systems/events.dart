part of client;

class InputHandlingSystem extends GenericInputHandlingSystem {
  final maxX = TILES_X * TILE_SIZE - 800;
  final maxY = TILES_Y * TILE_SIZE - 600;
  Map<int, Vector2> directions = {KeyCode.W: new Vector2(0.0, -1.0),
                                  KeyCode.S: new Vector2(0.0, 1.0),
                                  KeyCode.A: new Vector2(-1.0, 0.0),
                                  KeyCode.D: new Vector2(1.0, 0.0),
                                  };
  ComponentMapper<Transform> tm;
  ComponentMapper<Unit> unitMapper;
  UnitManager um;
  InputHandlingSystem() : super(Aspect.getAspectForAllOf([Camera, Transform]));

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
    Entity selectedUnit;
    try {
      selectedUnit = um.getSelectedUnit(gameState.alignment);
    } on StateError catch (e) {
      // no selected Unit exists
    }
    if (keyState[KeyCode.N] == true) {
      if (null != selectedUnit) {
        selectedUnit..removeComponent(Selected)
                    ..changedInWorld();
      }
      try {
        var moveableUnit = um.getNextUnit(gameState.alignment);
        var unitTransform = tm.get(moveableUnit);
        t.x = unitTransform.x * TILE_SIZE - 400;
        t.y = unitTransform.y * TILE_SIZE - 300;
        moveableUnit..addComponent(new Selected())
                    ..changedInWorld();

      } on StateError catch (e) {
        // no moveable Unit exists
      }
    }
    if (null != selectedUnit) {
      if (keyState[KeyCode.W] == true) {
        moveUnit(selectedUnit, KeyCode.W);
      } else if (keyState[KeyCode.S] == true) {
        moveUnit(selectedUnit, KeyCode.S);
      } else if (keyState[KeyCode.A] == true) {
        moveUnit(selectedUnit, KeyCode.A);
      } else if (keyState[KeyCode.D] == true) {
        moveUnit(selectedUnit, KeyCode.D);
      }
    }
    t.x = max(0, min(maxX, t.x));
    t.y = max(0, min(maxY, t.y));
  }

  void moveUnit(Entity entity, int keyCode) {
    var unit = unitMapper.get(entity);
    if (unit.movesLeft > 0) {
      var selectedTransform = tm.get(entity);
      var direction = directions[keyCode];
      selectedTransform.x += direction.x.toInt();
      selectedTransform.y += direction.y.toInt();
      unitMapper.get(entity).movesLeft -= 1;
      keyState[keyCode] = false;
    }
  }
}