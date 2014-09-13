part of client;

class InputHandlingSystem extends GenericInputHandlingSystem {
  int maxX;
  int maxY;
  var blockingKeys = new Set.from([KeyCode.N, KeyCode.W, KeyCode.A, KeyCode.S, KeyCode.D, KeyCode.ENTER]);
  var blockedKeys = new Set<int>();
  Map<int, List<int>> directions = {
                                    KeyCode.NUM_ONE:   [-1,  1],
                                    KeyCode.NUM_TWO:   [ 0,  1],
                                    KeyCode.NUM_THREE: [ 1,  1],
                                    KeyCode.NUM_FOUR:  [-1,  0],
                                    KeyCode.NUM_SIX:   [ 1,  0],
                                    KeyCode.NUM_SEVEN: [-1, -1],
                                    KeyCode.NUM_EIGHT: [ 0, -1],
                                    KeyCode.NUM_NINE:  [ 1, -1],
                                   };
  ComponentMapper<Transform> tm;
  UnitManager unitManager;
  TurnManager turnManager;
  GameManager gameManager;
  InputHandlingSystem() : super(Aspect.getAspectForAllOf([Camera, Transform]));

  @override
  void initialize() {
    super.initialize();
    eventBus.on(GameStartedEvent).listen((_) {
      maxX = gameManager.sizeX * TILE_SIZE - 800;
      maxY = gameManager.sizeY * TILE_SIZE - 600;
    });
  }

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
    if (gameManager.currentFaction == gameManager.playerFaction) {
      if (keyState[KeyCode.N] == true) {
        var moveableUnit = unitManager.getNextUnit(gameManager.playerFaction);
        if (null != moveableUnit) {
          var unitTransform = tm.get(moveableUnit);
          t.x = unitTransform.x * TILE_SIZE - 400;
          t.y = unitTransform.y * TILE_SIZE - 300;
          moveableUnit..addComponent(new Selected())
                      ..changedInWorld();

          keyState[KeyCode.N] = false;
        }
      }
      Entity selectedUnit = unitManager.getSelectedUnit(gameManager.playerFaction);
      if (null != selectedUnit) {
        if (keyState[KeyCode.NUM_EIGHT] == true) {
          moveUnit(selectedUnit, KeyCode.NUM_EIGHT);
        } else if (keyState[KeyCode.NUM_TWO] == true) {
          moveUnit(selectedUnit, KeyCode.NUM_TWO);
        } else if (keyState[KeyCode.NUM_FOUR] == true) {
          moveUnit(selectedUnit, KeyCode.NUM_FOUR);
        } else if (keyState[KeyCode.NUM_SIX] == true) {
          moveUnit(selectedUnit, KeyCode.NUM_SIX);
        } else if (keyState[KeyCode.NUM_ONE] == true) {
          moveUnit(selectedUnit, KeyCode.NUM_ONE);
        } else if (keyState[KeyCode.NUM_THREE] == true) {
          moveUnit(selectedUnit, KeyCode.NUM_THREE);
        } else if (keyState[KeyCode.NUM_SEVEN] == true) {
          moveUnit(selectedUnit, KeyCode.NUM_SEVEN);
        } else if (keyState[KeyCode.NUM_NINE] == true) {
          moveUnit(selectedUnit, KeyCode.NUM_NINE);
        }
      }
      if (keyState[KeyCode.ENTER] == true) {
        turnManager.nextTurn();
      }
    }
    t.x = max(0, min(maxX, t.x));
    t.y = max(0, min(maxY, t.y));
  }

  void moveUnit(Entity entity, int keyCode) {
    var selectedTransform = tm.get(entity);
    var direction = directions[keyCode];
    entity..addComponent(new Move(direction[0], direction[1]))
          ..changedInWorld();
    keyState[keyCode] = false;
  }

  @override
  bool checkProcessing() => gameManager.gameIsRunning;
}