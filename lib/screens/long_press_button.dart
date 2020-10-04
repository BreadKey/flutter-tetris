import 'dart:async';

import 'package:flutter/material.dart';

class LongPressButton extends StatefulWidget {
  final int sensitivity;
  final VoidCallback onPressed;
  final Widget child;
  final double minWidth;

  const LongPressButton(
      {Key key,
      @required this.sensitivity,
      @required this.onPressed,
      @required this.child,
      this.minWidth})
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
      minWidth: widget.minWidth,
      onPressed: () {},
      onHighlightChanged: (pressed) {
        if (pressed) {
          widget.onPressed?.call();

          int pressTick = 0;
          _longPressTimer?.cancel();
          _longPressTimer =
              Timer.periodic(const Duration(milliseconds: 100), (timer) {
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
