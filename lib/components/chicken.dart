import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventures/components/player.dart';
import 'package:pixel_adventures/pixel_adventure.dart';

enum ChickenState {idle, run, hit}

class Chicken extends SpriteAnimationGroupComponent with HasGameRef<PixelAdventure>,CollisionCallbacks{
  final double offNeg;
  final double offPos;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation hitAnimation;
  Chicken({super.position,super.size, this.offNeg = 0,this.offPos = 0});
  static const double stepTime = 0.05;
  static const int tileSize = 16;
  static const double _bounceHeight = 260;
  late final double rangeNeg;
  late final double rangePos;

  final double runSpeed = 80;
  int targetDirection = -1;
  double moveDirection = 1;
  Vector2 velocity = Vector2.zero();
  late final Player player;
  bool gotStomped = false;

  @override
  FutureOr<void> onLoad() {
    player = game.player;
    add(RectangleHitbox(
      position: Vector2(4,6),
      size: Vector2(24,26),
    ));
    _loadAllAnimations();
    _calculateActionRange();
    return super.onLoad();
  }
  @override
  void update(double dt) {
    if(!gotStomped){
      _updateState();
      _movement(dt);
    }
    super.update(dt);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 13);
    runningAnimation = _spriteAnimation('Run',14);
    hitAnimation = _spriteAnimation('Hit',5)..loop = false;

    animations = {
      ChickenState.idle : idleAnimation,
      ChickenState.run : runningAnimation,
      ChickenState.hit : hitAnimation
    };

    current = ChickenState.idle;
  }

  SpriteAnimation _spriteAnimation(String state,int amount){
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Enemies/Chicken/$state (32x34).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime, //temps entre les animations en fps. ici on 20 fps =>1s/20 = 0.05
        textureSize: Vector2(32,34.0),
      ),
    );
  }

  void _calculateActionRange() {
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offNeg * tileSize;
  }

  void _movement(double dt) {
    velocity.x = 0;
    double playerOffset = player.scale.x> 0? 0 : -player.width;
    double chickenOffset = scale.x> 0? 0 : -width;
    if(playerInRange() ){
      targetDirection = (player.x+playerOffset<position.x + chickenOffset)? -1:1;
      velocity.x = targetDirection * runSpeed;
    }
    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1)??1;
    position.x += velocity.x * dt ;
  }

  bool playerInRange(){
    double playerOffset = player.scale.x> 0? 0 : -player.width;
    return player.x + playerOffset <= rangePos&& player.x + rangeNeg>=rangeNeg
    && player.y<= position.y + height && player.y + player.height>=position.y;
  }

  void _updateState() {
    current = (velocity.x!=0)? ChickenState.run: ChickenState.idle;
    if((moveDirection< 0 && scale.x<0) || (moveDirection>0 && scale.x>0)){
      flipHorizontallyAroundCenter();
    }
  }

  void collidedWithPlayer() async{
    if(player.velocity.y > 0 && player.y+player.height> position.y){
      if(game.playSounds) FlameAudio.play('bounce.wav', volume: gameRef.soundVolume);
      gotStomped = true;
      player.velocity.y = -_bounceHeight;
      current = ChickenState.hit;
      await animationTicker?.completed;
      removeFromParent();

    }
    else{
      player.collidedWithEnemy();
    }
  }
}