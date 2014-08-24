import 'package:ld30/client.dart';

@MirrorsUsed(targets: const [RenderingSystem, InputHandlingSystem,
                             TileRenderingSystem, BufferToCanvasRenderingSystem,
                             SelectionRenderingSystem,
                             AttackerSystem, DefenderSystem, MovementSystem,
                             KilledInActionSystem, UnitManager, UnitStatusRenderingSystem,
                             SpawnerManager, TurnManager, AiSystem, ConquerableUnitSystem,
                             MinimapRenderingSystem, FogOfWarRenderingSystem,
                             FogOfWarManager, FactionSelectionScreenRenderingSystem,
                             TurnMessageRenderingSystem
                            ])
import 'dart:mirrors';

void main() {
  new Game().start();
}

class Game extends GameBase {
  CanvasElement buffer;
  Game() : super('ld30', 'canvas', 800, 600, bodyDefsName: null) {
    buffer = new CanvasElement(width: TILES_X * TILE_SIZE, height: TILES_Y * TILE_SIZE);
    buffer.context2D..textBaseline = "top"
                    ..font = '12px Verdana';
  }

  void createEntities() {
    addEntity([new Transform(TILES_X ~/ 2, TILES_Y - 1), new Renderable('gate'), new Spawner.instant(2), new Unit(F_HELL, 0, 0)]);
    addEntity([new Transform(TILES_X ~/ 2, 0), new Renderable('gate'), new Spawner.instant(2), new Unit(F_HEAVEN, 0, 0)]);
    addEntity([new Transform(0, TILES_Y ~/ 2), new Renderable('gate'), new Spawner.instant(2), new Unit(F_FIRE, 0, 0)]);
    addEntity([new Transform(TILES_X - 1, TILES_Y ~/ 2), new Renderable('gate'), new Spawner.instant(2), new Unit(F_ICE, 0, 0)]);

    List<int> freeTiles = new List.generate(TILES_X * TILES_Y, (index) => index);
    freeTiles.removeWhere((value) => value % TILES_Y < 3 || value % TILES_Y > TILES_X - 3 || value ~/ TILES_X < 3 || value ~/ TILES_X > TILES_Y - 3);
    for (int i = 0; i < 40; i++) {
      var pos = freeTiles[random.nextInt(freeTiles.length)];
      var x = pos % TILES_X;
      var y = pos ~/ TILES_X;
      if (freeTiles.contains(y * TILES_X + x)) {
        addEntity([new Transform(x, y), new Renderable('castle'), new Spawner(2), new Unit(F_NEUTRAL, 0, 0), new Conquerable()]);
        for (int deltaX = -4; deltaX < 5; deltaX++) {
          for (int deltaY = -4; deltaY < 5; deltaY++) {
            freeTiles.remove((y + deltaY) * TILES_X + x + deltaX);
          }
        }
      }
    }
    TagManager tm = world.getManager(TagManager);
    var camera = addEntity([new Transform(0, 0), new Camera()]);
    tm.register(camera, 'camera');
  }

  List<EntitySystem> getSystems() {
    return [

            new TweeningSystem(),
            new MovementSystem(),
            new AttackerSystem(),
            new DefenderSystem(),
            new ConquerableUnitSystem(),

            new InputHandlingSystem(),
            new AiSystem(),

            new CanvasCleaningSystem(canvas),
            new TileRenderingSystem(buffer.context2D, spriteSheet),
            new UnitStatusRenderingSystem(buffer.context2D),
            new RenderingSystem(buffer.context2D, spriteSheet),
            new FogOfWarRenderingSystem(buffer.context2D),
            new SelectionRenderingSystem(buffer.context2D, spriteSheet),
            new BufferToCanvasRenderingSystem(ctx, buffer),
            new MinimapRenderingSystem(ctx),
            new TurnMessageRenderingSystem(ctx),
            new FactionSelectionScreenRenderingSystem(ctx),
            new FpsRenderingSystem(ctx),

            new KilledInActionSystem(),
            new AnalyticsSystem(AnalyticsSystem.GITHUB, 'ld30')
    ];
  }

  @override
  Future onInit() {
    world.addManager(new UnitManager());
    world.addManager(new SpawnerManager());
    world.addManager(new TurnManager());
    world.addManager(new TagManager());
    world.addManager(new FogOfWarManager());
    return super.onInit();
  }

  @override
  Future onInitDone() {
    world.processEntityChanges();
    UnitManager unitManager = world.getManager(UnitManager);
    FogOfWarManager fowManager = world.getManager(FogOfWarManager);
    unitManager.factionUnits.forEach((_, entities) => entities.where((entity) => entity != null).forEach((entity) => fowManager.uncoverTiles(entity)));
  }
}
