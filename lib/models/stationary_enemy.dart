import 'package:flame/components.dart';

class StationaryEnemy extends SpriteComponent {
  StationaryEnemy(Sprite sprite) : super(sprite: sprite);

  @override
  void update(double dt) {
    // No movement, so leave this empty to keep the enemy stationary.
  }
}
