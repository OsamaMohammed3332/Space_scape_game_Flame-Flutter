import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'enemy.dart';

class Bullets extends SpriteComponent with CollisionCallbacks {
  double _speed = 450;

  Bullets({
    Sprite? sprite,
    Vector2? size,
    Vector2? position,
    Anchor? anchor,
  }) : super(
          anchor: anchor,
          sprite: sprite,
          position: position,
          size: size,
        );

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Enemy) {
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += Vector2(0, -1) * _speed * dt;

    if (position.y < 0) {
      removeFromParent();
    }
  }

  @override
  void onMount() {
    super.onMount();
    final shape = CircleHitbox(
        radius: 8, position: Vector2(size.x / 2 - 7, size.y / 2 - 8));
    add(shape);
  }
}
