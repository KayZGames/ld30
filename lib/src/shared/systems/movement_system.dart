part of shared;

class MovementSystem extends EntityProcessingSystem {
  UnitManager unitManager;
  Mapper<Unit> um;
  Mapper<Transform> tm;
  Mapper<Move> mm;

  FogOfWarManager fowManager;
  TagManager tagManager;
  GameManager gameManager;

  MovementSystem() : super(Aspect.getAspectForAllOf([Transform, Move, Unit]).exclude([Attacker, Defender]));


  @override
  void processEntity(Entity entity) {
    var u = um[entity];
    if (u.movesLeft > 0) {
      var t = tm[entity];
      var m = mm[entity];
      var targetX = t.x + m.x;
      var targetY = t.y + m.y;
      if (targetX >= 0 && targetY >= 0 && targetX < gameManager.sizeX && targetY < gameManager.sizeY) {
        var targetEntity = unitManager.getEntity(targetX, targetY);
        if (null == targetEntity) {
          unitManager.unitCoords[t.x][t.y] = null;
          t.x += m.x;
          t.y += m.y;
          unitManager.unitCoords[t.x][t.y] = entity;
          u.movesLeft -= 1;
          fowManager.uncoverTiles(entity);
          if (gameManager.currentFaction == gameManager.playerFaction) {
            var camera = tagManager.getEntity('camera');
            var cameraTransform = tm[camera];
            cameraTransform.x = t.x * TILE_SIZE - 400;
            cameraTransform.y = t.y * TILE_SIZE - 300;
          }
        } else {
          if (unitManager.isOccupied(targetEntity)) {
            // try again next iteration
            return;
          }
          var otherUnit = um[targetEntity];
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
