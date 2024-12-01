import 'package:dino_run/game/dino_run.dart';
import 'package:flutter/material.dart';

class LevelCompletedMenu extends StatelessWidget {
  static const id = 'LevelCompleted';
  final DinoRun game;

  const LevelCompletedMenu(this.game, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Level Completed!',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () {
              // Logic for restarting or advancing to the next level
              game.reset(); // Call reset on the game instance
              game.overlays.remove(LevelCompletedMenu.id); // Remove the overlay
            },
            child: Text('Play Again'),
          ),
        ],
      ),
    );
  }
}
