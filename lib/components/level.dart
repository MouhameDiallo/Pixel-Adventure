import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventures/components/background_tile.dart';
import 'package:pixel_adventures/components/checkpoint.dart';
import 'package:pixel_adventures/components/collison_block.dart';
import 'package:pixel_adventures/components/fruit.dart';
import 'package:pixel_adventures/components/player.dart';
import 'package:pixel_adventures/components/saw.dart';
import 'package:pixel_adventures/pixel_adventure.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  late TiledComponent level;
  final String levelName;
  final Player player;
  List<CollisionBlock> collisionBlocks = [];
  Level({required this.levelName, required this.player});
  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2(16, 16));
    add(level);

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');
    const tileSize = 64;
    final numTileY = (gameRef.size.y / tileSize).floor();
    final numTileX = (gameRef.size.x / tileSize).floor();
    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor');

      for (int y = 0; y < gameRef.size.y / numTileY; y++) {
        for (int x = 0; x < numTileX; x++) {
          final backgroundTile = BackgroundTile(
            color: backgroundColor ?? 'Gray',
            position: Vector2((x * tileSize - tileSize) as double,
                (y * tileSize - tileSize) as double),
          );
          add(backgroundTile);
        }
      }
    }
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          case 'Fruit':
            Fruit fruit = Fruit(
                name: spawnPoint.name,
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2.all(32.0));
            add(fruit);
            break;
          case 'Saw':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            Saw saw = Saw(
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2.all(38.0),
            );
            add(saw);
            break;
          case 'Checkpoint':
            Checkpoint checkpoint = Checkpoint(position: Vector2(spawnPoint.x, spawnPoint.y),size: Vector2.all(64.0),);
            add(checkpoint);
            break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }
}
