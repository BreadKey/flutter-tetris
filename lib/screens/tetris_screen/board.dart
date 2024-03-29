import 'package:flutter/material.dart';
import 'package:tetris/retro_colors.dart';

class Board extends StatelessWidget {
  final Widget? child;

  const Board({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => Theme(
        data: Theme.of(context).copyWith(
            textTheme:
                Theme.of(context).textTheme.apply(bodyColor: Colors.black87)),
        child: Material(
          elevation: 4,
          color: RetroColors.retroWhite,
          borderRadius: BorderRadius.circular(6),
          child: child,
        ),
      );
}
