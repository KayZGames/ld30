library shared;

import 'package:gamedev_helpers/gamedev_helpers_shared.dart';
import 'package:a_star/a_star.dart';
import 'dart:collection';

part 'src/shared/components.dart';

//part 'src/shared/systems/name.dart';
part 'src/shared/systems/ai.dart';
part 'src/shared/systems/logic.dart';
part 'src/shared/managers.dart';

typedef bool AddToQueueCondition(int tileId);
typedef void AddToQueueAction(int tileId);

const TILES_X = 64;
const TILES_Y = 64;
const TILE_SIZE = 64;
const MAX_TILES = TILES_X * TILES_Y;
const INFLUENCE_FACTOR = 0.95;

const F_HEAVEN = 'heaven';
const F_HELL = 'hell';
const F_FIRE = 'fire';
const F_ICE = 'ice';
const F_NEUTRAL = 'neutral';
const FACTIONS = const [F_HEAVEN, F_HELL, F_FIRE, F_ICE];

class GameState {
  bool menu = true;
  int _player = FACTIONS.length - 1;
  String playerFaction = F_HELL;
  String currentFaction = FACTIONS[FACTIONS.length - 1];

  void nextFaction() {
    currentFaction = FACTIONS[_player++ % FACTIONS.length];
  }
}

final GameState gameState = new GameState();