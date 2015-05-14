part of shared;

class ConquerableUnitRecoverySystem extends EntityProcessingSystem {
  Mapper<Unit> um;
  ConquerableUnitRecoverySystem() : super(Aspect.getAspectForAllOf([Unit, Conquerable]));

  @override
  void processEntity(Entity entity) {
    var u = um[entity];
    if (u.health < u.maxHealth) {
      u.health = min(u.health + u.maxHealth * 0.2, u.maxHealth);
    }
  }
}