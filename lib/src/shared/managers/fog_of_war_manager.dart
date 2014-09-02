part of shared;

class FogOfWarManager extends Manager {
  ComponentMapper<Unit> um;
  ComponentMapper<Transform> tm;
  bool hasChanges = false;

  Map<String, List<List<bool>>> tiles = {F_HELL: new List.generate(TILES_X, (_) => new List.generate(TILES_Y, (_) => false)),
                                         F_HEAVEN: new List.generate(TILES_X, (_) => new List.generate(TILES_Y, (_) => false)),
                                         F_FIRE: new List.generate(TILES_X, (_) => new List.generate(TILES_Y, (_) => false)),
                                         F_ICE: new List.generate(TILES_X, (_) => new List.generate(TILES_Y, (_) => false)),
                                         F_NEUTRAL: new List.generate(TILES_X, (_) => new List.generate(TILES_Y, (_) => false)),
                                        };

  void uncoverTiles(Entity entity) {
    var t = tm.get(entity);
    var u = um.get(entity);

    for (int y = -u.viewRange; y <= u.viewRange; y++) {
      for (int x = -u.viewRange; x <= u.viewRange; x++) {
        if (x.abs() + y.abs() <= u.viewRange && t.x + x >= 0 && t.x + x < TILES_X && t.y + y >= 0 && t.y + y < TILES_Y) {
          tiles[u.faction][t.x + x][t.y + y] = true;
        }
      }
    }
    hasChanges = true;
  }
}
