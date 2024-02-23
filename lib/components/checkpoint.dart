import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventures/components/player.dart';
import 'package:pixel_adventures/pixel_adventure.dart';

class Checkpoint extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  Checkpoint({position, size}) : super(position: position, size: size);

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    add(RectangleHitbox(
      position: Vector2(18,56),
      size: Vector2(12,8),
      collisionType: CollisionType.passive,
    ),);
    animation = SpriteAnimation.fromFrameData(
      gameRef.images.fromCache(
          'Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2.all(64.0),
      ),
    );
    return super.onLoad();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if(other is Player) _reachedCheckpoint();
  }

  void _reachedCheckpoint() async{

      animation = SpriteAnimation.fromFrameData(
        gameRef.images.fromCache(
            'Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png'),
        SpriteAnimationData.sequenced(
          amount: 26,
          stepTime: 0.05,
          loop: false,
          textureSize: Vector2.all(64.0),
        ),
      );

      await animationTicker?.completed;
      animation = SpriteAnimation.fromFrameData(
        gameRef.images.fromCache(
            'Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png'),
        SpriteAnimationData.sequenced(
          amount: 10,
          stepTime: 0.05,
          textureSize: Vector2.all(64.0),
        ),
      );
    }

}
