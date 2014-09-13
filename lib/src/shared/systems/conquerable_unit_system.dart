part of shared;

class ConquerableUnitSystem extends EntityProcessingSystem {
  ComponentMapper<Unit> um;
  ComponentMapper<Defeated> dm;
  ComponentMapper<Spawner> sm;

  UnitManager unitManager;
  SpawnerManager spawnerManager;
  FogOfWarManager fowManager;
  TileManager tileManager;
  GameManager gameManager;

  ConquerableUnitSystem() : super(Aspect.getAspectForAllOf([Unit, Conquerable, Defeated]));

  @override
  void processEntity(Entity entity) {
    var d = dm.get(entity);
    var u = um.get(entity);
    var oldFaction = u.faction;
    var newFaction = d.faction;

    if (sm.has(entity)) {
      spawnerManager.switchFaction(entity, newFaction);
      tileManager.growInfluence(entity, newFaction, captured: true);
      u.health = u.maxHealth * 0.2;
    }
    unitManager.switchFaction(entity, newFaction);
    gameManager.addConqueredCastle(newFaction);
    gameManager.addLostCastle(oldFaction);
    fowManager.uncoverTiles(entity);
    if (newFaction == gameManager.playerFaction) {
      eventBus.fire(new AnalyticsTrackEvent('Castle', 'conquered from $oldFaction'));
    } else if (oldFaction == gameManager.playerFaction) {
      eventBus.fire(new AnalyticsTrackEvent('Castle', 'lost to ${newFaction}'));
    }
    entity..removeComponent(Defeated)
          ..changedInWorld();
  }
}
