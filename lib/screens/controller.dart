import 'package:flutter/material.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/input_manager.dart';
import 'package:tetris/retro_colors.dart';
import 'package:tetris/screens/action_icons.dart';
import 'package:tetris/screens/controller/joystick.dart';
import 'package:tetris/screens/long_press_button.dart';

class Controller extends StatelessWidget {
  static const double actionButtonSpace = 14 * 1.518;
  static const double defaultCircleButtonSize = 52;

  final int longPressSensitivity;
  final Duration longPressInterval;

  final _inputManager = InputManager.instance;

  Controller(
      {Key key, @required this.longPressInterval, this.longPressSensitivity: 5})
      : assert(longPressInterval != null),
        super(key: key);

  @override
  build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: JoyStick(
              sensitivity: longPressSensitivity,
              interval: longPressInterval,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: buildActionButtons(context),
          )
        ],
      ));

  Widget buildDirectionButtons(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LongPressButton(
            sensitivity: longPressSensitivity,
            interval: longPressInterval,
            onPressed: () {
              _inputManager.enterDirection(Direction.up);
            },
            color: neutralBlackC,
            textColor: Colors.white,
            child: const Icon(Icons.arrow_drop_up),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24), bottom: Radius.circular(8))),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LongPressButton(
                sensitivity: longPressSensitivity,
                interval: longPressInterval,
                color: neutralBlackC,
                textColor: Colors.white,
                height: defaultCircleButtonSize,
                child: const Icon(Icons.arrow_left),
                onPressed: () {
                  _inputManager.enterDirection(Direction.left);
                },
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(24), right: Radius.circular(8))),
              ),
              LongPressButton(
                sensitivity: longPressSensitivity,
                interval: longPressInterval,
                color: neutralBlackC,
                textColor: Colors.white,
                height: defaultCircleButtonSize,
                child: const Icon(Icons.arrow_right),
                onPressed: () {
                  _inputManager.enterDirection(Direction.right);
                },
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(24), left: Radius.circular(8))),
              ),
            ],
          ),
          LongPressButton(
            sensitivity: longPressSensitivity,
            interval: longPressInterval,
            onPressed: () {
              _inputManager.enterDirection(Direction.down);
            },
            color: neutralBlackC,
            textColor: Colors.white,
            child: const Icon(Icons.arrow_drop_down),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(8), bottom: Radius.circular(24))),
          )
        ],
      );

  Widget buildActionButtons(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(
                height: actionButtonSpace * 5,
              ),
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
            width: 4,
            color: Colors.transparent,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(
                height: actionButtonSpace * 3,
              ),
              buildCircleButton(
                context,
                onPressed: () {
                  _inputManager.enterButton(ButtonKey.b);
                },
                child: const HardDropIcon(),
              ),
            ],
          ),
          const VerticalDivider(
            width: 4,
            color: Colors.transparent,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(
                height: actionButtonSpace,
              ),
              buildCircleButton(
                context,
                onPressed: () {
                  _inputManager.enterButton(ButtonKey.c);
                },
                child: const RotateIcon(),
              ),
            ],
          )
        ],
      );

  Widget buildCircleButton(BuildContext context,
          {@required VoidCallback onPressed,
          @required Widget child,
          double size = defaultCircleButtonSize,
          MaterialColor color = roseViolet}) =>
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
          sensitivity: longPressSensitivity,
          interval: longPressInterval,
          onPressed: onPressed,
          child: child,
          minWidth: size,
          height: size,
          shape: const CircleBorder(),
          textColor: Colors.white,
        )
      ]);
}
