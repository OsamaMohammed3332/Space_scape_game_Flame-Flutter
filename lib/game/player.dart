import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'enemy.dart';

class Player extends SpriteComponent with HasGameRef, CollisionCallbacks {
  Vector2 _moveDirection = Vector2.zero();
  final JoystickComponent joystick;
  double _speed = 300;
  int _score = 0;
  int get score => _score;
  int _health = 100;
  int get health => _health;

  Random _random = Random();
  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2(0.5, -1)) * 200;
  }

  Player(this.joystick,{
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
  void update(double dt) {
    super.update(dt);
    // if (!joystick.delta.isZero()) {
    //   position.add(joystick.relativeDelta * _speed * dt);
    //   angle = joystick.delta.screenAngle();
    // }
    // ensureVisible(position, gameRef.size);

    position += _moveDirection.normalized() * _speed * dt;
    position.clamp(Vector2.zero() + size / 2, gameRef.size - size / 2);

    final particleComponent = ParticleSystemComponent(
      particle: Particle.generate(
        count: 5,
        lifespan: 0.1,
        generator: (i) => AcceleratedParticle(
          acceleration: getRandomVector(),
          speed: getRandomVector(),
          position: position.clone() + Vector2(0, size.y / 3),
          child: CircleParticle(
            radius: 2,
            paint: Paint()..color = Colors.white,
          ),
        ),
      ),
    );
    gameRef.add(particleComponent);
  }

  @override
  void onMount() {
    super.onMount();
    final shape = CircleHitbox(
        radius: 26, position: Vector2(size.x / 2 - 25, size.y / 2 - 23));
    add(shape);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Enemy) {
      gameRef.camera.shake();
      _health -= 10;
      if (health <= 0) {
        _health = 0;
      }
    }
  }

  void setMoveDirection(Vector2 newMoveDirection) {
    _moveDirection = newMoveDirection;
  }

  void addToScore(int points) {
    _score += points;
  }

  void reset() {
    _score = 0;
    _health = 100;
    position = gameRef.canvasSize / 2;
  }
}

// void ensureVisible(Vector2 position, Vector2 size) {
//   if (position.x > size.x) {
//     position.x = 0;
//   }
//   if (position.x < 0) {
//     position.x = size.x;
//   }
//   if (position.y > size.y) {
//     position.y = 0;
//   }
//   if (position.y < 0) {
//     position.y = size.y;
//   }
// }
