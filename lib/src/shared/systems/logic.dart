part of shared;


class SpawningSystem extends EntityProcessingSystem {
  ComponentMapper<Transform> tm;
  ComponentMapper<Spawner> sm;
  UnitManager um;
  SpawningSystem() : super(Aspect.getAspectForAllOf([Transform, Spawner]));

  @override
  void processEntity(Entity entity) {
    var s = sm.get(entity);
    s.spawnTime -= world.delta;
    if (s.spawnTime <= 0.0) {
      var t = tm.get(entity);
      if (um.isTileEmpty(t.x, t.y)) {
        world.createAndAddEntity([new Transform(t.x, t.y), new Unit(s.type, 10), new Renderable('peasant_${s.type}')]);
        s.spawnTime = 10000.0;
      }
    }
  }
}