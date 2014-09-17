part of client;

class EndingScreenRenderingSystem extends VoidEntitySystem {
  var redrawBuffer = true;
  GameManager gameManager;
  CanvasRenderingContext2D ctx;
  CanvasElement worldMap;
  CanvasElement buffer;
  CanvasRenderingContext2D bufferCtx;
  TileRenderingSystem trs;
  FogOfWarRenderingSystem fowrs;
  RenderingSystem rs;
  EndingScreenRenderingSystem(this.ctx);

  @override
  void initialize() {
    buffer = new CanvasElement(width: 800, height: 600);
    bufferCtx = buffer.context2D;
    bufferCtx..font = '20px Verdana'
             ..textBaseline = 'top';
  }

  @override
  void processSystem() {
    if (redrawBuffer) {
      if (null == worldMap) {
        worldMap = new CanvasElement(width: 500, height: 500);
        worldMap.context2D..drawImageScaled(trs.buffer, 0, 0, 500, 500)
                          ..drawImageScaled(rs.buffer, 0, 0, 500, 500)
                          ..globalAlpha = 0.4
                          ..drawImageScaled(fowrs.fogOfWar, 0, 0, 500, 500);
      }
      var winLoseText = 'You have ${gameManager.playerWon ? 'WON' : 'LOST'} after ${gameManager.turn} turns';
      bufferCtx..save()
         ..fillStyle = Colors.MENU_BACKGROUND
         ..strokeStyle = Colors.MENU_BORDER
         ..fillRect(0, 0, 800, 600)
         ..strokeRect(0, 0, 800, 600)
         ..strokeStyle = Colors.MENU_BORDER
         ..lineWidth = 2
         ..strokeRect(0, 0, 800, 100)
         ..fillStyle = Colors.MENU_LABEL
         ..fillText(winLoseText, 400 - bufferCtx.measureText(winLoseText).width / 2, 40)
         ..drawImage(worldMap, 200, 100)
         ..restore();
      redrawBuffer = false;
    }
    ctx.drawImage(buffer, 0, 0);
  }

  @override
  bool checkProcessing() => gameManager.gameOver;

}
