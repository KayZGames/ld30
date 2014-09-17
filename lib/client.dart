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
                             EndingScreenRenderingSystem

//                             DebugInfluenceRenderingSsystem
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
part 'src/client/systems/ending_screen_rendering_system.dart';

class Game extends GameBase {
  CanvasElement buffer;
  Game() : super('ld30', 'canvas', 800, 600, bodyDefsName: null) {
    buffer = new CanvasElement();
    eventBus.on(GameStartedEvent).listen((_) {
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
            new EndingScreenRenderingSystem(ctx),

            new KilledInActionSystem(),
            new AnalyticsSystem(AnalyticsSystem.GITHUB, 'ld30-postcompo')
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

// Dawnbringer 32 palette
class Colors {
  static const BLACK = "#000000";
  static const VALHALLE = "#222034";
  static const LOULOU = "#45283c";
  static const OILED_CEDAR = "#663931";
  static const ROPE = "#8f563b";
  static const TAHITI_GOLD = "#df7126";
  static const TWINE = "#d9a066";
  static const PANCHO = "#eec39a";
  static const GOLDEN_FIZZ = "#fbf236";
  static const ATLANTIS = "#99e550";
  static const CHRISTI = "#6abe30";
  static const ELF_GREEN = "#37946e";
  static const DELL = "#4b692f";
  static const VERDIGRIS = "#524b24";
  static const OPAL = "#323c39";
  static const DEEP_KOAMARU = "#3f3f74";
  static const VENICE_BLUE = "#306082";
  static const ROYAL_BLUE = "#5b6ee1";
  static const CORNFLOWER = "#639bff";
  static const VIKING = "#5fcde4";
  static const LIGHT_STEEL_BLUE = "#cbdbfc";
  static const WHITE = "#ffffff";
  static const HEATHER = "#9badb7";
  static const TOPAZ = "#847e87";
  static const DIM_GRAY = "#696a6a";
  static const SMOKEY_ASH = "#595652";
  static const CLAIRVOYANT = "#76428a";
  static const BROWN = "#ac3232";
  static const MANDY = "#d95763";
  static const PLUM = "#d77bba";
  static const RAIN_FOREST = "#8f974a";
  static const STINGER = "#8a6f30";


  static const MENU_BACKGROUND = Colors.RAIN_FOREST;
  static const MENU_BORDER = Colors.DEEP_KOAMARU;
  static const MENU_LABEL = Colors.OPAL;
  static const MENU_LABEL_SELECTED = Colors.HEATHER;
  static const MENU_BUTTON = Colors.CHRISTI;
  static const MENU_BUTTON_BORDER = Colors.VERDIGRIS;
  static const MENU_BUTTON_SELECTED = Colors.DELL;
  static const MENU_BUTTON_HIGHLIGHTED = Colors.ATLANTIS;
  static const MENU_BUTTON_SELECTED_HIGHLIGHTED = Colors.ELF_GREEN;
}

