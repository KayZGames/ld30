import 'package:ld30/client.dart';

@MirrorsUsed(targets: const [
                            ])
import 'dart:mirrors';

void main() {
  new Game().start();
}

class Game extends GameBase {

  Game() : super.noAssets('ld30', 'canvas', 800, 600);

  void createEntities() {
    // addEntity([Component1, Component2]);
  }

  List<EntitySystem> getSystems() {
    return [
            new TweeningSystem(),
            new CanvasCleaningSystem(canvas),
            new FpsRenderingSystem(ctx),
            new AnalyticsSystem(AnalyticsSystem.GITHUB, 'ld30')
    ];
  }
}
