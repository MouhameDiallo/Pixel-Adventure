import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventures/components/player.dart';
import 'package:pixel_adventures/pixel_adventure.dart';

class Checkpoint extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  Checkpoint({position, size}) : super(position: position, size: size);
  bool hasReachedCheckpoint = false;

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
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if(other is Player) _reachedCheckpoint();
  }

  void _reachedCheckpoint() {
    if(!hasReachedCheckpoint){
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
      hasReachedCheckpoint = true;

      const flagOutDuration = Duration(milliseconds: 26 * 50);
      Future.delayed(flagOutDuration,(){
        animation = SpriteAnimation.fromFrameData(
          gameRef.images.fromCache(
              'Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png'),
          SpriteAnimationData.sequenced(
            amount: 10,
            stepTime: 0.05,
            textureSize: Vector2.all(64.0),
          ),
        );
      });
    }
  }
}
