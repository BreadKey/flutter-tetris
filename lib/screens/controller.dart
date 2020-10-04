import 'package:flutter/material.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/retro_colors.dart';
import 'package:tetris/screens/long_press_button.dart';

class Controller extends StatelessWidget {
  final Tetris tetris;
  final int longPressSensitivity;
  final double defaultCircleButtonSize = 48;

  const Controller(
      {Key key, @required this.tetris, this.longPressSensitivity: 3})
      : assert(tetris != null),
        super(key: key);

  @override
  build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildDirectionButtons(context),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(),
                  buildCircleButton(
                    context,
                    onPressed: () {
                      tetris.dropHard();
                    },
                    child: const Icon(Icons.vertical_align_bottom),
                    size: defaultCircleButtonSize * 1.618,
                  ),
                ],
              ),
              buildCircleButton(
                context,
                onPressed: () {
                  tetris.commandRotate(clockwise: false);
                },
                child: const Icon(Icons.rotate_left),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildCircleButton(context, onPressed: () {
                    tetris.commandRotate();
                  }, child: const Icon(Icons.rotate_right)),
                  const Divider()
                ],
              )
            ],
          ),
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
                color: neutralBlackC,
                textColor: Colors.white,
                child: const Icon(Icons.arrow_left),
                onPressed: () {
                  tetris.move(Direction.left);
                },
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(24), right: Radius.circular(8))),
              ),
              LongPressButton(
                sensitivity: longPressSensitivity,
                color: neutralBlackC,
                textColor: Colors.white,
                child: const Icon(Icons.arrow_right),
                onPressed: () {
                  tetris.commandMove(Direction.right);
                },
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(24), left: Radius.circular(8))),
              ),
            ],
          ),
          LongPressButton(
            sensitivity: longPressSensitivity,
            onPressed: () {
              tetris.commandMove(Direction.down);
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

  Widget buildCircleButton(BuildContext context,
          {@required VoidCallback onPressed,
          @required Widget child,
          double size}) =>
      LongPressButton(
        sensitivity: longPressSensitivity,
        onPressed: onPressed,
        child: child,
        minWidth: size ?? defaultCircleButtonSize,
        height: size ?? defaultCircleButtonSize,
        color: roseViolet,
        textColor: Colors.white,
        shape: const CircleBorder(),
      );
}
