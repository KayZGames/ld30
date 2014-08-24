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
  double spawnTime = 10000.0;
  String type;
  Spawner(this.type);
}

class Unit extends Component {
  String faction;
  final int maxMoves;
  int movesLeft;
  double offStrength = 2.0;
  double defStrength = 1.0;
  double maxHealth = 2.0;
  double health = 2.0;
  Unit(this.faction, int maxMoves) : maxMoves = maxMoves, movesLeft = maxMoves;

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

class KilledInAction extends Component {}