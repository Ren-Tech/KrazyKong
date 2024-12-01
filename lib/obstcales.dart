import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

class Obstacle extends SpriteComponent with HasGameRef, CollisionCallbacks {
  Obstacle(Sprite sprite, Vector2 position, Vector2 size)
      : super(sprite: sprite, position: position, size: size);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()); // Add collision detection
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= 100 * dt; // Move left at a constant speed

    // Remove the obstacle if it moves off-screen
    if (position.x + size.x < 0) {
      removeFromParent();
    }
  }
}
