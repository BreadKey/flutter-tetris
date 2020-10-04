import 'package:flutter/material.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/models/tetromino.dart';
import 'package:tetris/retro_colors.dart';
import 'package:tetris/screens/controller.dart';
import 'package:tetris/screens/playfield_renderer.dart';

class TetrisScreen extends StatelessWidget {
  final tetris = Tetris();

  @override
  Widget build(BuildContext context) {
    tetris.spawn(TetrominoName.iMino);
    
    return Container(
      color: antiqueWhite,
      child: Column(
        children: [
          Expanded(
            flex: 2618,
            child: PlayfieldRenderer(tetris),
          ),
          Expanded(
            flex: 1000,
            child: Controller(),
          )
        ],
      ),
    );
  }
}
