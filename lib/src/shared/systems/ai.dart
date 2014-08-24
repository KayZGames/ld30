part of shared;

class AiSystem extends VoidEntitySystem {
  final directions = <List<int>>[[1, 0], [-1, 0], [0, 1], [0, -1]];

  UnitManager unitManager;
  TurnManager turnManager;

  ComponentMapper<Unit> um;

  @override
  void processSystem() {
    var entity = unitManager.getSelectedUnit(gameState.currentFaction);
    if (entity == null || um.get(entity).movesLeft <= 0) {
      entity = unitManager.getNextUnit(gameState.currentFaction);
    }
    if (null == entity) {
      turnManager.nextTurn();
    } else {
      var direction = directions[random.nextInt(directions.length)];
      entity..addComponent(new Move(direction[0], direction[1]))
            ..changedInWorld();
    }
  }

  @override
  bool checkProcessing() => gameState.currentFaction != gameState.playerFaction;
}