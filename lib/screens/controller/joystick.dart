import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/input_manager.dart';
import 'package:tetris/models/tetris.dart';
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
  final totalSize = 150.0;
  int tick = 0;

  static final int directionLengh = JoystickDirection.values.length;
  static const int capacityPerDirection = 3;

  JoystickDirection lastDirection;

  final tickSubject = PublishSubject<JoystickDirection>();
  StreamSubscription tickResetDebouncer;

  @override
  void initState() {
    super.initState();
    tickResetDebouncer = tickSubject
        .debounceTime(const Duration(milliseconds: 1000 * 3 ~/ delayedAutoShiftHz))
        .listen((_) {
      tick = 0;
    });
  }

  @override
  void dispose() {
    tickProviders.values.forEach((provider) {
      provider.cancel();
    });
    tickSubject.close();
    tickResetDebouncer.cancel();
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
                  builder: (context, _, __) => (index / 2) % capacityPerDirection == 0
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: LongPressButton(
                            padding: const EdgeInsets.all(0),
                            minWidth: totalSize / 3 + 8,
                            height: 60,
                            sensitivity: widget.sensitivity,
                            interval: widget.interval,
                            child: const Icon(Icons.arrow_left),
                            onPressed: () {
                              _onDirectionButtonPressed(direction);
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
                        tickSubject.sink.add(direction);

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
              width: totalSize * 0.618 * 0.618 * 0.8,
              height: totalSize * 0.618 * 0.618 * 0.8,
              child: DragTarget(
                builder: (context, candidateData, rejectedData) =>
                    const SizedBox(),
                onMove: (_) {
                  tickProviders[lastDirection]?.cancel();
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
                        sensitivity: widget.sensitivity,
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
        onDragEnd: (_) {
          tickProviders[lastDirection]?.cancel();
          tick = 0;
          lastDirection = null;
        },
      ),
    );
  }

  void _onDirectionButtonPressed(JoystickDirection direction) {
    _onDirectionEntered(direction);
    tick++;
    tickSubject.sink.add(direction);
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
