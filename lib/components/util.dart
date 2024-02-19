import 'package:pixel_adventures/components/collison_block.dart';

bool checkCollision(player, CollisionBlock block){
  final playerX = player.position.x;
  final playerY = player.position.y;
  final playerWidth = player.width;
  final playerHeight = player.height;

  final blockX = block.position.x;
  final blockY = block.position.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  final fixedX = player.scale.x<0? playerX - playerWidth: playerX;
  final fixedY = block.isPlatform? playerY + playerHeight: playerY;

  //Enfaite ici, on utilise && au lieu de || parce qu'une collision dans un axe
  // entraine forcement une collison dans l'autre car la boite de collision est
  // rectangulaire
  return (fixedY < blockY + blockHeight && fixedY + playerHeight > blockY &&
      fixedX< blockX + blockWidth && fixedX + playerWidth > blockX) ;
}