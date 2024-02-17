import 'dart:async';
import 'package:flame/components.dart';
import 'package:pixel_adventures/pixel_adventure.dart';


enum PlayerState {idle, running}
enum PlayerDirection {left, right, none}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure> {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  final double stepTime = 0.05;
  final String character;

  PlayerDirection playerDirection = PlayerDirection.none;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isFacingRight = true;

  Player({position, required this.character}) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    _loadAnimations();
    // TODO: implement onLoad
    return super.onLoad();
  }

  @override
  void update(double dt){
    _updatePlayerMovement(dt);
    super.update(dt);
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
    double dirX= 0.0;
    switch(playerDirection){
      case PlayerDirection.left:
        if(isFacingRight){
          flipHorizontallyAroundCenter();
          isFacingRight = false;
        }
        current = PlayerState.running;
        dirX -= moveSpeed;
        break;
      case PlayerDirection.right:
        if(!isFacingRight){
          flipHorizontallyAroundCenter();
          isFacingRight = true;
        }
        current = PlayerState.running;
        dirX += moveSpeed;
        break;
      case PlayerDirection.none:
        current = PlayerState.idle;
        break;
      default:
    }
    velocity = Vector2(dirX, 0.0);
    position += velocity * dt;
  }
}
