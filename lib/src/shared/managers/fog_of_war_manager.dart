part of shared;

class FogOfWarManager extends Manager {
  ComponentMapper<Unit> um;
  ComponentMapper<Transform> tm;
  bool hasChanges = false;

  Map<String, List<List<bool>>> tiles = {F_HELL: new List.generate(gameState.sizeX, (_) => new List.generate(gameState.sizeY, (_) => false)),
                                         F_HEAVEN: new List.generate(gameState.sizeX, (_) => new List.generate(gameState.sizeY, (_) => false)),
                                         F_FIRE: new List.generate(gameState.sizeX, (_) => new List.generate(gameState.sizeY, (_) => false)),
                                         F_ICE: new List.generate(gameState.sizeX, (_) => new List.generate(gameState.sizeY, (_) => false)),
                                         F_NEUTRAL: new List.generate(gameState.sizeX, (_) => new List.generate(gameState.sizeY, (_) => false)),
                                        };

  void uncoverTiles(Entity entity) {
    var t = tm.get(entity);
    var u = um.get(entity);

    for (int y = -u.viewRange; y <= u.viewRange; y++) {
      for (int x = -u.viewRange; x <= u.viewRange; x++) {
        if (x.abs() + y.abs() <= u.viewRange && t.x + x >= 0 && t.x + x < gameState.sizeX && t.y + y >= 0 && t.y + y < gameState.sizeY) {
          tiles[u.faction][t.x + x][t.y + y] = true;
        }
      }
    }
    hasChanges = true;
  }
}
