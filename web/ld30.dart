import 'package:ld30/client.dart';

@MirrorsUsed(targets: const [RenderingSystem, InputHandlingSystem,
                             TileRenderingSystem, BufferToCanvasRenderingSystem,
                             SpawningSystem, SelectionRenderingSystem
                            ])
import 'dart:mirrors';

void main() {
  new Game().start();
}

class Game extends GameBase {
  CanvasElement buffer;
  Game() : super('ld30', 'canvas', 800, 600, bodyDefsName: null) {
    buffer = new CanvasElement(width: TILES_X * TILE_SIZE, height: TILES_Y * TILE_SIZE);
  }

  void createEntities() {
    addEntity([new Transform(TILES_X ~/ 2, TILES_Y - 1), new Renderable('gate_hell'), new Spawner('hell')]);
    addEntity([new Transform(TILES_X ~/ 2, 0), new Renderable('gate_heaven'), new Spawner('heaven')]);
    addEntity([new Transform(0, TILES_Y ~/ 2), new Renderable('gate_fire'), new Spawner('fire')]);
    addEntity([new Transform(TILES_X - 1, TILES_Y ~/ 2), new Renderable('gate_ice'), new Spawner('ice')]);
    addEntity([new Transform(0, 0), new Camera()]);
    addEntity([new Transform(32, 32), new Unit('hell', 10), new Renderable('peasant_hell')]);
  }

  List<EntitySystem> getSystems() {
    return [
            new SpawningSystem(),
            new TweeningSystem(),
            new CanvasCleaningSystem(canvas),
            new InputHandlingSystem(),
            new TileRenderingSystem(buffer.context2D, spriteSheet),
            new RenderingSystem(buffer.context2D, spriteSheet),
            new SelectionRenderingSystem(buffer.context2D, spriteSheet),
            new BufferToCanvasRenderingSystem(ctx, buffer),
            new FpsRenderingSystem(ctx),
            new AnalyticsSystem(AnalyticsSystem.GITHUB, 'ld30')
    ];
  }

  @override
  Future onInit() {
    world.addManager(new UnitManager());
    return super.onInit();
  }
}
