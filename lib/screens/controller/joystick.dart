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
  final int sensitivity;
  final Duration interval;
  Joystick({Key key, @required this.sensitivity, @required this.interval})
      : super(key: key);

  @override
  _JoystickState createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  final tickProviders = <JoystickDirection, Timer>{};
  final totalSize = 160.0;
  int tick = 0;

  static final int directionLengh = JoystickDirection.values.length;
  static const int capacityPerDirection = 4;

  JoystickDirection lastDirection;

  void dispose() {
    tickProviders.values.forEach((provider) {
      provider.cancel();
    });
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
        offset: (Offset(-totalSize / 2 / 1.618, 0)),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
                width: totalSize / 1.618,
                height: totalSize / capacityPerDirection,
                child: DragTarget(
                  builder: (context, _, __) => index % capacityPerDirection == 0
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: LongPressButton(
                            minWidth: 24,
                            height: 48,
                            sensitivity: widget.sensitivity,
                            interval: widget.interval,
                            child: const Icon(Icons.arrow_left),
                            onPressed: () {
                              _onDirectionEntered(direction);
                              lastDirection = null;
                            },
                          ),
                        )
                      : const SizedBox(),
                  onMove: (_) {
                    if (tickProviders[direction]?.isActive != true) {
                      if (lastDirection != direction) {
                        _onDirectionEntered(direction);
                        tickProviders.forEach((key, provider) {
                          if (key != direction) {
                            provider.cancel();
                          }
                        });
                      }

                      tickProviders[direction] =
                          Timer.periodic(widget.interval, (timer) {
                        tick++;

                        if (tick > widget.sensitivity) {
                          _onDirectionEntered(direction);
                        }
                      });
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
              width: totalSize * 0.618 * 0.618 * 0.9,
              height: totalSize * 0.618 * 0.618 * 0.9,
              child: DragTarget(
                builder: (context, candidateData, rejectedData) =>
                    const SizedBox(),
                onMove: (_) {
                  tickProviders[lastDirection]?.cancel();
                },
              ),
            ),
          )));

  Widget buildStick(BuildContext) {
    final lever = SizedBox(
      width: totalSize * 0.618 * 0.8,
      height: totalSize * 0.618 * 0.8,
      child: Material(
        elevation: 8,
        shape: CircleBorder(),
        color: Colors.grey,
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                Colors.black12,
                neutralBlackC,
                Colors.black87,
                Colors.black
              ])),
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                shape: BoxShape.circle, border: Border.all(color: Colors.grey)),
          ),
        ),
      ),
    );

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
        onDragEnd: (_) {
          tickProviders[lastDirection]?.cancel();
          tick = 0;
          lastDirection = null;
        },
      ),
    );
  }

  void _onDirectionEntered(JoystickDirection direction) {
    lastDirection = direction;
    switch (direction) {
      case JoystickDirection.centerLeft:
        InputManager.instance.enterDirection(Direction.left);
        break;
      case JoystickDirection.topLeft:
        InputManager.instance.enterDirection(Direction.left);
        InputManager.instance.enterDirection(Direction.up);
        break;
      case JoystickDirection.topCenter:
        InputManager.instance.enterDirection(Direction.up);
        break;
      case JoystickDirection.topRight:
        InputManager.instance.enterDirection(Direction.up);
        InputManager.instance.enterDirection(Direction.right);
        break;
      case JoystickDirection.centerRight:
        InputManager.instance.enterDirection(Direction.right);
        break;
      case JoystickDirection.bottomRight:
        InputManager.instance.enterDirection(Direction.right);
        InputManager.instance.enterDirection(Direction.down);
        break;
      case JoystickDirection.bottomCenter:
        InputManager.instance.enterDirection(Direction.down);
        break;
      case JoystickDirection.bottomLeft:
        InputManager.instance.enterDirection(Direction.down);
        InputManager.instance.enterDirection(Direction.left);
        break;
      default:
        break;
    }
  }
}
