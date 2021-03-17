import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/input_manager.dart';
import 'package:tetris/retro_colors.dart';
import 'package:tetris/screens/long_press_button.dart';
import 'package:tetris/screens/metal.dart';

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
  final Duration delay;
  final Duration interval;
  Joystick({Key key, @required this.delay, @required this.interval})
      : assert(delay != null),
        assert(interval != null),
        super(key: key);

  @override
  _JoystickState createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  static const totalSize = 150.0;
  static const leverDiameter = totalSize * 0.618;
  static const leverInputRadius = leverDiameter / 2 * 0.618;

  static final int directionLengh = JoystickDirection.values.length;
  static const int capacityPerDirection = 3;

  JoystickDirection lastDirection;

  Timer delayTimer;
  Timer intervalTimer;

  Offset leverPosition = Offset.zero;

  @override
  void dispose() {
    delayTimer?.cancel();
    intervalTimer?.cancel();
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
        offset: (Offset(-totalSize / 2 / 1.618 * 0.8, 0)),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
                width: totalSize / 1.618 * 0.95,
                height: totalSize / capacityPerDirection * 1.2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: LongPressButton(
                    padding: const EdgeInsets.all(0),
                    minWidth: totalSize / 3 + 8,
                    height: 60,
                    delay: widget.delay,
                    interval: widget.interval,
                    child: const Icon(Icons.arrow_left),
                    onPressed: () {
                      _onDirectionEntered(direction);
                    },
                  ),
                ))),
      ),
    );
  }

  Widget _buildStick(BuildContext context) {
    final lever = SizedBox(
        width: leverDiameter,
        height: leverDiameter,
        child: Material(
          elevation: 8,
          shape: CircleBorder(),
          color: Colors.grey,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                      neutralBlackC.shade400,
                      neutralBlackC,
                      neutralBlackC.shade600,
                      neutralBlackC.shade800
                    ])),
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey)),
                ),
              ),
            ]..addAll(List.generate(4, (index) {
                final direction = JoystickDirection.values[index * 2];

                return Transform.rotate(
                    angle: pi / 2 * index,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: LongPressButton(
                        minWidth: 24,
                        height: 48,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: const SizedBox(),
                        padding: const EdgeInsets.all(0),
                        delay: widget.delay,
                        interval: widget.interval,
                        onPressed: () {
                          _onDirectionEntered(direction);
                        },
                      ),
                    ));
              })),
          ),
        ));

    return Center(
      child: Draggable(
        child: lever,
        feedback: lever,
        childWhenDragging: const SizedBox(
          width: totalSize * 0.618 * 0.618,
          height: totalSize * 0.618 * 0.618,
          child: Material(
            shape: CircleBorder(),
            color: Colors.black,
          ),
        ),
        onDragStarted: () {
          delayTimer = Timer(widget.delay, () {
            intervalTimer = Timer.periodic(widget.interval, (_) {
              _onDirectionEntered(lastDirection);
            });
          });
        },
        onDragEnd: (_) {
          delayTimer.cancel();
          intervalTimer?.cancel();
          lastDirection = null;
          leverPosition = Offset.zero;
        },
        onDragUpdate: (details) {
          leverPosition += details.delta;
          if (leverPosition.distance < leverInputRadius) {
            lastDirection = null;
          } else {
            _detectDirection();
          }
        },
      ),
    );
  }

  void _detectDirection() {
    final radian = leverPosition.direction;
    JoystickDirection direction;

    const bottomLeftStart = 13 / 16 * pi;
    const bottomCenterStart = 11 / 16 * pi;
    const bottomRightStart = 5 / 16 * pi;
    const centerRightStart = 3 / 16 * pi;
    const topRightStart = -3 / 16 * pi;
    const topCenterStart = -5 / 16 * pi;
    const topLeftStart = -11 / 16 * pi;
    const centerleftStart = -13 / 16 * pi;

    if (radian < centerleftStart || radian > bottomLeftStart) {
      direction = JoystickDirection.centerLeft;
    } else if (radian <= bottomLeftStart && radian > bottomCenterStart) {
      direction = JoystickDirection.bottomLeft;
    } else if (radian <= bottomLeftStart && radian > bottomRightStart) {
      direction = JoystickDirection.bottomCenter;
    } else if (radian <= bottomRightStart && radian > centerRightStart) {
      direction = JoystickDirection.bottomRight;
    } else if (radian <= centerRightStart && radian > topRightStart) {
      direction = JoystickDirection.centerRight;
    } else if (radian <= topRightStart && radian > topCenterStart) {
      direction = JoystickDirection.topRight;
    } else if (radian <= topCenterStart && radian > topLeftStart) {
      direction = JoystickDirection.topCenter;
    } else {
      direction = JoystickDirection.topLeft;
    }

    if (direction != lastDirection) {
      _onDirectionEntered(direction);
    }
  }

  void _onDirectionEntered(JoystickDirection direction) {
    lastDirection = direction;

    switch (direction) {
      case JoystickDirection.bottomLeft:
      case JoystickDirection.centerLeft:
      case JoystickDirection.topLeft:
        InputManager.instance.enterDirection(Direction.left);
        break;
      default:
        break;
    }
    switch (direction) {
      case JoystickDirection.topLeft:
      case JoystickDirection.topCenter:
      case JoystickDirection.topRight:
        InputManager.instance.enterDirection(Direction.up);
        break;
      default:
        break;
    }
    switch (direction) {
      case JoystickDirection.topRight:
      case JoystickDirection.centerRight:
      case JoystickDirection.bottomRight:
        InputManager.instance.enterDirection(Direction.right);
        break;
      default:
        break;
    }
    switch (direction) {
      case JoystickDirection.bottomRight:
      case JoystickDirection.bottomCenter:
      case JoystickDirection.bottomLeft:
        InputManager.instance.enterDirection(Direction.down);
        break;
      default:
        break;
    }
  }
}
