library client;

import 'dart:html' hide Player, Timeline;
export 'dart:html' hide Player, Timeline;

import 'package:ld30/shared.dart';
export 'package:ld30/shared.dart';

import 'package:canvas_query/canvas_query.dart';
export 'package:canvas_query/canvas_query.dart';
import 'package:gamedev_helpers/gamedev_helpers.dart';
export 'package:gamedev_helpers/gamedev_helpers.dart';

@MirrorsUsed(targets: const [RenderingSystem, InputHandlingSystem,
                             TileRenderingSystem, BufferToCanvasRenderingSystem,
                             SelectionRenderingSystem,
                             AttackerSystem, DefenderSystem, MovementSystem,
                             KilledInActionSystem, UnitManager, UnitStatusRenderingSystem,
                             SpawnerManager, TurnManager, AiSystem, ConquerableUnitSystem,
                             MinimapRenderingSystem, FogOfWarRenderingSystem,
                             FogOfWarManager, MenuScreenRenderingSystem,
                             TurnMessageRenderingSystem, TileManager, GameManager,

                             DebugInfluenceRenderingSsystem
                            ])
import 'dart:mirrors';

//part 'src/client/systems/name.dart';
part 'src/client/systems/tile_rendering_system.dart';
part 'src/client/systems/unit_status_rendering_system.dart';
part 'src/client/systems/minimap_rendering_system.dart';
part 'src/client/systems/fog_of_war_rendering_system.dart';
part 'src/client/systems/menu_screen_rendering_system.dart';
part 'src/client/systems/turn_message_rendering_system.dart';
part 'src/client/systems/debug_influence_rendering_ssystem.dart';
part 'src/client/systems/selection_rendering_system.dart';
part 'src/client/systems/buffer_to_canvas_rendering_system.dart';
part 'src/client/systems/rendering_system.dart';
part 'src/client/systems/input_handling_system.dart';

class Game extends GameBase {
  CanvasElement buffer;
  Game() : super('ld30', 'canvas', 800, 600, bodyDefsName: null) {
    buffer = new CanvasElement();
    eventBus.on(gameStartedEvent).listen((_) {
      GameManager gameManager = world.getManager(GameManager);
      buffer.width = gameManager.sizeX * TILE_SIZE;
      buffer.height = gameManager.sizeY * TILE_SIZE;
      buffer.context2D..textBaseline = "top"
                      ..font = '12px Verdana';
    });
  }

  void createEntities() {
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
//            new DebugInfluenceRenderingSsystem(buffer.context2D),
            new SelectionRenderingSystem(buffer.context2D, spriteSheet),
            new BufferToCanvasRenderingSystem(ctx, buffer),
            new MinimapRenderingSystem(ctx),
            new TurnMessageRenderingSystem(ctx),
            new MenuScreenRenderingSystem(ctx),

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
    world.addManager(new TileManager());
    world.addManager(new GameManager());
    return super.onInit();
  }

}