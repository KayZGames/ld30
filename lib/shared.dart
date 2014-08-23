library shared;

import 'package:gamedev_helpers/gamedev_helpers_shared.dart';

part 'src/shared/components.dart';

//part 'src/shared/systems/name.dart';
part 'src/shared/systems/logic.dart';
part 'src/shared/managers.dart';

const TILES_X = 64;
const TILES_Y = 64;
const TILE_SIZE = 32;

const P_HEAVEN = 'heaven';
const P_HELL = 'hell';
const P_FIRE = 'fire';
const P_ICE = 'ice';

class GameState {
  String alignment = 'hell';
}

final GameState gameState = new GameState();