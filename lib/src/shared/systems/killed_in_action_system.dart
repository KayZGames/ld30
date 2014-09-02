part of shared;

class KilledInActionSystem extends EntityProcessingSystem {
  KilledInActionSystem() : super(Aspect.getAspectForAllOf([Defeated]).exclude([Conquerable]));

  @override
  void processEntity(Entity entity) {
    entity.deleteFromWorld();
  }
}
