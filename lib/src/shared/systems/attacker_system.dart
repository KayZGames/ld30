part of shared;

class AttackerSystem extends EntityProcessingSystem {
  Mapper<Attacker> am;
  Mapper<Transform> tm;
  Mapper<Unit> um;
  UnitManager unitManager;

  AttackerSystem() : super(Aspect.getAspectForAllOf([Transform, Attacker, Unit]));

  @override
  void processEntity(Entity entity) {
    var a = am[entity];
    var t = tm[entity];

    a.duration -= world.delta;
    if (a.duration <= 0.0) {
      entity..removeComponent(Attacker)
            ..changedInWorld();
      t.displacementX = 0.0;
      t.displacementY = 0.0;
      var enemyEntity = unitManager.getEntity(t.x + a.x, t.y + a.y);
      var unit = um[entity];
      var enemyUnit = um[enemyEntity];
      var strength = unit.offStrength + enemyUnit.defStrength;
      var counter = 0;
      while (counter < 10 && enemyUnit.health > 0.0 && unit.health > 0.0) {
        var fightResult = random.nextDouble() * strength;
        if (fightResult <= unit.offStrength) {
          enemyUnit.health -= unit.offStrength / 10;
        } else {
          unit.health -= enemyUnit.defStrength / 10;
        }
        counter++;
      }
      if (enemyUnit.health <= 0.0) {
        enemyEntity..addComponent(new Defeated(unit.faction))
                   ..changedInWorld();
      }
      if (unit.health <= 0.0) {
        entity..addComponent(new Defeated(enemyUnit.faction))
              ..changedInWorld();
      }
    } else {
      var displacementFactor = sin(PI/2 * a.duration * 20.0);
      t.displacementX = TILE_SIZE / 2 * a.x * displacementFactor;
      t.displacementY = TILE_SIZE / 2 * a.y * displacementFactor;
    }
  }
}
