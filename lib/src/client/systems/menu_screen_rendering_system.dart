part of client;

class MenuScreenRenderingSystem extends VoidEntitySystem {
  final FACTION_SELECT = 'Select your world!';
  final factions = ['World of Angels', 'World of Demons', 'World of Fire', 'World of Ice'];
  int selection = 0;

  /// to prevent scrolling
  var preventDefaultKeys = new Set.from([KeyCode.UP, KeyCode.DOWN, KeyCode.LEFT, KeyCode.RIGHT, KeyCode.SPACE]);
  var keyState = <int, bool>{};
  var blockingKeys = new Set.from([KeyCode.UP, KeyCode.DOWN, KeyCode.ENTER]);
  var blockedKeys = new Set<int>();

  TagManager tagManager;
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
    if (keyState[KeyCode.UP] == true) {
      selection = (selection - 1) % factions.length;
      keyState[KeyCode.UP] = false;
    } else if (keyState[KeyCode.DOWN] == true) {
      selection = (selection + 1) % factions.length;
      keyState[KeyCode.DOWN] = false;
    }
    if (keyState[KeyCode.ENTER] == true) {
      gameState.playerFaction = FACTIONS[selection];
      gameState.menu = false;
      var camera = tagManager.getEntity('camera');
      var cameraTransform = tm.get(camera);
      if (selection == 0) {
        cameraTransform.x = gameState.sizeX * TILE_SIZE ~/ 2 - 400;
        cameraTransform.y = 0;
      } else if (selection == 1) {
        cameraTransform.x = gameState.sizeX * TILE_SIZE ~/ 2 - 400;
        cameraTransform.y = gameState.sizeY * TILE_SIZE - 300;
      } else if (selection == 2) {
        cameraTransform.x = 0;
        cameraTransform.y = gameState.sizeY * TILE_SIZE ~/ 2 - 300;
      } else if (selection == 3) {
        cameraTransform.x = gameState.sizeX * TILE_SIZE - 800;
        cameraTransform.y = gameState.sizeY * TILE_SIZE ~/ 2 - 300;
      }
      eventBus.fire(analyticsTrackEvent, new AnalyticsTrackEvent('Faction selected', FACTIONS[selection]));
      return;
    }
    ctx..save()
       ..setFillColorRgb(100, 100, 100)
       ..setStrokeColorRgb(50, 50, 50)
       ..fillRect(50, 50, 700, 500)
       ..strokeRect(50, 50, 700, 500)
       ..font = '20px Verdana'
       ..fillStyle = 'black'
       ..fillText(FACTION_SELECT, 400 - ctx.measureText(FACTION_SELECT).width / 2, 100);

    drawOption(0);
    drawOption(1);
    drawOption(2);
    drawOption(3);
    ctx..restore();
  }

  void drawOption(int index) {
    var greyness = selection == index ? 200 : 150;
    ctx..setFillColorRgb(greyness, greyness, greyness)
       ..fillRect(100, 165 + index * 90, 600, 70)
       ..fillStyle = 'black'
       ..fillText(factions[index], 400 - ctx.measureText(factions[index]).width / 2, 190 + index * 90);
  }

  @override
  bool checkProcessing() => gameState.menu;
}
