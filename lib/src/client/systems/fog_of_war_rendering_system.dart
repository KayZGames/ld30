part of client;

class FogOfWarRenderingSystem extends VoidEntitySystem {
  FogOfWarManager fowManager;
  TagManager tagManager;
  ComponentMapper<Transform> tm;
  GameManager gameManager;

  CanvasRenderingContext2D ctx;
  CanvasElement fogOfWar;
  CanvasElement fogOfWarMini;


  FogOfWarRenderingSystem(this.ctx);

  @override
  void initialize() {
    eventBus.on(GameStartedEvent).listen((_) {
      fogOfWarMini = new CanvasElement(width: gameManager.sizeX, height: gameManager.sizeY);
      fogOfWarMini.context2D..fillStyle = 'black'
  //                          ..globalAlpha = 0.5
                            ..fillRect(0, 0, gameManager.sizeX, gameManager.sizeY);
      fogOfWar = new CanvasElement(width: gameManager.sizeX * TILE_SIZE, height: gameManager.sizeY * TILE_SIZE);
      fogOfWar.context2D.drawImageScaled(fogOfWarMini, 0, 0, gameManager.sizeX * TILE_SIZE, gameManager.sizeY * TILE_SIZE);
    });
  }

  @override
  void processSystem() {
    if (fowManager.hasChanges) {
      var tiles = fowManager.tiles[gameManager.playerFaction];
      for (int x = 0; x < tiles.length; x++) {
        for (int y = 0; y < tiles[x].length; y++) {
          if (tiles[x][y]) {
            fogOfWarMini.context2D.clearRect(x, y, 1, 1);
          }
        }
      }
      fowManager.hasChanges = false;
      fogOfWar.context2D..clearRect(0, 0, gameManager.sizeX * TILE_SIZE, gameManager.sizeY * TILE_SIZE)
                        ..drawImageScaled(fogOfWarMini, 0, 0, gameManager.sizeX * TILE_SIZE, gameManager.sizeY * TILE_SIZE);
    }
    var camera = tagManager.getEntity('camera');
    var t = tm.get(camera);

    ctx.drawImageScaledFromSource(fogOfWar, t.x, t.y, 800, 600, t.x, t.y, 800, 600);
  }

  @override
  bool checkProcessing() => !gameManager.menu;
}
