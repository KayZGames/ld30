part of shared;


class Renderable extends Component {
  String name;
  Renderable(this.name);
}

class Transform extends Component {
  double x, y;
  Transform(num x, num y) : x = x.toDouble(), y = y.toDouble();
}

class Camera extends Component {}