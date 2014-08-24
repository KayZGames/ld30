part of client;


class RenderingSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<Renderable> rm;
  ComponentMapper<Unit> um;

  CanvasRenderingContext2D ctx;
  SpriteSheet sheet;
  RenderingSystem(this.ctx, this.sheet) : super(Aspect.getAspectForAllOf([Transform, Renderable, Unit]));

  @override
  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var r = rm.get(entity);
    var u = um.get(entity);

    var sprite = sheet.sprites['${r.name}_${u.faction}'];
    ctx.drawImageScaledFromSource(sheet.image, sprite.src.left, sprite.src.top, sprite.src.width, sprite.src.height,
        t.x * TILE_SIZE + sprite.offset.x + TILE_SIZE/2 + t.displacementX,
        t.y * TILE_SIZE + sprite.offset.y + TILE_SIZE/2 + t.displacementY,
        sprite.dst.width, sprite.dst.height);
  }

  @override
  bool checkProcessing() => !gameState.menu;
}

class UnitStatusRenderingSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<Unit> um;

  CanvasRenderingContext2D ctx;
  UnitStatusRenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([Transform, Unit]));

  @override
  void begin() {
    ctx..save()
       ..strokeStyle = 'black'
       ..lineWidth = 1;
  }

  @override
  void end() {
    ctx.restore();
  }

  @override
  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var u = um.get(entity);

    var ratio = u.health / u.maxHealth;
    ctx..setFillColorRgb((255 * (1-ratio)).toInt(), (255 * ratio).toInt(), (100 * ratio).toInt())
       ..fillRect(t.x * TILE_SIZE, t.y * TILE_SIZE, ratio * TILE_SIZE, 4)
       ..strokeRect(t.x * TILE_SIZE, t.y * TILE_SIZE, TILE_SIZE, 5);
    if (u.faction == gameState.playerFaction && u.movesLeft > 0) {
      var moves = '${u.movesLeft}';
      var textWidth = ctx.measureText(moves).width;
      ctx..setFillColorRgb(0, 255, 255)
         ..fillText(moves, (t.x+1) * TILE_SIZE - textWidth, t.y * TILE_SIZE + 20);
    }
  }

  @override
  bool checkProcessing() => !gameState.menu;
}

class TileRenderingSystem extends VoidEntitySystem {

  CanvasRenderingContext2D ctx;
  CanvasElement tileBuffer;
  SpriteSheet sheet;
  TileRenderingSystem(this.ctx, this.sheet);

  @override
  void initialize() {
    tileBuffer = new CanvasElement(width: TILES_X * TILE_SIZE, height: TILES_Y * TILE_SIZE);
    var bufferCtx = tileBuffer.context2D;
    for (int y = 0; y < TILES_Y; y++) {
      for (int x = 0; x < TILES_X; x++) {
        var sprite = sheet.sprites['grass_${random.nextInt(7)}'];
        bufferCtx.drawImageScaledFromSource(sheet.image, sprite.src.left, sprite.src.top, sprite.src.width, sprite.src.height, x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
      }
    }
  }

  @override
  void processSystem() {
    ctx.drawImage(tileBuffer, 0, 0);
  }

  @override
  bool checkProcessing() => !gameState.menu;
}

class BufferToCanvasRenderingSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;

  CanvasRenderingContext2D ctx;
  CanvasElement buffer;
  BufferToCanvasRenderingSystem(this.ctx, this.buffer) : super(Aspect.getAspectForAllOf([Camera, Transform]));

  @override
  void processEntity(Entity entity) {
    var t = tm.get(entity);
    ctx.drawImageScaledFromSource(buffer, t.x, t.y, 800, 600, 0, 0, 800, 600);
  }

  @override
  bool checkProcessing() => !gameState.menu;
}

class SelectionRenderingSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;

  CanvasRenderingContext2D ctx;
  SpriteSheet sheet;
  SelectionRenderingSystem(this.ctx, this.sheet) : super(Aspect.getAspectForAllOf([Transform, Selected]));


  @override
  void processEntity(Entity entity) {
    var t = tm.get(entity);

    var sprite = sheet.sprites['selected_${gameState.playerFaction}'];
    ctx.drawImageScaledFromSource(sheet.image,
        sprite.src.left, sprite.src.top, sprite.src.width, sprite.src.height,
        t.x * TILE_SIZE + sprite.offset.x + TILE_SIZE/2, t.y * TILE_SIZE + sprite.offset.y + TILE_SIZE/2 - TILE_SIZE + 2 * sin(world.time / 100),
        sprite.dst.width, sprite.dst.height);
  }

  @override
  bool checkProcessing() => gameState.playerFaction == gameState.currentFaction && !gameState.menu;
}

class MinimapRenderingSystem extends EntityProcessingSystem {
  final baseX = 800 - TILES_X * 2;
  final baseY = 600 - TILES_Y * 2;
  ComponentMapper<Unit> um;
  ComponentMapper<Transform> tm;
  TagManager tagManager;
  FogOfWarRenderingSystem fowrs;

  CanvasRenderingContext2D ctx;

  MinimapRenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([Unit, Transform]));

  @override
  void begin() {
    ctx..setFillColorRgb(50, 50, 50)
       ..fillRect(baseX, baseY, TILES_X * 2, TILES_Y * 2);
  }

  @override
  void end() {
    ctx.drawImageScaled(fowrs.fogOfWarMini, baseX, baseY, TILES_X * 2, TILES_Y * 2);

    var camera = tagManager.getEntity('camera');
    var cameraTransform = tm.get(camera);
    ctx..setStrokeColorRgb(150, 150, 150)
       ..lineWidth = 1
       ..strokeRect(1+baseX + cameraTransform.x / TILE_SIZE * 2, 1+baseY + cameraTransform.y / TILE_SIZE * 2, 800 / TILE_SIZE * 2, 600 / TILE_SIZE * 2);
  }


  @override
  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var u = um.get(entity);

    if (u.faction == gameState.playerFaction) {
      ctx.setFillColorRgb(0, 255, 0);
    } else if (u.faction == 'neutral') {
      ctx.setFillColorRgb(150, 150, 150);
    } else {
      ctx.setFillColorRgb(255, 0, 0);
    }
    ctx.fillRect(baseX + t.x * 2, baseY + t.y * 2, 2, 2);
  }

  @override
  bool checkProcessing() => !gameState.menu;
}

class FogOfWarRenderingSystem extends VoidEntitySystem {
  FogOfWarManager fowManager;
  TagManager tagManager;
  ComponentMapper<Transform> tm;

  CanvasRenderingContext2D ctx;
  CanvasElement fogOfWar;
  CanvasElement fogOfWarMini;


  FogOfWarRenderingSystem(this.ctx);

  @override
  void initialize() {
    fogOfWarMini = new CanvasElement(width: TILES_X, height: TILES_Y);
    fogOfWarMini.context2D..fillStyle = 'black'
                          ..globalAlpha = 0.5
                          ..fillRect(0, 0, TILES_X, TILES_Y);
    fogOfWar = new CanvasElement(width: TILES_X * TILE_SIZE, height: TILES_Y * TILE_SIZE);
    fogOfWar.context2D.drawImageScaled(fogOfWarMini, 0, 0, TILES_X * TILE_SIZE, TILES_Y * TILE_SIZE);
  }

  @override
  void processSystem() {
    if (fowManager.hasChanges) {
      var tiles = fowManager.tiles[gameState.playerFaction];
      for (int x = 0; x < tiles.length; x++) {
        for (int y = 0; y < tiles[x].length; y++) {
          if (tiles[x][y]) {
            fogOfWarMini.context2D.clearRect(x, y, 1, 1);
          }
        }
      }
      fowManager.hasChanges = false;
      fogOfWar.context2D..clearRect(0, 0, TILES_X * TILE_SIZE, TILES_Y * TILE_SIZE)
                        ..drawImageScaled(fogOfWarMini, 0, 0, TILES_X * TILE_SIZE, TILES_Y * TILE_SIZE);
    }
    var camera = tagManager.getEntity('camera');
    var t = tm.get(camera);

    ctx.drawImageScaledFromSource(fogOfWar, t.x, t.y, 800, 600, t.x, t.y, 800, 600);
  }

  @override
  bool checkProcessing() => !gameState.menu;
}

class FactionSelectionScreenRenderingSystem extends VoidEntitySystem {
  final FACTION_SELECT = 'Select your world!';
  final factions = ['World of Angels', 'World of Demons', 'World of Fire', 'World of Ice'];
  int selection = 0;


  /// to prevent scrolling
  var preventDefaultKeys = new Set.from([KeyCode.UP, KeyCode.DOWN, KeyCode.LEFT, KeyCode.RIGHT, KeyCode.SPACE]);
  var keyState = <int, bool>{};
  var blockingKeys = new Set.from([KeyCode.UP, KeyCode.DOWN, KeyCode.ENTER]);
  var blockedKeys = new Set<int>();

  CanvasRenderingContext2D ctx;

  FactionSelectionScreenRenderingSystem(this.ctx);

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