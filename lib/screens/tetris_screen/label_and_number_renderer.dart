import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LabelAndNumberRenderer extends StatelessWidget {
  final String label;
  final Stream<int> numberStream;
  final Axis direction;

  const LabelAndNumberRenderer(this.label, this.numberStream, {Key key, this.direction = Axis.horizontal})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: direction,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("$label: ",
            style: Theme.of(context)
                .textTheme
                .subtitle2),
        StreamProvider<int>.value(
          value: numberStream,
          child: Consumer<int>(
            builder: (context, number, child) => Center(
              child: Text(
                "$number",
                style: Theme.of(context)
                    .textTheme
                    .subtitle1,
              ),
            ),
          ),
        )
      ],
    );
  }
}
