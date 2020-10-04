import 'package:flutter/material.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/tetris.dart';

class Controller extends StatelessWidget {
  final Tetris tetris;

  const Controller({Key key, @required this.tetris})
      : assert(tetris != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RaisedButton(
                onPressed: () {
                  tetris.move(Direction.left);
                },
                child: const Icon(Icons.arrow_left),
              ),
              RaisedButton(
                onPressed: () {
                  tetris.move(Direction.right);
                },
                child: const Icon(Icons.arrow_right),
              )
            ],
          )
        ],
      );
}
