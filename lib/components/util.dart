import 'package:pixel_adventures/components/collison_block.dart';

bool checkCollision(player, CollisionBlock block){
  final hitBox = player.hitBox;
  final playerX = player.position.x + hitBox.offsetX;
  final playerY = player.position.y + hitBox.offsetY;
  final playerWidth = hitBox.width;
  final playerHeight = hitBox.height;

  final blockX = block.position.x;
  final blockY = block.position.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  final fixedX = player.scale.x<0? playerX - (hitBox.offsetX *2) - playerWidth: playerX;
  final fixedY = block.isPlatform? playerY + playerHeight: playerY;

  //Enfaite ici, on utilise && au lieu de || parce qu'une collision dans un axe
  // entraine forcement une collison dans l'autre car la boite de collision est
  // rectangulaire
  return (fixedY < blockY + blockHeight && fixedY + playerHeight > blockY &&
      fixedX< blockX + blockWidth && fixedX + playerWidth > blockX) ;
}