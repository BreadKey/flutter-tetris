import 'package:flutter/material.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/screens/tetris_screen/tetromino_renderer.dart';

class Logo extends StatelessWidget {
  final double height;

  const Logo({Key key, this.height: 28}) : super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: SizedBox(
            height: height,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TetrominoRenderer(TetrominoName.J, rotateCount: 3,),
                const Text("ust", style: TextStyle(color: Colors.white)),
                const TetrominoRenderer(TetrominoName.T, rotateCount: 2,),
                const Text("etris", style: TextStyle(color: Colors.white)),
              ],
            )),
      );
}