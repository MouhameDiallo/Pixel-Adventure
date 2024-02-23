import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventures/components/jump_button.dart';
import 'package:pixel_adventures/components/player.dart';
import 'package:pixel_adventures/components/level.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection, TapCallbacks {
  late CameraComponent cam;
  final player = Player(character: 'Mask Dude');
  late final JoystickComponent joystick;
  bool showControls = true;
  List<String> levelNames = ['Level-02', 'Level-02'];
  int currentLevel = 0;

  @override
  Color backgroundColor() => const Color(0xFF211F30);
  @override
  FutureOr<void> onLoad() async {
    //Load all images into cache memory
    await images.loadAllImages();
    _loadLevel();
    if (showControls) {
      addJoystick();
      add(JumpButton());
    }
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (showControls) updateJoystick();
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 10,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 32.0, bottom: 32.0),
    );
    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }

  void loadNextLevel() {
    if (currentLevel < levelNames.length - 1) {
      currentLevel++;
      _loadLevel();
    } else {
      //no more levels
    }
  }

  void _loadLevel() {
    removeWhere((component) => component is Level);
    Future.delayed(const Duration(seconds: 1), () {
      Level world = Level(
        player: player,
        levelName: levelNames[currentLevel],
      );

      cam = CameraComponent.withFixedResolution(
        width: 640,
        height: 360,
        world: world,
      );
      cam.viewfinder.anchor = Anchor.topLeft;
      addAll([cam, world]);
    });
  }
}
