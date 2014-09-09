part of shared;

class GameManager extends Manager {
  final turnStatistics = <TurnStatistics>[new TurnStatistics()];
  int turn = 0;
  double startTime;

  int sizeX = 64;
  int sizeY = 64;
  bool menu = true;
  int _player = FACTIONS.length - 1;
  String playerFaction = F_HELL;
  String currentFaction = FACTIONS[FACTIONS.length - 1];

  void startGame() {
    startTime = world.time;
    eventBus.fire(new GameStartedEvent(), sync: true);
    menu = false;
    for (int y = 0; y < sizeY; y++) {
      for (int x = 0; x < sizeX; x++) {
        world.createAndAddEntity([new Transform(x, y), new Tile()]);
      }
    }

    world.createAndAddEntity([new Transform(sizeX ~/ 2, sizeY - 1), new Renderable('gate'), new Spawner.instant(3), new Unit(F_HELL, 0, 0, 4, influence: 20.0)]);
    world.createAndAddEntity([new Transform(sizeX ~/ 2, 0), new Renderable('gate'), new Spawner.instant(3), new Unit(F_HEAVEN, 0, 0, 4, influence: 20.0)]);
    world.createAndAddEntity([new Transform(0, sizeY ~/ 2), new Renderable('gate'), new Spawner.instant(3), new Unit(F_FIRE, 0, 0, 4, influence: 20.0)]);
    world.createAndAddEntity([new Transform(sizeX - 1, sizeY ~/ 2), new Renderable('gate'), new Spawner.instant(3), new Unit(F_ICE, 0, 0, 4, influence: 20.0)]);

    List<int> freeTiles = new List.generate(sizeX * sizeY, (index) => index);
    freeTiles.removeWhere((value) => value % sizeY < 3 || value % sizeY > sizeX - 3 || value ~/ sizeX < 3 || value ~/ sizeX > sizeY - 3);
    int castles = 0;
    while (freeTiles.length > 0 && castles < 40) {
      var pos = freeTiles[random.nextInt(freeTiles.length)];
      var x = pos % sizeX;
      var y = pos ~/ sizeX;
      world.createAndAddEntity([new Transform(x, y), new Renderable('castle'), new Spawner(3), new Unit(F_NEUTRAL, 0, 0, 3), new Conquerable()]);
      castles++;
      for (int deltaX = -4; deltaX < 5; deltaX++) {
        for (int deltaY = -4; deltaY < 5; deltaY++) {
          freeTiles.remove((y + deltaY) * sizeX + x + deltaX);
        }
      }
    }

    world.processEntityChanges();
    UnitManager unitManager = world.getManager(UnitManager);
    FogOfWarManager fowManager = world.getManager(FogOfWarManager);
    unitManager.factionUnits.forEach((_, entityMap) => entityMap.values.forEach((entity) => fowManager.uncoverTiles(entity)));
    TileManager tileManager = world.getManager(TileManager);
    tileManager.initInfluence();
    FACTIONS.forEach((faction) => tileManager.spreadFactionInfluence(faction));
  }

  void nextFaction() {
    _player = (_player + 1) % FACTIONS.length;
    turnStatistics[turn].timeAfterTurn[currentFaction] = world.time;
    currentFaction = FACTIONS[_player];
    if (_player == 0) {
      turnStatistics.add(new TurnStatistics());
      turn++;
    }
  }

  int get maxTiles => sizeX * sizeY;

  addLostUnit(String faction) => turnStatistics[turn].lostUnits[faction] += 1;
  addLostCastle(String faction) => turnStatistics[turn].lostCastles[faction] += 1;
  addConqueredCastle(String faction) => turnStatistics[turn].conqueredCastles[faction] += 1;
  addDefeatedUnit(String faction) => turnStatistics[turn].defeatedUnits[faction] += 1;
  addSpawnedUnit(String faction) => turnStatistics[turn].spawnedUnits[faction] += 1;
  addScoutedArea(String faction) => turnStatistics[turn].scoutedArea[faction] += 1;
}

class TurnStatistics {
  var lostUnits = {F_HELL: 0, F_HEAVEN: 0, F_FIRE: 0, F_ICE: 0};
  var lostCastles = {F_HELL: 0, F_HEAVEN: 0, F_FIRE: 0, F_ICE: 0, F_NEUTRAL: 0};
  var defeatedUnits = {F_HELL: 0, F_HEAVEN: 0, F_FIRE: 0, F_ICE: 0, F_NEUTRAL: 0};
  var conqueredCastles = {F_HELL: 0, F_HEAVEN: 0, F_FIRE: 0, F_ICE: 0};
  var spawnedUnits = {F_HELL: 0, F_HEAVEN: 0, F_FIRE: 0, F_ICE: 0};
  var timeAfterTurn = {F_HELL: 0.0, F_HEAVEN: 0.0, F_FIRE: 0.0, F_ICE: 0.0};
  var scoutedArea = {F_HELL: 0, F_HEAVEN: 0, F_FIRE: 0, F_ICE: 0, F_NEUTRAL: 0};
  // TODO once issue #26 is fixed
  var ownedArea = {F_HELL: 0, F_HEAVEN: 0, F_FIRE: 0, F_ICE: 0};
  // TODO when more types of units with different strength exist
  var armyStrength = {F_HELL: 0, F_HEAVEN: 0, F_FIRE: 0, F_ICE: 0};
}