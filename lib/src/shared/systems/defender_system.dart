part of shared;

class DefenderSystem extends EntityProcessingSystem {
  Mapper<Defender> dm;
  Mapper<Transform> tm;

  DefenderSystem() : super(Aspect.getAspectForAllOf([Transform, Defender]));

  @override
  void processEntity(Entity entity) {
    var d = dm[entity];
    var t = tm[entity];

    d.duration -= world.delta;
    if (d.duration <= 0.0) {
      entity..removeComponent(Defender)
            ..changedInWorld();
      t.displacementX = 0.0;
      t.displacementY = 0.0;
    } else {
      var displacementFactor = -sin(PI/2 * d.duration / 50.0);
      t.displacementX = TILE_SIZE / 4 * d.x * displacementFactor;
      t.displacementY = TILE_SIZE / 4 * d.y * displacementFactor;
    }
  }
}
