part of client;

class EndingScreenRenderingSystem extends VoidEntitySystem {
  var redrawBuffer = true;
  GameManager gameManager;
  CanvasRenderingContext2D ctx;
  CanvasElement gameMap;
  CanvasElement buffer;
  CanvasRenderingContext2D bufferCtx;
  EndingScreenRenderingSystem(this.ctx, this.gameMap);

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
      var winLoseText = 'You have ${gameManager.playerWon ? 'won' : 'lost'} after ${gameManager.turn} turns';
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
         ..drawImageScaled(gameMap, 100, 100, 500, 500)
         ..restore();
      redrawBuffer = false;
    }
    ctx.drawImage(buffer, 0, 0);
  }

  @override
  bool checkProcessing() => gameManager.gameOver;

}
