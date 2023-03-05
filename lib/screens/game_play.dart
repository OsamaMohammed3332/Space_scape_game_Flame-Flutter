import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:space_scape/game/game.dart';
import 'package:space_scape/widgets/game_over_menu.dart';
import 'package:space_scape/widgets/pause_buatton.dart';
import 'package:space_scape/widgets/pause_menu.dart';

MyGame _spacescapeGame = MyGame();

class GamePlay extends StatelessWidget {
  const GamePlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        child: GameWidget(
          game: _spacescapeGame,
          initialActiveOverlays: const [PauseButton.ID],
          overlayBuilderMap: {
            PauseButton.ID: (BuildContext context, MyGame gameRef) =>
                PauseButton(
                  gameRef: gameRef,
                ),
            PauseMenu.id: (BuildContext context, MyGame gameRef) =>
                PauseMenu(
                  gameRef: gameRef,
                ),
            GameOverMenu.id: (BuildContext context, MyGame gameRef) =>
                GameOverMenu(
                  gameRef: gameRef,
                ),
          },
        ),
        onWillPop: () async => false,
      ),
    );
  }
}
