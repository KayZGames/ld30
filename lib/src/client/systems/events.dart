part of client;

class InputHandlingSystem extends GenericInputHandlingSystem {
  final maxX = TILES_X * TILE_SIZE - 800;
  final maxY = TILES_Y * TILE_SIZE - 600;
  Set<int> blockingKeys = new Set.from([KeyCode.N, KeyCode.W, KeyCode.A, KeyCode.S, KeyCode.D, KeyCode.ENTER]);
  Set<int> blockedKeys = new Set<int>();
  Map<int, Vector2> directions = {KeyCode.W: new Vector2(0.0, -1.0),
                                  KeyCode.S: new Vector2(0.0, 1.0),
                                  KeyCode.A: new Vector2(-1.0, 0.0),
                                  KeyCode.D: new Vector2(1.0, 0.0),
                                  };
  ComponentMapper<Transform> tm;
  UnitManager um;
  InputHandlingSystem() : super(Aspect.getAspectForAllOf([Camera, Transform]));

  @override
  void handleInput(KeyboardEvent event, bool pressed) {
    var keyCode = event.keyCode;
    if (preventDefaultKeys.contains(keyCode)) {
      event.preventDefault();
    }
    if (blockedKeys.contains(keyCode) && pressed) return;
    keyState[keyCode] = pressed;
    if (!pressed) {
      blockedKeys.remove(keyCode);
    } else if (blockingKeys.contains(keyCode)) {
      blockedKeys.add(keyCode);
    }
  }

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
      keyState[KeyCode.N] = false;
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
    if (keyState[KeyCode.ENTER] == true) {
      um.nextTurn();
    }
    t.x = max(0, min(maxX, t.x));
    t.y = max(0, min(maxY, t.y));
  }

  void moveUnit(Entity entity, int keyCode) {
    var selectedTransform = tm.get(entity);
    var direction = directions[keyCode];
    entity..addComponent(new Move(direction.x.toInt(), direction.y.toInt()))
          ..changedInWorld();
    keyState[keyCode] = false;
  }
}