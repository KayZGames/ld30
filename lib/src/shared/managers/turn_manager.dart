part of shared;

class TurnManager extends Manager {
  ComponentMapper<Unit> um;
  ComponentMapper<Spawner> sm;
  ComponentMapper<Conquerable> cm;
  UnitManager unitManager;
  TileManager tileManager;
  SpawnerManager spawnerManager;

  void nextTurn() {
    unitManager.factionUnits[gameState.currentFaction]..values.forEach((entity) => um.get(entity).nextTurn());
    spawnerManager.factionSpawner[gameState.currentFaction].values.forEach((entity) => sm.get(entity).spawnTime--);

    gameState.nextFaction();

    unitManager.factionUnits[gameState.currentFaction].values.forEach(recoverConquarable);
    spawnerManager.factionSpawner[gameState.currentFaction].values.forEach(spawnerManager.spawn);
    tileManager.spreadFactionInfluence(gameState.currentFaction);

    world.createAndAddEntity([new NextTurnInfo()]);
  }

  void recoverConquarable(Entity entity) {
    if (cm.has(entity)) {
      var u = um.get(entity);
      if (u.health < u.maxHealth) {
        u.health = min(u.health + u.maxHealth * 0.2, u.maxHealth);
      }
    }
  }
}
