import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/screens/long_press_button.dart';

class Controller extends StatelessWidget {
  final Tetris tetris;
  final int longPressSensitivity;

  const Controller(
      {Key key, @required this.tetris, this.longPressSensitivity: 3})
      : assert(tetris != null),
        super(key: key);

  build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LongPressButton(
                minWidth: 0,
                child: const Icon(Icons.arrow_left),
                onPressed: () {
                  tetris.move(Direction.left);
                },
                sensitivity: longPressSensitivity,
              ),
              LongPressButton(
                minWidth: 0,
                child: const Icon(Icons.arrow_right),
                onPressed: () {
                  tetris.commandMove(Direction.right);
                },
                sensitivity: longPressSensitivity,
              )
            ],
          ),
          MaterialButton(
            onPressed: () {
              tetris.dropHard();
            },
            child: const Icon(Icons.file_download),
          ),
          Row(
            children: [
              LongPressButton(
                minWidth: 0,
                sensitivity: longPressSensitivity,
                onPressed: () {
                  tetris.commandRotate(clockwise: false);
                },
                child: const Icon(Icons.rotate_left),
              ),
              LongPressButton(
                  minWidth: 0,
                  sensitivity: longPressSensitivity,
                  onPressed: () {
                    tetris.commandRotate();
                  },
                  child: const Icon(Icons.rotate_right)),
            ],
          )
        ],
      );
}
