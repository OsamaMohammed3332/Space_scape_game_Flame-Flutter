
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:space_scape/game/game.dart';
import 'package:space_scape/widgets/pause_menu.dart';

class PauseButton extends StatelessWidget {
  static const String ID = 'PauseButton';
  final MyGame gameRef;
  const PauseButton({Key? kay, required this.gameRef}) : super(key: kay);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topCenter,
        child: TextButton(
            onPressed: () => {
              gameRef.pauseEngine(),
              gameRef.overlays.add(PauseMenu.id),
              gameRef.overlays.remove(PauseButton.ID)
            },
            child: const Icon(
              Icons.pause_rounded,
              color: Colors.white,
            )));
  }
}
