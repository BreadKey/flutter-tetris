import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tetris/models/rules.dart';

class LongPressButton extends StatefulWidget {
  final int sensitivity;
  final VoidCallback onPressed;
  final Widget child;
  final double minWidth;
  final double height;
  final ShapeBorder shape;
  final Color color;
  final Color textColor;

  const LongPressButton(
      {Key key,
      @required this.sensitivity,
      @required this.onPressed,
      @required this.child,
      this.minWidth,
      this.height,
      this.shape,
      this.color,
      this.textColor})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _LongPressButtonState();
}

class _LongPressButtonState extends State<LongPressButton> {
  Timer _longPressTimer;

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: widget.shape,
      color: widget.color,
      textColor: widget.textColor,
      minWidth: widget.minWidth,
      height: widget.height,
      onPressed: () {},
      onHighlightChanged: (pressed) {
        if (pressed) {
          widget.onPressed?.call();

          int pressTick = 0;
          _longPressTimer?.cancel();
          _longPressTimer = Timer.periodic(
              const Duration(milliseconds: 1000 ~/ dasHz), (timer) {
            pressTick++;

            if (pressTick > widget.sensitivity) {
              widget.onPressed?.call();
            }
          });
        } else {
          _longPressTimer?.cancel();
        }
      },
      child: widget.child,
    );
  }
}
