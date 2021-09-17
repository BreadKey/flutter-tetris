import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/models/tetris.dart';

class LabelAndNumberRenderer extends StatelessWidget {
  final String label;
  final int Function(Tetris tetris) numberSelector;
  final Axis direction;

  const LabelAndNumberRenderer(this.label, this.numberSelector,
      {Key? key, this.direction = Axis.horizontal})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: direction,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("$label: ", style: Theme.of(context).textTheme.subtitle2),
        Selector<Tetris, int>(
          selector: (_, tetris) => numberSelector(tetris),
          builder: (context, number, child) => Center(
            child: Text(
              "$number",
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        )
      ],
    );
  }
}
