import 'dart:math';

import 'package:dino_run/obstcales.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:hive/hive.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

import '/game/dino.dart';
import '/widgets/hud.dart';
import '/models/settings.dart';
import '/game/audio_manager.dart';
import '/game/enemy_manager.dart';
import '/models/player_data.dart';
import '/widgets/pause_menu.dart';
import '/widgets/game_over_menu.dart';

class DinoRun extends FlameGame
    with TapDetector, HasCollisionDetection, PanDetector {
  DinoRun({super.camera});

  static const _imageAssets = [
    'DinoSprites - tard.png',
    'AngryPig/Walk (36x30).png',
    'Bat/Flying (46x30).png',
    'Rino/Run (52x34).png',
    'parallax/plx-1.png',
    'parallax/plx-2.png',
    'parallax/plx-3.png',
    'parallax/plx-4.png',
    'parallax/plx-5.png',
    'parallax/plx-6.png',
    'obstacles/rocks/rock.png',
    'obstacles/stump/stump.png'
  ];

  static const _audioAssets = [
    '8BitPlatformerLoop.wav',
    'hurt7.wav',
    'jump14.wav',
  ];

  late Dino _dino;
  late Settings settings;
  late PlayerData playerData;
  late EnemyManager _enemyManager;
  final List<Obstacle> _obstacles = [];

  final Random random = Random();

  // New variables for horizontal movement
  static const double _horizontalMoveSpeed = 200; // Adjust speed as needed
  Vector2 _dinoMovement = Vector2.zero();

  Vector2 get virtualSize => camera.viewport.virtualSize;
  void moveForward() {
    _dinoMovement.x = _horizontalMoveSpeed; // Move forward
  }

  void moveBackward() {
    _dinoMovement.x = -_horizontalMoveSpeed; // Move backward
  }

  void jump() {
    _dino.jump(); // Trigger jump
  }

  void _spawnObstacle() {
    // Randomly decide between rock or stump
    final isRock = random.nextBool();

    final spriteName = isRock ? 'rock.png' : 'stump.png';
    final sprite = images.fromCache(spriteName); // Use the image from cache

    final obstacle = Obstacle(
      Sprite(sprite),
      Vector2(virtualSize.x,
          virtualSize.y - 50), // Adjust position to match ground level
      Vector2(48, 48), // Adjust size based on your asset dimensions
    );

    _obstacles.add(obstacle);
    add(obstacle);
  }

  @override
  Future<void> onLoad() async {
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();

    playerData = await _readPlayerData();
    settings = await _readSettings();

    await AudioManager.instance.init(_audioAssets, settings);
    AudioManager.instance.startBgm('8BitPlatformerLoop.wav');

    await images.loadAll(_imageAssets);

    camera.viewfinder.position = camera.viewport.virtualSize * 0.5;

    final parallaxBackground = await loadParallaxComponent(
      [
        ParallaxImageData('parallax/plx-1.png'),
        ParallaxImageData('parallax/plx-2.png'),
        ParallaxImageData('parallax/plx-3.png'),
        ParallaxImageData('parallax/plx-4.png'),
        ParallaxImageData('parallax/plx-5.png'),
        ParallaxImageData('parallax/plx-6.png'),
      ],
      baseVelocity: Vector2(10, 0),
      velocityMultiplierDelta: Vector2(1.4, 0),
    );

    camera.backdrop.add(parallaxBackground);
  }

  void startGamePlay() {
    _dino = Dino(images.fromCache('DinoSprites - tard.png'), playerData);
    _enemyManager = EnemyManager();

    world.add(_dino);
    world.add(_enemyManager);
  }

  void _disconnectActors() {
    _dino.removeFromParent();
    _enemyManager.removeAllEnemies();
    _enemyManager.removeFromParent();
  }

  void reset() {
    _disconnectActors();
    playerData.currentScore = 0;
    playerData.lives = 5;
    _dinoMovement = Vector2.zero();
  }

  @override
  void update(double dt) {
    if (overlays.isActive(Hud.id)) {
      _dino.position += _dinoMovement * dt;
      _dino.position.x = _dino.position.x.clamp(0, virtualSize.x - _dino.width);
    }
    // Check if the game is over
    if (playerData.lives <= 0) {
      overlays.add(GameOverMenu.id);
      overlays.remove(Hud.id);
      pauseEngine();
      AudioManager.instance.pauseBgm();
    }

    // Check if the dino reached a total score of 10
    if (playerData.currentScore >= 10) {
      overlays.add('LevelCompleted');
      overlays.remove(Hud.id);
      pauseEngine();
      AudioManager.instance.pauseBgm();
      print('Congratulations! You reached a score of 10!');
    }

    // Move the dino based on input
    if (overlays.isActive(Hud.id)) {
      _dino.position += _dinoMovement * _horizontalMoveSpeed * dt;

      // Constrain dino's horizontal movement to screen bounds
      _dino.position.x = _dino.position.x.clamp(0, virtualSize.x - _dino.width);
    }

    super.update(dt);
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (overlays.isActive(Hud.id)) {
      _dino.jump();
    }
    super.onTapDown(info);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (overlays.isActive(Hud.id)) {
      _dinoMovement.x = info.delta.global.x;
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    _dinoMovement = Vector2.zero(); // Stop movement when drag ends
  }

  Future<PlayerData> _readPlayerData() async {
    final playerDataBox =
        await Hive.openBox<PlayerData>('DinoRun.PlayerDataBox');
    final playerData = playerDataBox.get('DinoRun.PlayerData');

    if (playerData == null) {
      await playerDataBox.put('DinoRun.PlayerData', PlayerData());
    }

    return playerDataBox.get('DinoRun.PlayerData')!;
  }

  Future<Settings> _readSettings() async {
    final settingsBox = await Hive.openBox<Settings>('DinoRun.SettingsBox');
    final settings = settingsBox.get('DinoRun.Settings');

    if (settings == null) {
      await settingsBox.put(
        'DinoRun.Settings',
        Settings(bgm: true, sfx: true),
      );
    }

    return settingsBox.get('DinoRun.Settings')!;
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!(overlays.isActive(PauseMenu.id)) &&
            !(overlays.isActive(GameOverMenu.id))) {
          resumeEngine();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        if (overlays.isActive(Hud.id)) {
          overlays.remove(Hud.id);
          overlays.add(PauseMenu.id);
        }
        pauseEngine();
        break;
    }
    super.lifecycleStateChange(state);
  }
}
