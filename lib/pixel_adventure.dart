import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventures/levels/level.dart';

class PixelAdventure extends FlameGame{

  late final CameraComponent cam;
  @override
  final world  = Level(levelName: "Level-02");
  
  @override
  Color backgroundColor()=>const Color(0xFF211F30);
  @override
  FutureOr<void> onLoad() async{
    //Load all images into cache memory
    await images.loadAllImages();

    cam = CameraComponent.withFixedResolution(width: 640, height: 360, world: world);
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam,world]);
    // TODO: implement onLoad
    return super.onLoad();
  }
}