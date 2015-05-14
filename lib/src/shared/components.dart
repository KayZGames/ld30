part of shared;

class Renderable extends Component {
  String name;
  Renderable(this.name);
}

class Transform extends Component {
  int x, y;
  double displacementX, displacementY;
  Transform(this.x, this.y)
      : displacementX = 0.0,
        displacementY = 0.0;
}

class Camera extends Component {}

class Spawner extends Component {
  int spawnTime;
  int maxSpawnTime;
  Spawner(int maxSpawnTime)
      : maxSpawnTime = maxSpawnTime,
        spawnTime = maxSpawnTime;
  Spawner.instant(int maxSpawnTime)
      : maxSpawnTime = maxSpawnTime,
        spawnTime = 0;
}

class Unit extends Component {
  String faction;
  int level;
  int maxMoves;
  int movesLeft;
  int viewRange;
  double offStrength;
  double defStrength;
  double maxHealth;
  double health;
  double influence;
  double influenceWeight;
  Unit(this.faction, int maxMoves, this.level, this.viewRange,
      {this.influence: 5.0})
      : maxMoves = maxMoves,
        movesLeft = maxMoves,
        offStrength = 2.0,
        defStrength = 1.0,
        maxHealth = 2.0,
        health = 2.0,
        influenceWeight = 1.0;

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
  double power;
  double duration;
  Attacker(this.x, this.y)
      : duration = 0.1,
        power = 1.0;
}
class Defender extends Component {
  int x, y;
  double duration;
  Defender(this.x, this.y) : duration = 0.1;
}

class Defeated extends Component {
  String faction;
  Defeated(this.faction);
}
class Conquerable extends Component {}

class NextTurnInfo extends Component {
  double timer = 1.0;
}

class Tile extends Component {
  String faction = F_NEUTRAL;
  double influence;
  Tile() : influence = 1.0;
}

class Redraw extends Component {}
