library joystick;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/retro_colors.dart';
import 'package:tetris/screens/long_press_button.dart';
import 'package:tetris/screens/metal.dart';

part 'joystick/handler.dart';
part 'joystick/lever.dart';

enum JoystickDirection {
  centerLeft,
  topLeft,
  topCenter,
  topRight,
  centerRight,
  bottomRight,
  bottomCenter,
  bottomLeft,
}

class Joystick extends StatefulWidget {
  final Duration holdDelay;
  final Duration holdInterval;
  final Function(JoystickDirection direction)? onDirectionEntered;
  Joystick(
      {Key? key,
      required this.holdDelay,
      required this.holdInterval,
      required this.onDirectionEntered})
      : super(key: key);

  @override
  _JoystickState createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  static const totalSize = 150.0;
  static const leverDiameter = totalSize * 0.618;

  late JoystickHandler handler;

  JoystickDirection? lastDirection;

  Offset leverPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    handler = JoystickHandler(widget.holdDelay, widget.holdInterval,
        leverDiameter / 2 * 0.618, widget.onDirectionEntered);
  }

  @override
  void dispose() {
    handler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: totalSize,
        height: totalSize,
        child: Metal(
            width: totalSize,
            height: totalSize,
            color: bitOfBlue,
            shape: BoxShape.circle,
            child: ClipOval(
                child: Stack(
                    children: List.generate(4, _buildDirectionButton)
                      ..add(_buildStick(context))))));
  }

  Widget _buildDirectionButton(int index) {
    final direction = JoystickDirection.values[index * 2];

    return Transform.rotate(
      angle: pi / 2 * index,
      child: Transform.translate(
        offset: (Offset(-leverDiameter / 2, 0)),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
                width: leverDiameter,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: LongPressButton(
                    padding: const EdgeInsets.all(0),
                    minWidth: leverDiameter / 1.618,
                    height: leverDiameter,
                    delay: widget.holdDelay,
                    interval: widget.holdInterval,
                    child: const Icon(Icons.arrow_left),
                    onPressed: () {
                      handler.onDirectionEntered?.call(direction);
                    },
                  ),
                ))),
      ),
    );
  }

  Widget _buildStick(BuildContext context) {
    return Center(
      child: Draggable(
        child: Lever(diameter: leverDiameter, handler: handler),
        feedback: Lever(diameter: leverDiameter, handler: handler),
        childWhenDragging: _buildHole(context),
        onDragStarted: () {
          handler.holdLever();
        },
        onDragEnd: (_) {
          handler.releaseLever();
        },
        onDragUpdate: (details) {
          handler.moveLever(details.delta);
        },
      ),
    );
  }

  Widget _buildHole(BuildContext context) {
    const holeDiameter = leverDiameter * 0.618;

    return const SizedBox(
      width: holeDiameter,
      height: holeDiameter,
      child: Material(
        color: Colors.black,
        shape: CircleBorder(),
      ),
    );
  }
}
