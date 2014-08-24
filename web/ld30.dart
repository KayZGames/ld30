import 'package:ld30/client.dart';

@MirrorsUsed(targets: const [RenderingSystem, InputHandlingSystem,
                             TileRenderingSystem, BufferToCanvasRenderingSystem,
                             SpawningSystem, SelectionRenderingSystem,
                             AttackerSystem, DefenderSystem, MovementSystem,
                             KilledInActionSystem, UnitManager, UnitStatusRenderingSystem
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
    addEntity([new Transform(TILES_X ~/ 2, TILES_Y - 1), new Renderable('gate_hell'), new Spawner('hell')]);
    addEntity([new Transform(TILES_X ~/ 2, 0), new Renderable('gate_heaven'), new Spawner('heaven')]);
    addEntity([new Transform(0, TILES_Y ~/ 2), new Renderable('gate_fire'), new Spawner('fire')]);
    addEntity([new Transform(TILES_X - 1, TILES_Y ~/ 2), new Renderable('gate_ice'), new Spawner('ice')]);
    addEntity([new Transform(0, 0), new Camera()]);
    addEntity([new Transform(32, 32), new Unit('hell', 10), new Renderable('peasant_hell')]);
    addEntity([new Transform(33, 33), new Unit('heaven', 10), new Renderable('peasant_heaven')]);
  }

  List<EntitySystem> getSystems() {
    return [
            new TweeningSystem(),
            new SpawningSystem(),
            new MovementSystem(),
            new AttackerSystem(),
            new DefenderSystem(),

            new InputHandlingSystem(),

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
    return super.onInit();
  }
}
