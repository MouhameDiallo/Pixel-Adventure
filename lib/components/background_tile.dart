import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/cupertino.dart';
import 'package:pixel_adventures/pixel_adventure.dart';

class BackgroundTile extends ParallaxComponent{
  final String color;

  BackgroundTile({this.color = 'Gray',position}) : super(position: position);
  final double scrollSpeed = 40;

  @override
  FutureOr<void> onLoad() async{
    priority = -10;
    size = Vector2.all(64.6);
    parallax = await game.loadParallax(
      [ParallaxImageData('Background/$color.png')],
      fill: LayerFill.none,
      repeat: ImageRepeat.repeat,
      baseVelocity: Vector2(0, -scrollSpeed),
    );
    return super.onLoad();
  }


}