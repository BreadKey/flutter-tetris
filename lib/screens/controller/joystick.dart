import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/input_manager.dart';
import 'package:tetris/retro_colors.dart';
import 'package:tetris/screens/long_press_button.dart';
import 'package:tetris/screens/metal.dart';

class JoyStick extends StatefulWidget {
  final int sensitivity;
  final Duration interval;
  JoyStick({Key key, @required this.sensitivity, @required this.interval})
      : super(key: key);

  @override
  _JoyStickState createState() => _JoyStickState();
}

class _JoyStickState extends State<JoyStick> {
  final tickProviders = <int, Timer>{};
  final totalSize = 160.0;
  int tick = 0;

  static const int directionLengh = 8;
  static const int capacityPerDirection = 3;

  int lastDirection;

  void dispose() {
    tickProviders.values.forEach((provider) {
      provider.cancel();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ball = SizedBox(
      width: totalSize * 0.618 * 0.85,
      height: totalSize * 0.618 * 0.85,
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
            ..addAll(List.generate(
              directionLengh * capacityPerDirection ~/ 2,
              (index) {
                final diagonalIndex = index +
                    ((index ~/ capacityPerDirection) + 1) *
                        capacityPerDirection;
                return _buildInputArea(context, diagonalIndex);
              },
            ))
            ..addAll(List.generate(
              directionLengh * capacityPerDirection ~/ 2,
              (index) {
                final crossIndex = index +
                    (index ~/ capacityPerDirection) * capacityPerDirection;
                return _buildInputArea(context, crossIndex);
              },
            ))
            ..addAll(List.generate(
                directionLengh * capacityPerDirection,
                (index) => Center(
                        child: Transform.rotate(
                      angle: pi /
                          (directionLengh * capacityPerDirection / 2) *
                          (index + 1),
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
                    ))))
            ..add(Center(
              child: Draggable(
                child: ball,
                feedback: ball,
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
                },
              ),
            ))),
    );
  }

  Widget _buildInputArea(BuildContext context, int index) {
    final direction = index ~/ capacityPerDirection;
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
                  onLeave: (_) {
                    print("leave");
                  },
                ))),
      ),
    );
  }

  void _onDirectionEntered(int direction) {
    lastDirection = direction;
    switch (direction) {
      case 0:
        InputManager.instance.enterDirection(Direction.left);
        break;
      case 1:
        InputManager.instance.enterDirection(Direction.left);
        InputManager.instance.enterDirection(Direction.up);
        break;
      case 2:
        InputManager.instance.enterDirection(Direction.up);
        break;
      case 3:
        InputManager.instance.enterDirection(Direction.up);
        InputManager.instance.enterDirection(Direction.right);
        break;
      case 4:
        InputManager.instance.enterDirection(Direction.right);
        break;
      case 5:
        InputManager.instance.enterDirection(Direction.right);
        InputManager.instance.enterDirection(Direction.down);
        break;
      case 6:
        InputManager.instance.enterDirection(Direction.down);
        break;
      case 7:
        InputManager.instance.enterDirection(Direction.down);
        InputManager.instance.enterDirection(Direction.left);
        break;
      default:
        break;
    }
  }
}
