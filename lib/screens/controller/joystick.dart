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
  final totalSize = 150.0;

  static final int directionLengh = JoystickDirection.values.length;
  static const int capacityPerDirection = 3;

  JoystickDirection lastDirection;

  Timer delayTimer;
  Timer intervalTimer;

  @override
  void dispose() {
    delayTimer?.cancel();
    intervalTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cross = 0;
    final diagonal = 1;

    return SizedBox(
        width: totalSize,
        height: totalSize,
        child: Stack(
            children: [
          Metal(
            width: totalSize,
            height: totalSize,
            color: bitOfBlue,
            shape: BoxShape.circle,
            child: SizedBox.expand(),
          )
        ]
              ..addAll(buildDirectionsArea(context, diagonal))
              ..addAll(buildDirectionsArea(context, cross))
              ..addAll(buildNeutralArea(context))
              ..add(buildStick(context))));
  }

  Widget _buildDetectDirectionArea(BuildContext context, int index) {
    final direction = JoystickDirection.values[index ~/ capacityPerDirection];

    return Transform.rotate(
      angle: pi / (directionLengh * capacityPerDirection / 2) * (index + 1) -
          2 * pi / (directionLengh * capacityPerDirection),
      child: Transform.translate(
        offset: (Offset(-totalSize / 2 / 1.618 * 0.8, 0)),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
                width: totalSize / 1.618 * 0.95,
                height: totalSize / capacityPerDirection * 1.2,
                child: DragTarget(
                  builder: (context, _, __) =>
                      (index / 2) % capacityPerDirection == 0
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: LongPressButton(
                                padding: const EdgeInsets.all(0),
                                minWidth: totalSize / 3 + 8,
                                height: 60,
                                delay: widget.delay,
                                interval: widget.interval,
                                child: const Icon(Icons.arrow_left),
                                onPressed: () {
                                  _onDirectionButtonPressed(direction);
                                },
                              ),
                            )
                          : const SizedBox(),
                  onMove: (_) {
                    if (lastDirection != direction) {
                      _onDirectionEntered(direction);
                    }
                  },
                ))),
      ),
    );
  }

  List<Widget> buildDirectionsArea(BuildContext context, int offset) =>
      List.generate(
        (directionLengh * capacityPerDirection) ~/ 2,
        (index) {
          final diagonalIndex = index +
              ((index ~/ capacityPerDirection) + offset) * capacityPerDirection;
          return _buildDetectDirectionArea(context, diagonalIndex);
        },
      );

  List<Widget> buildNeutralArea(BuildContext context) => List.generate(
      directionLengh * capacityPerDirection,
      (index) => Center(
              child: Transform.rotate(
            angle:
                pi / (directionLengh * capacityPerDirection / 2) * (index + 1),
            child: Container(
              width: totalSize * 0.618 * 0.618 * 0.8,
              height: totalSize * 0.618 * 0.618 * 0.8,
              child: DragTarget(
                builder: (context, candidateData, rejectedData) =>
                    const SizedBox(),
                onMove: (_) {
                  lastDirection = null;
                },
              ),
            ),
          )));

  Widget buildStick(BuildContext context) {
    final lever = SizedBox(
        width: totalSize * 0.618,
        height: totalSize * 0.618,
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
                          _onDirectionButtonPressed(direction);
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
        childWhenDragging: Container(
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
        },
      ),
    );
  }

  void _onDirectionButtonPressed(JoystickDirection direction) {
    _onDirectionEntered(direction);
    lastDirection = null;
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
