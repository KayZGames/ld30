library shared;

import 'package:gamedev_helpers/gamedev_helpers_shared.dart';
import 'package:a_star/a_star.dart';
import 'dart:collection';

part 'src/shared/components.dart';

part 'src/shared/systems/ai_system.dart';
part 'src/shared/terrain_map.dart';
part 'src/shared/systems/movement_system.dart';
part 'src/shared/systems/attacker_system.dart';
part 'src/shared/systems/defender_system.dart';
part 'src/shared/systems/killed_in_action_system.dart';
part 'src/shared/systems/conquerable_unit_system.dart';
part 'src/shared/systems/conquerable_unit_recovery_system.dart';
part 'src/shared/managers/unit_manager.dart';
part 'src/shared/managers/spawner_manager.dart';
part 'src/shared/managers/turn_manager.dart';
part 'src/shared/managers/fog_of_war_manager.dart';
part 'src/shared/managers/tile_manager.dart';
part 'src/shared/managers/game_manager.dart';

class GameStartedEvent {}

typedef bool AddToQueueCondition(int tileId);
typedef void AddToQueueAction(int tileId);

const TILE_SIZE = 64;
const INFLUENCE_FACTOR = 0.95;

const F_HEAVEN = 'heaven';
const F_HELL = 'hell';
const F_FIRE = 'fire';
const F_ICE = 'ice';
const F_NEUTRAL = 'neutral';
const FACTIONS = const [F_HEAVEN, F_HELL, F_FIRE, F_ICE];
