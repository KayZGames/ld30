part of shared;

class MovementSystem extends EntityProcessingSystem {
  UnitManager unitManager;
  ComponentMapper<Unit> um;
  ComponentMapper<Transform> tm;
  ComponentMapper<Move> mm;

  FogOfWarManager fowManager;
  TagManager tagManager;

  MovementSystem() : super(Aspect.getAspectForAllOf([Transform, Move, Unit]).exclude([Attacker, Defender]));


  @override
  void processEntity(Entity entity) {
    var u = um.get(entity);
    if (u.movesLeft > 0) {
      var t = tm.get(entity);
      var m = mm.get(entity);
      var targetX = t.x + m.x;
      var targetY = t.y + m.y;
      if (targetX >= 0 && targetY >= 0 && targetX < TILES_X && targetY < TILES_Y) {
        var targetEntity = unitManager.getEntity(targetX, targetY);
        if (null == targetEntity) {
          unitManager.unitCoords[t.x][t.y] = null;
          t.x += m.x;
          t.y += m.y;
          unitManager.unitCoords[t.x][t.y] = entity;
          u.movesLeft -= 1;
          fowManager.uncoverTiles(entity);
          if (gameState.currentFaction == gameState.playerFaction) {
            var camera = tagManager.getEntity('camera');
            var cameraTransform = tm.get(camera);
            cameraTransform.x = t.x * TILE_SIZE - 400;
            cameraTransform.y = t.y * TILE_SIZE - 300;
          }
        } else {
          var otherUnit = um.get(targetEntity);
          if (otherUnit.faction != u.faction) {
            targetEntity..addComponent(new Defender(-m.x, -m.y))
                        ..changedInWorld();
            entity..addComponent(new Attacker(m.x, m.y));
            u.movesLeft -= 1;
          }
        }
      }
    }
    entity..removeComponent(Move)
          ..changedInWorld();
  }

}
