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
    u.faction = d.faction;
    entity..removeComponent(Defeated)
          ..changedInWorld();

    fowManager.uncoverTiles(entity);
    unitManager.factionUnits[oldFaction].remove(entity.id);
    unitManager.factionUnits[u.faction][entity.id] = entity;
    if (sm.has(entity)) {
      spawnerManager.factionSpawner[oldFaction].remove(entity.id);
      spawnerManager.factionSpawner[u.faction][entity.id] = entity;
      tileManager.growInfluence(entity, u.faction, captured: true);
      u.health = u.maxHealth * 0.2;
    }
    if (u.faction == gameManager.playerFaction) {
      eventBus.fire(new AnalyticsTrackEvent('Castle', 'conquered from $oldFaction'));
    } else if (oldFaction == gameManager.playerFaction) {
      eventBus.fire(new AnalyticsTrackEvent('Castle', 'lost to ${u.faction}'));
    }
  }
}
