import 'package:flutter/material.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/screens/tetris_screen/tetromino_renderer.dart';

class Logo extends StatelessWidget {
  final double height;

  const Logo({super.key, this.height = 28});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: SizedBox(
            height: height,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TetrominoRenderer(
                  TetrominoName.J,
                  rotateCount: 3,
                  kicks: [Direction.right, Direction.right, Direction.up],
                ),
                const Text(" ust", style: TextStyle(color: Colors.white)),
                const TetrominoRenderer(
                  TetrominoName.T,
                  rotateCount: 2,
                  kicks: [Direction.up, Direction.right],
                ),
                const Text(" etris", style: TextStyle(color: Colors.white)),
              ],
            )),
      );
}
