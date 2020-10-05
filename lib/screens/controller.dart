import 'package:flutter/material.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/input_manager.dart';
import 'package:tetris/retro_colors.dart';
import 'package:tetris/screens/long_press_button.dart';

class Controller extends StatelessWidget {
  final int longPressSensitivity;
  final double defaultCircleButtonSize = 48;
  final Duration longPressInterval;

  final _inputManager = InputManager.instance;

  Controller(
      {Key key, @required this.longPressInterval, this.longPressSensitivity: 3})
      : assert(longPressInterval != null),
        super(key: key);

  @override
  build(BuildContext context) => Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: buildDirectionButtons(context),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: buildActionButtons(context),
          )
        ],
      );

  Widget buildDirectionButtons(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LongPressButton(
                sensitivity: longPressSensitivity,
                interval: longPressInterval,
                color: neutralBlackC,
                textColor: Colors.white,
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
                height: 24 * 1.618,
              ),
              buildCircleButton(
                context,
                onPressed: () {
                  _inputManager.enterButton(ButtonKey.a);
                },
                child: const Icon(Icons.file_download),
                size: defaultCircleButtonSize * 1.618,
              ),
            ],
          ),
          const VerticalDivider(
            width: 8,
            color: Colors.transparent,
          ),
          buildCircleButton(
            context,
            onPressed: () {
              _inputManager.enterButton(ButtonKey.b);
            },
            child: const Icon(Icons.rotate_left),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildCircleButton(context, onPressed: () {
                _inputManager.enterButton(ButtonKey.c);
              }, child: const Icon(Icons.rotate_right)),
              const Divider(
                height: 24 * 1.618,
              )
            ],
          )
        ],
      );

  Widget buildCircleButton(BuildContext context,
          {@required VoidCallback onPressed,
          @required Widget child,
          double size}) =>
      LongPressButton(
        sensitivity: longPressSensitivity,
        interval: longPressInterval,
        onPressed: onPressed,
        child: child,
        minWidth: size ?? defaultCircleButtonSize,
        height: size ?? defaultCircleButtonSize,
        color: roseViolet,
        textColor: Colors.white,
        shape: const CircleBorder(),
      );
}
