part of shared;

class GameManager extends Manager {
  final Map<String, List<TurnStatistics>> turnStatistics = new Map.fromIterable(FACTIONS_PLUS_NEUTRAL, key: (faction) => faction, value: (_) => new List<TurnStatistics>.generate(1, (_) => new TurnStatistics()));
  final Map<String, GameStatistics> gameStatistics = new Map.fromIterable(FACTIONS_PLUS_NEUTRAL, key: (faction) => faction, value: (_) => new GameStatistics());
  var gameOver = false;
  var playerWon = false;
  int turn = 0;
  double startTime;

  int sizeX;
  int sizeY;
  bool menu = true;
  int _player = FACTIONS.length - 1;
  String playerFaction = F_HELL;
  String currentFaction = FACTIONS[FACTIONS.length - 1];

  bool get gameIsRunning => !menu && !gameOver;

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
    while (freeTiles.length > 0 && castles < sizeX - 10) {
      var pos = freeTiles[random.nextInt(freeTiles.length)];
      var x = pos % sizeX;
      var y = pos ~/ sizeX;
      world.createAndAddEntity([new Transform(x, y), new Renderable('castle'), new Spawner(3), new Unit(F_NEUTRAL, 0, 0, 3), new Conquerable()]);
      addConqueredCastle(F_NEUTRAL);
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
    turnStatistics[currentFaction][turn].timeAfterTurn = world.time;
    currentFaction = FACTIONS[_player];
    if (_player == 0) {
      FACTIONS_PLUS_NEUTRAL.forEach((faction) => turnStatistics[faction].add(new TurnStatistics()));
      turn++;
    }
  }

  int get maxTiles => sizeX * sizeY;

  void addLostUnit(String faction) {
    turnStatistics[faction][turn].lostUnits += 1;
    turnStatistics[faction][turn].units -= 1;
  }

  void addSpawnedUnit(String faction) {
    turnStatistics[faction][turn].spawnedUnits += 1;
    turnStatistics[faction][turn].units += 1;
  }

  void addLostCastle(String faction) {
    turnStatistics[faction][turn].lostCastles += 1;
    turnStatistics[faction][turn].castles -= 1;
  }

  void addConqueredCastle(String faction) {
    turnStatistics[faction][turn].conqueredCastles += 1;
    turnStatistics[faction][turn].castles += 1;
  }


  addDefeatedUnit(String faction) => turnStatistics[faction][turn].defeatedUnits += 1;
  addScoutedArea(String faction) => turnStatistics[faction][turn].scoutedArea += 1;

  void initGameStatistics() {
    gameStatistics.forEach((faction, gameStatsForFaction) {
      turnStatistics[faction].forEach((turnStat) {
        gameStatsForFaction.add(turnStat);
      });
    });
  }

  void factionLost(String faction) {
    gameStatistics[faction].defeatedInTurn = turn;
    if (faction == playerFaction) {
      initGameStatistics();
      gameOver = true;
      eventBus.fire(new AnalyticsTrackEvent('player lost', faction));
      eventBus.fire(new AnalyticsTrackEvent('turns played', '$turn'));
    } else {
      var playerHasWon = FACTIONS.where((faction) => faction != playerFaction)
                                 .map((faction) => gameStatistics[faction].defeatedInTurn != null)
                                 .firstWhere((bool defeated) => !defeated, orElse: () => true);
      if (playerHasWon) {
        initGameStatistics();
        gameOver = true;
        playerWon = true;
        eventBus.fire(new AnalyticsTrackEvent('player won', playerFaction));
        eventBus.fire(new AnalyticsTrackEvent('turns played', '$turn'));
      }
    }
  }
}

class TurnStatistics {
  var units = 0;
  var castles = 0;
  var lostUnits = 0;
  var lostCastles = 0;
  var defeatedUnits = 0;
  var conqueredCastles = 0;
  var spawnedUnits = 0;
  var timeAfterTurn = 0.0;
  var scoutedArea = 0;
  // TODO once issue #26 is fixed
  var ownedArea = 0;
  // TODO when more types of units with different strength exist
  var armyStrength = 0;

  String toString() => '''lost units: $lostUnits 
lost castles: $lostCastles 
defeated units: $defeatedUnits
conqured castles: $conqueredCastles
spawned units: $spawnedUnits
time: $timeAfterTurn
scouted area: $scoutedArea
owned area: $ownedArea
army strength: $armyStrength

''';
}


class GameStatistics extends Object with TurnStatistics {
  var defeatedInTurn;
  var maxUnits = 0;
  var maxCastles = 0;

  void add(TurnStatistics turnStatistics) {
    armyStrength += turnStatistics.armyStrength;
    conqueredCastles += turnStatistics.conqueredCastles;
    defeatedUnits += turnStatistics.defeatedUnits;
    lostCastles += turnStatistics.lostCastles;
    lostUnits += turnStatistics.lostUnits;
    ownedArea += turnStatistics.ownedArea;
    scoutedArea += turnStatistics.scoutedArea;
    spawnedUnits += turnStatistics.spawnedUnits;
    timeAfterTurn += turnStatistics.timeAfterTurn;
    units += turnStatistics.units;
    castles += turnStatistics.castles;
    maxUnits = max(maxUnits, units);
    maxCastles = max(maxCastles, units);
  }
}