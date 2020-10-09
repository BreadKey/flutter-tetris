import 'package:flutter/material.dart';
import 'package:tetris/models/tetris.dart';

class HoldButton extends StatelessWidget {
  final Tetris tetris;

  const HoldButton(this.tetris, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MaterialButton(
            onPressed: () {
              tetris.hold();
            },
            color: Theme.of(context).buttonColor,
            minWidth: 24,
            height: 8,
          ),
          Material(
            color: Colors.transparent,
            child: Text(
              "hold",
              style: TextStyle(color: Theme.of(context).iconTheme.color),
            ),
          ),
        ],
      );
}
