import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:space_scape/game/command.dart';
import 'package:space_scape/game/game.dart';
import 'audio_component.dart';
import 'bullets.dart';
import 'player.dart';

class Enemy extends SpriteComponent
    with HasGameRef<MyGame>, CollisionCallbacks {
  double _speed = 150;
  Random _random = Random();
  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2.random(_random)) * 500;
  }

  Enemy({
    Sprite? sprite,
    Vector2? size,
    Vector2? position,
  }) : super(
          sprite: sprite,
          position: position,
          size: size,
        ) {
    angle = pi;
  }
  @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);
    position += Vector2(0, 1) * _speed * dt;
    if (position.y > gameRef.size.y) {
      removeFromParent();
    }
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
    if (other is Bullets || other is Player) {
      removeFromParent();
      gameRef.addCommand(Command<AudioPlayerComponent>(action: (audioPlayer) {
        audioPlayer.playSfx("laser.ogg");
      }));
      final command = Command<Player>(action: (player) {
        player.addToScore(1);
      });
      gameRef.addCommand(command);
      final particleComponent = ParticleSystemComponent(
        particle: Particle.generate(
          count: 10,
          lifespan: 0.1,
          generator: (i) => AcceleratedParticle(
            acceleration: getRandomVector(),
            speed: getRandomVector(),
            position: position.clone(),
            child: CircleParticle(
              radius: 2,
              paint: Paint()..color = Colors.white,
            ),
          ),
        ),
      );
      gameRef.add(particleComponent);
    }
  }
}
