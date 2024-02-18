import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventures/pixel_adventure.dart';

import 'collison_block.dart';


enum PlayerState {idle, running}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  final double stepTime = 0.05;
  final String character;

  double moveSpeed = 100;
  double horizontalMovement = 0;
  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
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
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed= keysPressed.contains(LogicalKeyboardKey.keyA)||keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed= keysPressed.contains(LogicalKeyboardKey.keyD)||keysPressed.contains(LogicalKeyboardKey.arrowRight);
    horizontalMovement += isLeftKeyPressed? -1:0;
    horizontalMovement += isRightKeyPressed? 1:0;
    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);

    runningAnimation = _spriteAnimation('Run',12);

    //Liste toutes les animations
    animations = {
      PlayerState.idle : idleAnimation,
      PlayerState.running : runningAnimation,
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
    //Driection dans le sens des abscisses

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
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
    current = playerState;
  }

  void _checkHorizontalCollisions() {}
}