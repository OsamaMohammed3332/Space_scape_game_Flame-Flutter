import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:space_scape/game/bullets.dart';
import 'package:space_scape/game/enemy.dart';
import 'package:space_scape/game/player.dart';
import 'package:space_scape/widgets/game_over_menu.dart';
import 'package:space_scape/widgets/pause_buatton.dart';

import '../widgets/pause_menu.dart';
import 'audio_component.dart';
import 'command.dart';
import 'enemy_manager.dart';

class MyGame extends FlameGame
    with PanDetector, HasTappables, HasDraggables, HasCollisionDetection {
  Offset? _pointerStartPos;
  late Player _player;
  late SpriteSheet _spriteSheet;
  late EnemyManager _enemyManager;
  late final JoystickComponent joystick;
  Button button = Button();
  final Vector2 buttonSize = Vector2(60.0, 60.0);
  late TextComponent _playerScore;
  late TextComponent _playerHealth;
  final _commandList = List<Command>.empty(growable: true);
  final _addLaterCommandList = List<Command>.empty(growable: true);
  bool _isAlreadyLoaded = false;
  late AudioPlayerComponent _audioPlayerComponent;

  @override
  Future<void>? onLoad() async {
    if (!_isAlreadyLoaded) {
      await images.load('simpleSpace_tilesheet@2.png');
      _spriteSheet = SpriteSheet.fromColumnsAndRows(
          image: images.fromCache('simpleSpace_tilesheet@2.png'),
          columns: 8,
          rows: 6);
      _audioPlayerComponent = AudioPlayerComponent();
      add(_audioPlayerComponent);
      final stars = await ParallaxComponent.load(
        [ParallaxImageData('stars1.png'), ParallaxImageData('stars2.png')],
        repeat: ImageRepeat.repeat,
        baseVelocity: Vector2(0, -50),
        velocityMultiplierDelta: Vector2(0, 1.5),
      );
      add(stars);

      button
        ..sprite = await loadSprite('icon.png')
        ..size = buttonSize
        ..position =
            Vector2(size[0] - buttonSize[0] - 20, size[1] - buttonSize[1] - 75);
      add(button);

      final knobPaint = BasicPalette.gray.withAlpha(200).paint();
      final backgroundPaint = BasicPalette.gray.withAlpha(100).paint();
      joystick = JoystickComponent(
        knob: CircleComponent(radius: 20, paint: knobPaint),
        background: CircleComponent(radius: 50, paint: backgroundPaint),
        margin: const EdgeInsets.only(left: 20, bottom: 75),
      );

      add(joystick);
      _player = Player(
          sprite: _spriteSheet.getSpriteById(7),
          position: size / 2,
          size: Vector2(64, 64),
          anchor: Anchor.center,
          joystick);
      add(_player);
      _playerScore = TextComponent(
        text: 'Score: ${_player.score}',
        textRenderer: TextPaint(
            style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        )),
        position: Vector2(10, 10),
      );
      _playerScore.positionType = PositionType.viewport;
      add(_playerScore);
      _playerHealth = TextComponent(
        text: 'Health: ${_player.health}%',
        textRenderer: TextPaint(
            style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        )),
        position: Vector2(size.x - 10, 10),
      );
      _playerHealth.anchor = Anchor.topRight;
      _playerHealth.positionType = PositionType.viewport;
      add(_playerHealth);
      camera.defaultShakeIntensity = 20;
      _isAlreadyLoaded = true;

      _enemyManager = EnemyManager(spriteSheet: _spriteSheet);
      add(_enemyManager);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (var command in _commandList) {
      for (var component in children) {
        command.run(component);
      }
    }
    _commandList.clear();
    _commandList.addAll(_addLaterCommandList);
    _addLaterCommandList.clear();
    _player.position.add(joystick.relativeDelta * 300 * dt);
    _playerScore.text = 'Score: ${_player.score}';
    _playerHealth.text = 'Health: ${_player.health}%';
    if (_player.health <= 0 && (!camera.shaking)) {
      pauseEngine();
      overlays.remove(PauseButton.ID);
      overlays.add(GameOverMenu.id);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(size.x - 107, 10, _player.health.toDouble(), 20),
      Paint()..color = Colors.blue,
    );
    super.render(canvas);
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (_player.health > 0) {
          pauseEngine();
          overlays.remove(PauseButton.ID);
          overlays.add(PauseMenu.id);
        }
        break;
    }

    super.lifecycleStateChange(state);
  }

  @override
  void onAttach() {
    _audioPlayerComponent.playBgm("SpaceInvaders.wav");
    super.onAttach();
  }

  @override
  void onDetach() {
    _audioPlayerComponent.stopBgm();
    super.onDetach();
  }

  void addCommand(Command command) {
    _addLaterCommandList.add(command);
  }

  void reset() {
    _player.reset();
    _enemyManager.reset();

    children.whereType<Enemy>().forEach((enemy) {
      enemy.removeFromParent();
    });

    children.whereType<Bullets>().forEach((bullet) {
      bullet.removeFromParent();
    });
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    super.onTapDown(pointerId, info);
    if (Button.pressed == true) {
      Bullets bullets = Bullets(
        sprite: _spriteSheet.getSpriteById(28),
        position: _player.position.clone(),
        size: Vector2(64, 64),
        anchor: Anchor.center,
      );
      add(bullets);
      _audioPlayerComponent.playSfx("laserSmall.ogg");
      // _player.add(Bullet(
      //     position: _player.position.clone(), angle: _player.angle - pi / 2));
    } else if (Button.pressedCancel) {
      return;
    }
  }
}

class Button extends SpriteComponent with Tappable {
  static bool pressed = false;
  static bool pressedCancel = false;
  @override
  bool onTapDown(TapDownInfo info) {
    try {
      return pressed = true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  @override
  bool onTapCancel() {
    pressed = false;
    return pressedCancel = true;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    pressed = false;
    return pressedCancel = true;
  }
}

// class Bullet extends PositionComponent with HasGameRef {
//   late Vector2 velocity;
//   late double spawnTime;

//   Bullet({
//     required Vector2 position,
//     required double angle,
//   })  : velocity = Vector2(cos(angle), sin(angle)).scaled(500),
//         super(
//           position: position,
//           size: Vector2.all(10),
//           anchor: Anchor.center,
//         );

//   @override
//   Future<void> onLoad() async {
//     final defaultPaint = Paint()
//       ..color = Colors.red
//       ..style = PaintingStyle.fill;
//     final hitbox = CircleHitbox()
//       ..paint = defaultPaint
//       ..renderShape = true;
//     add(hitbox);
//     spawnTime = gameRef.currentTime();
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);
//     if (gameRef.currentTime() > spawnTime + 1) {
//       removeFromParent();
//     }
//     position.add(velocity * dt);
//     ensureVisible(position, gameRef.size);
//   }
// }
