part of shared;


class Renderable extends Component {
  String name;
  Renderable(this.name);
}

class Transform extends Component {
  int x, y;
  Transform(this.x, this.y);
}

class Camera extends Component {}

class Spawner extends Component {
  double spawnTime = 10000.0;
  String type;
  Spawner(this.type);
}

class Unit extends Component {
  String alignment;
  final int maxMoves;
  int movesLeft;
  Unit(this.alignment, int maxMoves) : maxMoves = maxMoves, movesLeft = maxMoves;
}

class Selected extends Component {}