import 'dart:ui';

import 'package:dino_run/game/dino_run.dart';
import 'package:dino_run/models/player_data.dart';
import 'package:dino_run/widgets/hud.dart';
import 'package:dino_run/widgets/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PauseMenu extends StatelessWidget {
  static const id = 'PauseMenu';
  final DinoRun gameRef;

  const PauseMenu(this.gameRef, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: gameRef.playerData,
      child: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.black.withAlpha(100),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Selector<PlayerData, int>(
                        selector: (_, playerData) => playerData.currentScore,
                        builder: (_, score, __) {
                          return Text(
                            'Score: $score',
                            style: TextStyle(fontSize: 40, color: Colors.white),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        gameRef.overlays.remove(PauseMenu.id);
                        gameRef.overlays.add(Hud.id);
                        gameRef.resumeEngine();
                      },
                      child: Text(
                        'Resume',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        gameRef.overlays.remove(PauseMenu.id);
                        gameRef.overlays.add(Hud.id);
                        gameRef.resumeEngine();
                        gameRef.reset();
                        gameRef.startGamePlay();
                      },
                      child: Text(
                        'Restart',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        gameRef.overlays.remove(PauseMenu.id);
                        gameRef.overlays.add(MainMenu.id);
                        gameRef.resumeEngine();
                        gameRef.reset();
                      },
                      child: Text(
                        'Exit',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
