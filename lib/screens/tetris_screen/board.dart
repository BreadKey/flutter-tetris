import 'package:flutter/material.dart';
import 'package:tetris/retro_colors.dart';

class Board extends StatelessWidget {
  final Widget child;

  const Board({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        color: neutralBlackC,
        elevation: 4,
        child: child,
      );
}
