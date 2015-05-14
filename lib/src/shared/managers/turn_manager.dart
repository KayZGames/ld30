part of shared;

class TurnManager extends Manager {
  Mapper<Unit> um;
  Mapper<Spawner> sm;
  Mapper<Conquerable> cm;
  UnitManager unitManager;
  TileManager tileManager;
  SpawnerManager spawnerManager;
  GameManager gameManager;

  void nextTurn() {
    unitManager.factionUnits[gameManager.currentFaction]..values.forEach((entity) => um[entity].nextTurn());
    spawnerManager.factionSpawner[gameManager.currentFaction].values.forEach((entity) => sm[entity].spawnTime--);

    gameManager.nextFaction();

    unitManager.factionUnits[gameManager.currentFaction].values.forEach(recoverConquarable);
    spawnerManager.factionSpawner[gameManager.currentFaction].values.forEach(spawnerManager.spawn);
    tileManager.spreadFactionInfluence(gameManager.currentFaction);

    world.createAndAddEntity([new NextTurnInfo()]);
  }

  void recoverConquarable(Entity entity) {
    if (cm.has(entity)) {
      var u = um[entity];
      if (u.health < u.maxHealth) {
        u.health = min(u.health + u.maxHealth * 0.2, u.maxHealth);
      }
    }
  }
}
