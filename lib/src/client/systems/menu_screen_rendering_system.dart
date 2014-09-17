part of client;

class MenuScreenRenderingSystem extends VoidEntitySystem {
  static final HEAVEN = 0;
  static final HELL = 1;
  static final FIRE = 2;
  static final ICE = 3;
  static final int OPTION_FACTION = 0;
  static final int OPTION_MAPSIZE = 1;
  static final int OPTION_START_GAME = 2;

  Map<int, int> highlighted = {OPTION_FACTION: 0,
                              OPTION_MAPSIZE: 0,
                              OPTION_START_GAME: 0};
  Map<int, int> optionCount = {OPTION_FACTION: 4,
                               OPTION_MAPSIZE: 3,
                               OPTION_START_GAME: 1};
  Map<int, String> optionLabels = {OPTION_FACTION: ['Angelus', 'Abyssus', 'Ignis', 'Glacies'],
                                   OPTION_MAPSIZE: ['Small', 'Medium', 'Large'],
                                   OPTION_START_GAME: ['Start Game']};
  Map<int, int> selected = {OPTION_FACTION: null,
                            OPTION_MAPSIZE: null};

  int selectedRow = 0;

  /// to prevent scrolling
  var preventDefaultKeys = new Set.from([KeyCode.UP, KeyCode.DOWN, KeyCode.LEFT, KeyCode.RIGHT, KeyCode.SPACE]);
  var keyState = <int, bool>{};
  var blockingKeys = new Set.from([KeyCode.UP, KeyCode.DOWN, KeyCode.LEFT, KeyCode.RIGHT, KeyCode.ENTER]);
  var blockedKeys = new Set<int>();

  TagManager tagManager;
  GameManager gameManager;
  ComponentMapper<Transform> tm;

  CanvasRenderingContext2D ctx;

  MenuScreenRenderingSystem(this.ctx);

  @override
  void initialize() {
    window.onKeyDown.listen((event) => handleInput(event, true));
    window.onKeyUp.listen((event) => handleInput(event, false));
  }

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
  void processSystem() {
    if (keyState[KeyCode.LEFT] == true) {
      highlighted[selectedRow] = (highlighted[selectedRow] - 1) % optionCount[selectedRow];
      keyState[KeyCode.LEFT] = false;
    } else if (keyState[KeyCode.RIGHT] == true) {
      highlighted[selectedRow] = (highlighted[selectedRow] + 1) % optionCount[selectedRow];
      keyState[KeyCode.RIGHT] = false;
    } else if (keyState[KeyCode.DOWN] == true) {
      selectedRow = (selectedRow + 1) % 3;
      keyState[KeyCode.DOWN] = false;
    } else if (keyState[KeyCode.UP] == true) {
      selectedRow = (selectedRow - 1) % 3;
      keyState[KeyCode.UP] = false;
    }
    if (keyState[KeyCode.ENTER] == true) {
      if (selectedRow == OPTION_START_GAME
        && selected[OPTION_FACTION] != null
        && selected[OPTION_MAPSIZE] != null) {
        gameManager.playerFaction = FACTIONS[selected[OPTION_FACTION]];
        switch (selected[OPTION_MAPSIZE]) {
          case 0:
            gameManager.sizeX = 16;
            gameManager.sizeY = 16;
            break;
          case 1:
            gameManager.sizeX = 32;
            gameManager.sizeY = 32;
            break;
          default:
            gameManager.sizeX = 64;
            gameManager.sizeY = 64;
            break;
        }
        var camera = tagManager.getEntity('camera');
        var cameraTransform = tm.get(camera);
        if (gameManager.playerFaction == F_HEAVEN) {
          cameraTransform.x = gameManager.sizeX * TILE_SIZE ~/ 2 - 400;
          cameraTransform.y = 0;
        } else if (gameManager.playerFaction == F_HELL) {
          cameraTransform.x = gameManager.sizeX * TILE_SIZE ~/ 2 - 400;
          cameraTransform.y = gameManager.sizeY * TILE_SIZE - 300;
        } else if (gameManager.playerFaction == F_FIRE) {
          cameraTransform.x = 0;
          cameraTransform.y = gameManager.sizeY * TILE_SIZE ~/ 2 - 300;
        } else if (gameManager.playerFaction == F_ICE) {
          cameraTransform.x = gameManager.sizeX * TILE_SIZE - 800;
          cameraTransform.y = gameManager.sizeY * TILE_SIZE ~/ 2 - 300;
        }
        eventBus.fire(new AnalyticsTrackEvent('Faction selected', gameManager.playerFaction));
        gameManager.startGame();
        return;
      } else if (selectedRow != OPTION_START_GAME) {
        selected[selectedRow] = highlighted[selectedRow];
      }
    }
    ctx..save()
       ..fillStyle = Colors.MENU_BACKGROUND
       ..strokeStyle = Colors.MENU_BORDER
       ..fillRect(0, 0, 800, 600)
       ..strokeRect(00, 00, 800, 600)
       ..globalAlpha = 1.0
       ..font = '20px Verdana';

    drawLabel('FACTION', 50);
    drawLabel('MAP SIZE', 150);
    for (int option = 0; option < 3; option++) {
      for (int i = 0; i < optionCount[option]; i++) {
        drawOption(option, i);
      }
    }
    ctx..restore();
  }

  void drawLabel(String label, int y) {
    var width = ctx.measureText(label).width;
    ctx..moveTo(50, y)
       ..fillStyle = Colors.MENU_LABEL
       ..strokeStyle = Colors.MENU_LABEL
       ..lineTo(400 - width / 2 - 20, y)
       ..moveTo(400 + width / 2 + 20, y)
       ..lineTo(750, y)
       ..stroke()
       ..fillText(label, 400 - width / 2, y - 10);
  }

  void drawOption(int option, int index) {
    var fillStyle = Colors.MENU_BUTTON;
    if (selected[option] == index) {
      fillStyle = Colors.MENU_BUTTON_SELECTED;
    }
    if (selectedRow == option && highlighted[option] == index) {
      fillStyle = Colors.MENU_BUTTON_HIGHLIGHTED;
      if (selected[option] == index) {
        fillStyle = Colors.MENU_BUTTON_SELECTED_HIGHLIGHTED;
      }
    }
    var labelWidth = ctx.measureText(optionLabels[option][index]).width;
    var x = 400 + (index - optionCount[option] / 2) * 175 + 12.5;
    ctx..fillStyle = fillStyle
       ..lineWidth = 1
       ..strokeStyle = Colors.MENU_BUTTON_BORDER
       ..fillRect(x, 75 + option * 100, 150, 50)
       ..strokeRect(x, 75 + option * 100, 150, 50)
       ..fillStyle = selected[option] == index ? Colors.MENU_LABEL_SELECTED : Colors.MENU_LABEL
       ..fillText(optionLabels[option][index], x + 75 - labelWidth / 2, 90 + option * 100);
  }

  @override
  bool checkProcessing() => gameManager.menu;
}
