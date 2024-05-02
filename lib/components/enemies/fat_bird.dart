import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventures/pixel_adventure.dart';

import '../player.dart';

enum BirdState {idle, ground, fall, hit}

class FatBird extends SpriteAnimationGroupComponent with HasGameRef<PixelAdventure>{
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation groundAnimation;
  late final SpriteAnimation hitAnimation;
  late final Player player;

  final double offNeg;
  final double offPos;
  final double fallLimit;
  late final double rangeNeg;
  late final double rangePos;
  late final double rangeLimit;

  Vector2 velocity = Vector2.zero();
  int sens = -1;
  double moveSpeed = 14;

  static const double stepTime = 0.05;
  static const int tileSize = 16;

  FatBird({super.position, super.size, this.offNeg=0, this.offPos =0, this.fallLimit=0});

  @override
  FutureOr<void> onLoad() {
    player = game.player;
    _loadAllAnimations();
    _calculateActionRange();
    debugMode = true;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updateState(dt);
    super.update(dt);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 8);
    fallAnimation = _spriteAnimation('Fall',4);
    hitAnimation = _spriteAnimation('Hit',5);
    groundAnimation = _spriteAnimation('Ground',4);

    animations = {
      BirdState.idle : idleAnimation,
      BirdState.fall : fallAnimation,
      BirdState.ground : groundAnimation,
      BirdState.hit : hitAnimation
    };
    current = BirdState.idle;
  }

  SpriteAnimation _spriteAnimation(String state,int amount){
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Enemies/FatBird/$state (40x48).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime, //temps entre les animations en fps. ici on 20 fps =>1s/20 = 0.05
        textureSize: Vector2(40,48.0),
      ),
    );
  }

  void _calculateActionRange() {
    rangeNeg = position.y - offNeg * tileSize;
    rangePos = position.y +height + offNeg * tileSize;
    rangeLimit = position.y + height + fallLimit * tileSize;
  }

  void _birdIdleMovement(double dt) {
    if(position.y<rangeNeg) sens =1;
    if(position.y + height>= rangePos) sens =-1;
    velocity.y = sens * moveSpeed;
    position.y+= velocity.y*dt;
    current = BirdState.idle;
  }

  void _fallBird(double dt){
    moveSpeed = 100;
    if(position.y + height>= rangeLimit) moveSpeed=0;
    sens =1;
    velocity.y = sens * moveSpeed;
    position.y+= velocity.y*dt;
    current = BirdState.fall;

  }

  void _updateState(double dt) {
    if(_playerInRange()){
      print('Player in range: ......');
      _fallBird(dt);
    }else{
      moveSpeed = 14;
      _birdIdleMovement(dt);
    }
  }

  bool _playerInRange(){
    double playerOffset = player.scale.x> 0? 0 : -player.width;
    if(player.x+playerOffset >= position.x && (player.x + player.width + playerOffset)<=(position.x + width))
      {
        return true;
      }
    return false;
  }
}