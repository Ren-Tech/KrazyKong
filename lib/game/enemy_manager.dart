import 'dart:math';

import 'package:flame/components.dart';

import '/game/enemy.dart';
import '/game/dino_run.dart';
import '/models/enemy_data.dart';

/// This class is responsible for spawning random enemies at certain
/// intervals of time depending upon the player's current score.
class EnemyManager extends Component with HasGameReference<DinoRun> {
  // A list to hold data for all the enemies.
  final List<EnemyData> _data = [];

  // Random generator required for randomly selecting enemy type.
  final Random _random = Random();

  // Timer to decide when to spawn the next enemy.
  final Timer _timer = Timer(2, repeat: true);

  // Speed multiplier for enemies.
  double _speedMultiplier = 1.0;

  EnemyManager() {
    _timer.onTick = spawnRandomEnemy;
  }

  /// Sets the speed multiplier for all enemies.
  void setEnemySpeedMultiplier(double multiplier) {
    _speedMultiplier = multiplier;
    final enemies = game.world.children.whereType<Enemy>();
    for (var enemy in enemies) {
      enemy.speedX *= _speedMultiplier;
    }
  }

  /// This method is responsible for spawning a random enemy.
  void spawnRandomEnemy() {
    // Generate a random index within [_data] and get an [EnemyData].
    final randomIndex = _random.nextInt(_data.length);
    final enemyData = _data.elementAt(randomIndex);
    final enemy = Enemy(enemyData);

    // Help in setting all enemies on the ground.
    enemy.anchor = Anchor.bottomLeft;
    enemy.position = Vector2(
      game.virtualSize.x + 32,
      game.virtualSize.y - 24,
    );

    // If this enemy can fly, set its y position randomly.
    if (enemyData.canFly) {
      final newHeight = _random.nextDouble() * 2 * enemyData.textureSize.y;
      enemy.position.y -= newHeight;
    }

    // Due to the size of our viewport, we can
    // use textureSize as size for the components.
    enemy.size = enemyData.textureSize;

    // Adjust speed based on the multiplier.
    enemy.speedX = enemyData.speedX * _speedMultiplier;

    game.world.add(enemy);
  }

  @override
  void onMount() {
    // Avoid mounting if already mounted.
    if (isMounted) {
      removeFromParent();
    }

    // Don't fill the list again on every mount.
    if (_data.isEmpty) {
      // Initialize all the data on the first mount.
      _data.addAll([
        EnemyData(
          image: game.images.fromCache('AngryPig/Walk (36x30).png'),
          nFrames: 16,
          stepTime: 0.1,
          textureSize: Vector2(36, 30),
          speedX: 80,
          canFly: false,
        ),
        EnemyData(
          image: game.images.fromCache('Bat/Flying (46x30).png'),
          nFrames: 7,
          stepTime: 0.1,
          textureSize: Vector2(46, 30),
          speedX: 100,
          canFly: true,
        ),
        EnemyData(
          image: game.images.fromCache('Rino/Run (52x34).png'),
          nFrames: 6,
          stepTime: 0.09,
          textureSize: Vector2(52, 34),
          speedX: 150,
          canFly: false,
        ),
      ]);
    }
    _timer.start();
    super.onMount();
  }

  @override
  void update(double dt) {
    _timer.update(dt);
    super.update(dt);
  }

  /// Removes all enemies from the game world.
  void removeAllEnemies() {
    final enemies = game.world.children.whereType<Enemy>();
    for (var enemy in enemies) {
      enemy.removeFromParent();
    }
  }
}
