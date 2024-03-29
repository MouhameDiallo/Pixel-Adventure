import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventures/pixel_adventure.dart';

class JumpButton extends SpriteComponent with HasGameRef<PixelAdventure>, TapCallbacks {
  final margin = 32;
  final buttonSize = 64;
  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/JumpButton.png'));
    position = Vector2(
      gameRef.size.x - margin - buttonSize,
      gameRef.size.y - margin - buttonSize,
    );
    priority = 100;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }
}
