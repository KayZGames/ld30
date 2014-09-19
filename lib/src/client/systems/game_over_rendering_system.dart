part of client;

class GameOverRenderingSystem extends VoidEntitySystem {
  /// to prevent scrolling
  var preventDefaultKeys = new Set.from([KeyCode.UP, KeyCode.DOWN, KeyCode.LEFT, KeyCode.RIGHT, KeyCode.SPACE]);
  var keyState = <int, bool>{};
  var blockingKeys = new Set.from([KeyCode.UP, KeyCode.DOWN, KeyCode.ENTER]);
  var blockedKeys = new Set<int>();
  var factionColors = {F_HEAVEN: Colors.GOLDEN_FIZZ, F_HELL: Colors.DEEP_KOAMARU, F_FIRE: Colors.MANDY, F_ICE: Colors.LIGHT_STEEL_BLUE, F_NEUTRAL: Colors.LIGHT_STEEL_BLUE};
  static final int GRAPH_COUNT = 7;

  List<String> buttonLabels = <String>['New Game', 'World Map', 'Units', 'Castles', 'Lost Units', 'Lost Castles', 'Defeated Units', 'Conquered Castles', 'Scouted Area'];
  List<CanvasElement> graphs = new List<CanvasElement>(GRAPH_COUNT);
  var redrawBuffer;
  var highlighted;
  var selected;
  GameManager gameManager;
  CanvasRenderingContext2D ctx;
  CanvasElement worldMap;
  CanvasElement buffer;
  CanvasRenderingContext2D bufferCtx;
  TileRenderingSystem trs;
  FogOfWarRenderingSystem fowrs;
  RenderingSystem rs;
  GameOverRenderingSystem(this.ctx);

  @override
  void initialize() {
    buffer = new CanvasElement(width: 800, height: 600);
    bufferCtx = buffer.context2D;
    bufferCtx..font = '18px Verdana'
             ..textBaseline = 'top';
    window.onKeyDown.listen((event) => handleInput(event, true));
    window.onKeyUp.listen((event) => handleInput(event, false));
    reset();
  }

  void reset() {
    redrawBuffer = true;
    highlighted = 1;
    selected = 1;
    worldMap = null;
    keyState = <int, bool>{};
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
    if (redrawBuffer) {
      if (null == worldMap) {
        worldMap = new CanvasElement(width: 550, height: 550);
        worldMap.context2D..drawImageScaled(trs.buffer, 0, 0, 550, 550)
                          ..drawImageScaled(rs.buffer, 0, 0, 550, 550)
                          ..globalAlpha = 0.4
                          ..drawImageScaled(fowrs.fogOfWar, 0, 0, 550, 550);
        for (int i = 0; i < GRAPH_COUNT; i++) {
          graphs[i] = new CanvasElement(width: 550, height: 550);
          graphs[i].context2D..fillStyle = Colors.SMOKEY_ASH
                             ..lineWidth = 2
                             ..fillRect(0, 0, 550, 550);
        }
        var aggregate = (a, b) => a + b;
        drawGraph(graphs[0].context2D, (TurnStatistics turnStat) => turnStat.units, aggregate, maxAmountFunc: (GameStatistics gameStat) => gameStat.maxUnits);
        drawGraph(graphs[1].context2D, (TurnStatistics turnStat) => turnStat.castles, aggregate, maxAmountFunc: (GameStatistics gameStat) => gameStat.maxCastles);
        drawGraph(graphs[2].context2D, (TurnStatistics turnStat) => turnStat.lostUnits, aggregate);
        drawGraph(graphs[3].context2D, (TurnStatistics turnStat) => turnStat.lostCastles, aggregate);
        drawGraph(graphs[4].context2D, (TurnStatistics turnStat) => turnStat.defeatedUnits, aggregate);
        drawGraph(graphs[5].context2D, (TurnStatistics turnStat) => turnStat.conqueredCastles, aggregate);
        drawGraph(graphs[6].context2D, (TurnStatistics turnStat) => turnStat.scoutedArea, aggregate);
      }
      var winLoseText = 'You have ${gameManager.playerWon ? 'WON' : 'LOST'} after ${gameManager.turn} turns';
      bufferCtx..save()
         ..fillStyle = Colors.MENU_BACKGROUND
         ..strokeStyle = Colors.MENU_BORDER
         ..fillRect(0, 0, 800, 600)
         ..strokeRect(0, 0, 800, 600)
         ..strokeStyle = Colors.MENU_BORDER
         ..lineWidth = 2
         ..beginPath()
         ..moveTo(0, 50)
         ..lineTo(800, 50)
         ..moveTo(250, 50)
         ..lineTo(250, 600)
         ..closePath()
         ..stroke()
         ..fillStyle = Colors.MENU_LABEL
         ..fillText(winLoseText, 400 - bufferCtx.measureText(winLoseText).width / 2, 25 - 18 * 0.6)
         ..drawImage(worldMap, 250, 50)
         ..restore();
      var buttonCount = 0;
      buttonLabels.forEach((label) => drawButton(label, buttonCount++));
      redrawBuffer = false;
    }
    updateForSelection();
    ctx.drawImage(buffer, 0, 0);
  }

  void drawGraph(CanvasRenderingContext2D context, num attribute(TurnStatistics turnStats), num graphValue(num lastValue, num currentValue), {num maxAmountFunc(GameStatistics gameStats)}) {
    var turns = gameManager.turn;
    if (null == maxAmountFunc) {
      maxAmountFunc = attribute;
    }
    var maxAmount = gameManager.gameStatistics.values.fold(0, (value, element) => max(value, maxAmountFunc(element)));
    gameManager.turnStatistics.forEach((faction, turnStatistics) {
      var counter = 0;
      var amount = 0;
      context..beginPath()
             ..strokeStyle = factionColors[faction]
             ..moveTo(0, 550);
      turnStatistics.forEach((turnStat) {
        amount = graphValue(amount, attribute(turnStat));
        context.lineTo(counter * 550 / turns, 550 - amount * 550 / maxAmount);
        counter++;
      });
      context..stroke()
             ..closePath();
    });
  }

  void updateForSelection() {
    var lastHighlighted = highlighted;
    var lastSelected = selected;
    if (keyState[KeyCode.DOWN] == true) {
      highlighted = (highlighted + 1) % (GRAPH_COUNT+2);
      keyState[KeyCode.DOWN] = false;
    } else if (keyState[KeyCode.UP] == true) {
      highlighted = (highlighted - 1) % (GRAPH_COUNT+2);
      keyState[KeyCode.UP] = false;
    }
    if (keyState[KeyCode.ENTER] == true) {
      selected = highlighted;
    }
    if (lastHighlighted != highlighted) {
      drawButton(buttonLabels[lastHighlighted], lastHighlighted);
      drawButton(buttonLabels[highlighted], highlighted);
    }
    if (lastSelected != selected) {
      drawButton(buttonLabels[lastSelected], lastSelected);
      drawButton(buttonLabels[selected], selected);
      switch (selected) {
        case 0:
          reset();
          gameManager.restart();
          break;
        case 1:
          bufferCtx.drawImage(worldMap, 250, 50);
          break;
        default:
          bufferCtx.drawImage(graphs[selected - 2], 250, 50);
      }
    }
  }

  void drawButton(String text, int index) {
    var fillStyle = Colors.MENU_BUTTON;
    var labelFillStyle = Colors.MENU_LABEL;
    if (selected == index) {
      fillStyle = Colors.MENU_BUTTON_SELECTED;
    }
    if (highlighted == index) {
      fillStyle = Colors.MENU_BUTTON_HIGHLIGHTED;
      if (selected == index) {
        fillStyle = Colors.MENU_BUTTON_SELECTED_HIGHLIGHTED;
        labelFillStyle = Colors.MENU_LABEL_SELECTED;
      }
    }
    _drawButton(text, 20, 75 + index * 50, 210, 30, fillStyle, Colors.MENU_LABEL);
  }

  void _drawButton(String text, int x, int y, int width, int height, String buttonFillStyle, String buttonLabelFillStyle) {
    var textWidth = bufferCtx.measureText(text).width;
    bufferCtx..fillStyle = buttonFillStyle
             ..strokeStyle = Colors.MENU_BUTTON_BORDER
             ..fillRect(x, y, width, height)
             ..strokeRect(x, y, width, height)
             ..fillStyle = buttonLabelFillStyle
             ..fillText(text, x + (width - textWidth) / 2, y + height / 2 - 18 * 0.6);
  }

  @override
  bool checkProcessing() => gameManager.gameOver;

}
