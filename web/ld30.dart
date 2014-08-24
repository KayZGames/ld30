import 'package:ld30/client.dart';

@MirrorsUsed(targets: const [RenderingSystem, InputHandlingSystem,
                             TileRenderingSystem, BufferToCanvasRenderingSystem,
                             SelectionRenderingSystem,
                             AttackerSystem, DefenderSystem, MovementSystem,
                             KilledInActionSystem, UnitManager, UnitStatusRenderingSystem,
                             SpawnerManager, TurnManager, AiSystem, ConquerableUnitSystem
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
    addEntity([new Transform(TILES_X ~/ 2, TILES_Y - 5), new Renderable('castle'), new Spawner(2), new Unit(F_NEUTRAL, 0, 0), new Conquerable()]);
    addEntity([new Transform(0, 0), new Camera()]);
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
            new SelectionRenderingSystem(buffer.context2D, spriteSheet),
            new BufferToCanvasRenderingSystem(ctx, buffer),
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
    return super.onInit();
  }
}
