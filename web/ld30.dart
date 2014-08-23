import 'package:ld30/client.dart';

@MirrorsUsed(targets: const [RenderingSystem, CameraPositionSystem,
                             TileRenderingSystem, BufferToCanvasRenderingSystem
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
    addEntity([new Transform(TILES_X / 2, TILES_Y - 1), new Renderable('gate_hell')]);
    addEntity([new Transform(TILES_X / 2, 0), new Renderable('gate_heaven')]);
    addEntity([new Transform(0, TILES_Y / 2), new Renderable('gate_fire')]);
    addEntity([new Transform(TILES_X - 1, TILES_Y / 2), new Renderable('gate_ice')]);
    addEntity([new Transform(0, 0), new Camera()]);
  }

  List<EntitySystem> getSystems() {
    return [
            new TweeningSystem(),
            new CanvasCleaningSystem(canvas),
            new CameraPositionSystem(),
            new TileRenderingSystem(buffer.context2D, spriteSheet),
            new RenderingSystem(buffer.context2D, spriteSheet),
            new BufferToCanvasRenderingSystem(ctx, buffer),
            new FpsRenderingSystem(ctx),
            new AnalyticsSystem(AnalyticsSystem.GITHUB, 'ld30')
    ];
  }
}
