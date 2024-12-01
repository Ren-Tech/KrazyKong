import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/game/dino_run.dart';
import '/game/audio_manager.dart';
import '/models/player_data.dart';
import '/widgets/pause_menu.dart';

class Hud extends StatelessWidget {
  // An unique identifier for this overlay.
  static const id = 'Hud';

  // Reference to parent game.
  final DinoRun game;

  const Hud(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: game.playerData,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Stack(
          children: [
            // Original score, high score, and lives display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Selector<PlayerData, int>(
                      selector: (_, playerData) => playerData.currentScore,
                      builder: (_, score, __) {
                        return Text(
                          'Score: $score',
                          style: const TextStyle(
                              fontSize: 20, color: Colors.white),
                        );
                      },
                    ),
                    Selector<PlayerData, int>(
                      selector: (_, playerData) => playerData.highScore,
                      builder: (_, highScore, __) {
                        return Text(
                          'High: $highScore',
                          style: const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    game.overlays.remove(Hud.id);
                    game.overlays.add(PauseMenu.id);
                    game.pauseEngine();
                    AudioManager.instance.pauseBgm();
                  },
                  child: const Icon(Icons.pause, color: Colors.white),
                ),
                Selector<PlayerData, int>(
                  selector: (_, playerData) => playerData.lives,
                  builder: (_, lives, __) {
                    return Row(
                      children: List.generate(5, (index) {
                        if (index < lives) {
                          return const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          );
                        } else {
                          return const Icon(
                            Icons.favorite_border,
                            color: Colors.red,
                          );
                        }
                      }),
                    );
                  },
                )
              ],
            ),

            // Controls for forward, back, and jump actions
            Positioned(
              left: 20,
              bottom: 50,
              child: Column(
                children: [
                  // Jump button
                  RawMaterialButton(
                    onPressed: game.jump, // Call the correct method name
                    shape: CircleBorder(),
                    fillColor: Colors.blue,
                    padding: const EdgeInsets.all(20),
                    child: const Icon(Icons.arrow_upward,
                        size: 40, color: Colors.white),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              bottom: 120,
              child: Column(
                children: [
                  // Move backward button
                  RawMaterialButton(
                    onPressed:
                        game.moveBackward, // Call the correct method name
                    shape: CircleBorder(),
                    fillColor: Colors.blue,
                    padding: const EdgeInsets.all(20),
                    child: const Icon(Icons.arrow_left,
                        size: 40, color: Colors.white),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              bottom: 120,
              child: Column(
                children: [
                  // Move forward button
                  RawMaterialButton(
                    onPressed: game.moveForward, // Call the correct method name
                    shape: CircleBorder(),
                    fillColor: Colors.blue,
                    padding: const EdgeInsets.all(20),
                    child: const Icon(Icons.arrow_right,
                        size: 40, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
