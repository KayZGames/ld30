part of shared;

class KilledInActionSystem extends EntityProcessingSystem {
  Mapper<Unit> um;
  Mapper<Defeated> dm;
  GameManager gameManager;
  KilledInActionSystem() : super(Aspect.getAspectForAllOf([Unit, Defeated]).exclude([Conquerable]));

  @override
  void processEntity(Entity entity) {
    var unit = um[entity];
    var defeated = dm[entity];
    gameManager.addLostUnit(unit.faction);
    gameManager.addDefeatedUnit(defeated.faction);

    entity.deleteFromWorld();
  }
}
