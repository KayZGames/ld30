part of shared;

class KilledInActionSystem extends EntityProcessingSystem {
  ComponentMapper<Unit> um;
  ComponentMapper<Defeated> dm;
  GameManager gameManager;
  KilledInActionSystem() : super(Aspect.getAspectForAllOf([Unit, Defeated]).exclude([Conquerable]));

  @override
  void processEntity(Entity entity) {
    var unit = um.get(entity);
    var defeated = dm.get(entity);
    gameManager.addLostUnit(unit.faction);
    gameManager.addDefeatedUnit(defeated.faction);

    entity.deleteFromWorld();
  }
}
