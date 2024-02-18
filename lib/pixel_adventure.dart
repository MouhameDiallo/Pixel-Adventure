import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventures/components/player.dart';
import 'package:pixel_adventures/components/level.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks{

  late final CameraComponent cam;
  final player = Player(character: 'Mask Dude');
  late final JoystickComponent joystick;
  
  @override
  Color backgroundColor()=>const Color(0xFF211F30);
  @override
  FutureOr<void> onLoad() async{
    //Load all images into cache memory
    await images.loadAllImages();
    final world  = Level(player: player,levelName: "Level-02");

    cam = CameraComponent.withFixedResolution(width: 640, height: 360, world: world);
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam,world]);
    addJoystick();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateJoystick();

  }

  void addJoystick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Knob.png'),),
      ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Joystick.png'),),
      ),
      margin: const EdgeInsets.only(left: 32.0, bottom: 32.0),
    );

    add(joystick);
  }

  void updateJoystick() {
    switch(joystick.direction){
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement =-1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement =1;
        break;
      default:
        player.horizontalMovement =0;
        break;
    }
  }
}