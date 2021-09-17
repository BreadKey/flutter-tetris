import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LongPressButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? minWidth;
  final double? height;
  final ShapeBorder? shape;
  final Color? color;
  final Color? splashColor;
  final Color? highlightColor;
  final Color? textColor;
  final Duration delay;
  final Duration interval;
  final EdgeInsets? padding;

  const LongPressButton(
      {Key? key,
      required this.onPressed,
      required this.child,
      this.minWidth,
      this.height,
      this.shape,
      this.color,
      this.splashColor,
      this.highlightColor,
      this.textColor,
      this.padding,
      required this.delay,
      required this.interval})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _LongPressButtonState();
}

class _LongPressButtonState extends State<LongPressButton> {
  Timer? _delayTimer;
  Timer? _intervalTimer;

  @override
  void dispose() {
    _delayTimer?.cancel();
    _intervalTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: widget.shape,
      color: widget.color,
      splashColor: widget.splashColor,
      highlightColor: widget.highlightColor,
      padding: widget.padding,
      elevation: 4,
      textColor: widget.textColor,
      minWidth: widget.minWidth,
      height: widget.height,
      onPressed: () {},
      onHighlightChanged: (pressed) {
        if (pressed) {
          HapticFeedback.lightImpact();
          widget.onPressed?.call();

          _delayTimer = Timer(widget.delay, () {
            _intervalTimer = Timer.periodic(widget.interval, (timer) {
              widget.onPressed?.call();
            });
          });
        } else {
          _delayTimer!.cancel();
          _intervalTimer?.cancel();
        }
      },
      child: widget.child,
    );
  }
}
