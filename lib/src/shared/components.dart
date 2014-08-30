part of shared;


class Renderable extends Component {
  String name;
  Renderable(this.name);
}

class Transform extends Component {
  int x, y;
  double displacementX = 0.0, displacementY = 0.0;
  Transform(this.x, this.y);
}

class Camera extends Component {}

class Spawner extends Component {
  int spawnTime;
  int maxSpawnTime;
  Spawner(int maxSpawnTime) : maxSpawnTime = maxSpawnTime, spawnTime = maxSpawnTime;
  Spawner.instant(int maxSpawnTime) : maxSpawnTime = maxSpawnTime, spawnTime = 0;
}

class Unit extends Component {
  String faction;
  int level;
  final int maxMoves;
  int movesLeft;
  int viewRange;
  double offStrength = 2.0;
  double defStrength = 1.0;
  double maxHealth = 2.0;
  double health = 2.0;
  double influence;
  double influenceWeight = 1.0;
  Unit(this.faction, int maxMoves, this.level, this.viewRange, {this.influence: 5.0}) : maxMoves = maxMoves, movesLeft = maxMoves;

  void nextTurn() {
    movesLeft = maxMoves;
  }
}

class Selected extends Component {}
class Move extends Component {
  int x, y;
  Move(this.x, this.y);
}
class Attacker extends Component {
  int x, y;
  double power = 1.0;
  double duration = 100.0;
  Attacker(this.x, this.y);
}
class Defender extends Component {
  int x, y;
  double duration = 100.0;
  Defender(this.x, this.y);
}

class Defeated extends Component {
  String faction;
  Defeated(this.faction);
}
class Conquerable extends Component {}

class NextTurnInfo extends Component {
  double timer = 1000.0;
}

class Tile extends Component {
  String faction = F_NEUTRAL;
  double influence = 1.0;
}

class Redraw extends Component {}

