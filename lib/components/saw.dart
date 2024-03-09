import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventures/pixel_adventure.dart';

class Saw extends SpriteAnimationComponent with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final bool isVertical;
  final double offNeg;
  final double offPos;

  Saw(
      {this.isVertical = false,
      this.offNeg = 0,
      this.offPos = 0,
      position,
      size})
      : super(position: position, size: size);

  static const double sawSpeed = 0.03;
  static const double moveSpeed = 50;
  static const tileSize = 16;
  int sens = 1;
  double rangeNeg = 0;
  double rangePos = 0;


  @override
  FutureOr<void> onLoad() {
    double ref = isVertical? position.y : position.x;
    rangePos= ref + (offPos* tileSize);
    rangeNeg= ref - (offNeg* tileSize);
    priority = -1;
    add(CircleHitbox());
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/On (38x38).png'),
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: sawSpeed,
        textureSize: Vector2.all(38.0),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if(isVertical){
      position.y+= dt *moveSpeed*sens;
      if(position.y >= rangePos || position.y <= rangeNeg){
        sens = -sens;
      }
    }else{
      position.x+= dt *moveSpeed*sens;
      if(position.x >= rangePos || position.x <= rangeNeg){
        sens = -sens;
      }
    }
    super.update(dt);
  }

}
