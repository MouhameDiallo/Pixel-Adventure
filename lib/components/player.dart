import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventures/components/checkpoint.dart';
import 'package:pixel_adventures/components/saw.dart';
import 'package:pixel_adventures/components/util.dart';
import 'package:pixel_adventures/pixel_adventure.dart';

import 'collision_block.dart';
import 'custom_hitbox.dart';
import 'fruit.dart';


enum PlayerState {idle, running, jumping, falling, hit, appearing,disappearing}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;
  final double stepTime = 0.05;
  final String character;
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool hasReachedCheckpoint = false;

  double moveSpeed = 100;
  double horizontalMovement = 0;
  Vector2 velocity = Vector2.zero();
  CustomHitBox hitBox = CustomHitBox(offsetX: 10, offsetY: 4, width: 14, height: 28);

  final double _gravity = 9.8;
  final double _jumpForce = 250;
  final double _terminalVelocity = 300;
  
  List<CollisionBlock> collisionBlocks = [];
  late Vector2 respawnPoint;
  final double fixedDeltaTime = 1/60;
  double accumulatedTime = 0;

  
  Player({position, this.character = 'Mask Dude'}) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    respawnPoint = Vector2(position.x, position.y);
    _loadAnimations();
    add(RectangleHitbox(position: Vector2(hitBox.offsetX,hitBox.offsetY), size: Vector2(hitBox.width,hitBox.height)));
    return super.onLoad();
  }

  @override
  void update(double dt){
    accumulatedTime+=dt;
    while (accumulatedTime >= fixedDeltaTime){
      if(!gotHit && !hasReachedCheckpoint) {
        _updatePlayerState();
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime); // il est preferable de faire gerer cela apres la detection de collision horizontale
        _checkVerticalCollisions();
      }
      accumulatedTime-= fixedDeltaTime;
    }


    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed= keysPressed.contains(LogicalKeyboardKey.keyA)||keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed= keysPressed.contains(LogicalKeyboardKey.keyD)||keysPressed.contains(LogicalKeyboardKey.arrowRight);
    horizontalMovement += isLeftKeyPressed? -1:0;
    horizontalMovement += isRightKeyPressed? 1:0;
    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);
    return super.onKeyEvent(event, keysPressed);
  }


  // meme chose que onCollision a la difference que onCollisionStart
  // ne se declenche qu'a la premiere collision, donc meilleure performance
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if(!hasReachedCheckpoint){
      if(other is Fruit) {
        other.collidedWithPlayer();
      } else if(other is Saw) {
        _reSpawn();
      }
      else if(other is Checkpoint){
        _reachedCheckpoint();
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run',12);
    jumpingAnimation = _spriteAnimation('Jump',1);
    fallingAnimation = _spriteAnimation('Fall',1);
    hitAnimation = _spriteAnimation('Hit',7)..loop=false;
    appearingAnimation = _specialSpriteAnimation('Appearing',7);
    disappearingAnimation = _specialSpriteAnimation('Desappearing',7);

    //Liste toutes les animations
    animations = {
      PlayerState.idle : idleAnimation,
      PlayerState.running : runningAnimation,
      PlayerState.jumping : jumpingAnimation,
      PlayerState.falling : fallingAnimation,
      PlayerState.hit : hitAnimation,
      PlayerState.appearing : appearingAnimation,
      PlayerState.disappearing : disappearingAnimation,
    };

    //Indique l'animation actuelle
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state,int amount){
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Main Characters/$character/$state (32x32).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime, //temps entre les animations en fps. ici on 20 fps =>1s/20 = 0.05
        textureSize: Vector2.all(32),
      ),
    );
  }

  SpriteAnimation _specialSpriteAnimation(String state,int amount){
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Main Characters/$state (96x96).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime, //temps entre les animations en fps. ici on 20 fps =>1s/20 = 0.05
        textureSize: Vector2.all(96),
        loop: false,
      ),
    );
  }

  void _updatePlayerMovement(double dt) {
    //Direction dans le sens des abscisses
    if (hasJumped && isOnGround) _playerJump(dt);
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    if(game.playSounds) FlameAudio.play('jump.wav',volume: game.soundVolume);
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    hasJumped = false;
    isOnGround = false;
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    if(velocity.x<0 && scale.x>0){
      flipHorizontallyAroundCenter();
    }
    else if(velocity.x>0 && scale.x<0){
      flipHorizontallyAroundCenter();
    }

    if(velocity.x>0 || velocity.x<0) playerState = PlayerState.running;
    if(velocity.y<0) playerState = PlayerState.jumping;
    if(velocity.y>0) playerState = PlayerState.falling;
    current = playerState;
  }

  void _checkHorizontalCollisions() {
    for(var block in collisionBlocks){
      if(!block.isPlatform){
        if(checkCollision(this, block)){
          if(velocity.x>0){
            velocity.x = 0;
            position.x = block.position.x - hitBox.width - hitBox.offsetX;
            break;
          }
          if(velocity.x<0){
            velocity.x = 0;
            position.x = block.x + block.width +hitBox.width + hitBox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for(var block in collisionBlocks){
      if(block.isPlatform){
        if(checkCollision(this, block)){
          if(velocity.y > 0){
            velocity.y = 0;
            position.y = block.y - hitBox.height - hitBox.offsetY;
            isOnGround = true;
            break;
          }
        }
      }
      else{
        if(checkCollision(this, block)){
          if(velocity.y > 0){
            velocity.y = 0;
            position.y = block.y - hitBox.height - hitBox.offsetY;
            isOnGround = true;
            break;
          }
          if(velocity.y < 0){
            velocity.y = 0;
            position.y = block.y +block.height - hitBox.offsetY;
            break;
          }
        }
      }
    }
  }

  void _reSpawn() async{
    if(game.playSounds) FlameAudio.play('hit.wav',volume: game.soundVolume);
    gotHit = true;
    current  = PlayerState.hit;
    Duration canMoveDuration = const Duration(milliseconds: 350);

    await animationTicker?.completed;// attention aux animations qui font un loop
    animationTicker?.reset();
    scale.x = 1;
    position = respawnPoint - Vector2.all(32); // a cause de la taille de l'animation 96x96
    current  = PlayerState.appearing;

    await animationTicker?.completed;//on peut tjr faire un Future.delayed
    animationTicker?.reset();
    _updatePlayerState();
    position = respawnPoint;
    velocity = Vector2.zero();
    Future.delayed(canMoveDuration,()=> gotHit = false);
    // Future.delayed(hitDuration, (){
    //   scale.x = 1;
    //   position = respawnPoint - Vector2.all(32); // a cause de la taille de l'animation 96x96
    //   current  = PlayerState.appearing;
    //   Future.delayed(appearingDuration,(){
    //     _updatePlayerState();
    //     position = respawnPoint;
    //     velocity = Vector2.zero();
    //     Future.delayed(canMoveDuration,()=> gotHit = false);
    //   });
    // });
  }

  void _reachedCheckpoint() async {
    if(game.playSounds) FlameAudio.play('disappear.wav',volume: game.soundVolume);
    hasReachedCheckpoint = true;
    if(scale.x>0){
      position -= Vector2(32, 32);
    }
    else if(scale.x<0){
      position += Vector2(32, -32);
    }
    current = PlayerState.disappearing;
    await animationTicker?.completed;
    animationTicker?.reset();

    hasReachedCheckpoint = false;
    position = Vector2.all(-1000);//move it out screen bounds

    const waitToSwitchLevel = Duration(seconds: 3);
    Future.delayed(waitToSwitchLevel,(){
      game.loadNextLevel();
    });
  }


}
