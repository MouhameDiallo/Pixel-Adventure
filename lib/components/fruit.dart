import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventures/components/custom_hitbox.dart';
import 'package:pixel_adventures/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final String name;
  Fruit({this.name = 'Apple', position, size})
      : super(position: position, size: size);

  double stepTime = 0.05;
  bool isCollected = false;
  final hitBox = CustomHitBox(offsetX: 10, offsetY: 10, width: 12, height: 12);

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    add(
      RectangleHitbox(
        position: Vector2(hitBox.offsetX, hitBox.offsetY),
        size: Vector2(hitBox.width, hitBox.height),
        collisionType: CollisionType.passive,
      ),
    );
    animation = _spriteAnimation(name, 17);
    return super.onLoad();
  }

  SpriteAnimation _spriteAnimation(String name, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Items/Fruits/$name.png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime:
            stepTime, //temps entre les animations en fps. ici on 20 fps =>1s/20 = 0.05
        textureSize: Vector2.all(32),
      ),
    );
  }

  void collidedWithPlayer() {
    if (!isCollected) {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache("Items/Fruits/Collected.png"),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
          loop: false,
        ),
      );
      isCollected = true;
      Future.delayed(
        const Duration(milliseconds: 400),
        () => removeFromParent(),
      );
    }
    //removeFromParent();
  }
}
