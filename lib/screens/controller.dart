import 'dart:math';

import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:tetris/models/audio_manager.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/input_manager.dart';
import 'package:tetris/retro_colors.dart';
import 'package:tetris/screens/action_icons.dart';
import 'package:tetris/screens/controller/joystick.dart';
import 'package:tetris/screens/long_press_button.dart';

class Controller extends StatelessWidget {
  static const double actionButtonSpace = 14 * 1.518;
  static const double defaultCircleButtonSize = 52;

  final Duration longPressDelay;
  final Duration longPressInterval;

  final _inputManager = InputManager.instance;
  final _audioManager = Injector.appInstance.get<IAudioManager>();

  Controller(
      {Key key,
      @required this.longPressDelay,
      @required this.longPressInterval})
      : assert(longPressDelay != null),
        assert(longPressInterval != null),
        super(key: key);

  @override
  build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Joystick(
              holdDelay: longPressDelay,
              holdInterval: longPressInterval,
              onDirectionEntered: _onJoystickDirectionEntered,
            ),
          ),
          Align(
              alignment: Alignment.centerRight,
              child: Transform.translate(
                offset: Offset(0, actionButtonSpace / 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildSpecialButtons(context),
                    buildActionButtons(context)
                  ],
                ),
              ))
        ],
      ));

  void _onJoystickDirectionEntered(JoystickDirection direction) {
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

  Widget buildActionButtons(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildCircleButton(
                context,
                onPressed: () {
                  _inputManager.enterButton(ButtonKey.a);
                },
                child: const RotateIcon(
                  clockwise: false,
                ),
              ),
            ],
          ),
          const VerticalDivider(
            width: 8,
            color: Colors.transparent,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildCircleButton(
                context,
                onPressed: () {
                  _inputManager.enterButton(ButtonKey.b);
                },
                child: const HardDropIcon(),
              ),
              const Divider(
                height: actionButtonSpace * 2,
              ),
            ],
          ),
          const VerticalDivider(
            width: 8,
            color: Colors.transparent,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildCircleButton(
                context,
                onPressed: () {
                  _inputManager.enterButton(ButtonKey.c);
                },
                child: const RotateIcon(),
              ),
              const Divider(
                height: actionButtonSpace * 4,
              ),
            ],
          ),
        ],
      );

  Widget buildCircleButton(BuildContext context,
          {@required VoidCallback onPressed,
          @required Widget child,
          double size = defaultCircleButtonSize,
          MaterialColor color = bitOfBlue}) =>
      Stack(alignment: Alignment.center, children: [
        Material(
          color: color.shade600,
          shape: const CircleBorder(),
          elevation: 4,
          child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: Container(
                  width: size - 12,
                  height: size - 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.shade50,
                          color.shade200,
                          color,
                          color,
                          color.shade600,
                          color.shade800
                        ]),
                  ),
                ),
              )),
        ),
        LongPressButton(
          delay: longPressDelay,
          interval: longPressInterval,
          onPressed: onPressed,
          child: child,
          minWidth: size,
          height: size,
          shape: const CircleBorder(),
          textColor: Colors.grey,
        ),
      ]);

  Widget buildSpecialButtons(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Transform.translate(
            offset: Offset(0, actionButtonSpace / 2),
            child: StatefulBuilder(
                builder: (context, setState) => _buildSpecialButton(
                      context,
                      onPressed: () {
                        _audioManager.toggleMute();
                        setState(() {});
                      },
                      icon: Icon(
                        _audioManager.isMuted
                            ? Icons.volume_up
                            : Icons.volume_off,
                        color: Colors.white54,
                      ),
                    )),
          ),
          _buildSpecialButton(context, onPressed: () {
            InputManager.instance.enterButton(ButtonKey.special2);
          },
              icon: Text(
                "Hold",
                style: TextStyle(color: Colors.white54),
              )),
          const VerticalDivider(
            color: Colors.transparent,
            width: actionButtonSpace,
          )
        ],
      );

  Widget _buildSpecialButton(BuildContext context,
          {@required VoidCallback onPressed, Widget icon}) =>
      Transform.rotate(
        angle: -pi / 6,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
                offset: Offset(0, 18),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 24),
                  child: Material(
                    child: icon,
                    color: Colors.transparent,
                  ),
                )),
            MaterialButton(
              onPressed: onPressed,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              color: bitOfBlue,
              minWidth: 24,
              height: 10,
            ),
          ],
        ),
      );
}
