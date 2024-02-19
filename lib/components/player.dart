import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventures/components/util.dart';
import 'package:pixel_adventures/pixel_adventure.dart';

import 'collison_block.dart';


enum PlayerState {idle, running, jumping, falling}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  final double stepTime = 0.05;
  final String character;

  double moveSpeed = 100;
  double horizontalMovement = 0;
  Vector2 velocity = Vector2.zero();

  final double _gravity = 9.8;
  final double _jumpForce = 300;
  final double _terminalVelocity = 300;
  bool hasJumped = false;
  List<CollisionBlock> collisionBlocks = [];

  bool isOnGround = false;
  Player({position, this.character = 'Mask Dude'}) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    _loadAnimations();
    // TODO: implement onLoad
    return super.onLoad();
  }

  @override
  void update(double dt){
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _checkHorizontalCollisions();
    _applyGravity(dt); // il est prefereable de faire gerer cela apres la detection de collision horizontale
    _checkVerticalCollisions();
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

  void _loadAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run',12);
    jumpingAnimation = _spriteAnimation('Jump',1);
    fallingAnimation = _spriteAnimation('Fall',1);

    //Liste toutes les animations
    animations = {
      PlayerState.idle : idleAnimation,
      PlayerState.running : runningAnimation,
      PlayerState.jumping : jumpingAnimation,
      PlayerState.falling : fallingAnimation,
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

  void _updatePlayerMovement(double dt) {
    //Direction dans le sens des abscisses
    if (hasJumped && isOnGround) _playerJump(dt);
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }
  void _playerJump(double dt) {
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
            position.x = block.position.x - width;
            break;
          }
          if(velocity.x<0){
            velocity.x = 0;
            position.x = block.x + block.width +width;
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
            position.y = block.y - height;
            isOnGround = true;
            break;
          }

        }
      }
      else{
        if(checkCollision(this, block)){
          if(velocity.y > 0){
            velocity.y = 0;
            position.y = block.y - height;
            isOnGround = true;
            break;
          }
          if(velocity.y < 0){
            velocity.y = 0;
            position.y = block.y +block.height;
            break;
          }
        }
      }
    }
  }


}
