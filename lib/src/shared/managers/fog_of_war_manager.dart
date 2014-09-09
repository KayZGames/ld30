part of shared;

class FogOfWarManager extends Manager {
  ComponentMapper<Unit> um;
  ComponentMapper<Transform> tm;
  GameManager gameManager;
  bool hasChanges = false;

  Map<String, List<List<bool>>> tiles;

  @override
  void initialize() {
    eventBus.on(GameStartedEvent).listen((_) {
      tiles = {F_HELL: new List.generate(gameManager.sizeX, (_) => new List.generate(gameManager.sizeY, (_) => false)),
                                           F_HEAVEN: new List.generate(gameManager.sizeX, (_) => new List.generate(gameManager.sizeY, (_) => false)),
                                           F_FIRE: new List.generate(gameManager.sizeX, (_) => new List.generate(gameManager.sizeY, (_) => false)),
                                           F_ICE: new List.generate(gameManager.sizeX, (_) => new List.generate(gameManager.sizeY, (_) => false)),
                                           F_NEUTRAL: new List.generate(gameManager.sizeX, (_) => new List.generate(gameManager.sizeY, (_) => false)),
                                          };
    });
  }

  void uncoverTiles(Entity entity) {
    var t = tm.get(entity);
    var u = um.get(entity);
    var faction = u.faction;
    var tx = t.x;
    var ty = t.y;

    for (int y = -u.viewRange; y <= u.viewRange; y++) {
      for (int x = -u.viewRange; x <= u.viewRange; x++) {
        if (x.abs() + y.abs() <= u.viewRange && tx + x >= 0 && tx + x < gameManager.sizeX && ty + y >= 0 && ty + y < gameManager.sizeY) {
          if (!tiles[faction][tx + x][ty + y]) {
            tiles[faction][tx + x][ty + y] = true;
            gameManager.addScoutedArea(faction);
          }
        }
      }
    }
    hasChanges = true;
  }
}
