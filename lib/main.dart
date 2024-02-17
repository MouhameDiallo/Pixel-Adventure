import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventures/pixel_adventure.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //S'assurer que le rendu prenne tout l'ecran
  await Flame.device.fullScreen();
  //Affichage en mode paysage
  await Flame.device.setLandscape();

  PixelAdventure game = PixelAdventure();
  runApp(GameWidget(game: kDebugMode? PixelAdventure(): game));
}

