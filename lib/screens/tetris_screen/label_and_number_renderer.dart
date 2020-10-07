import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LabelAndNumberRenderer extends StatelessWidget {
  final String label;
  final Stream<int> numberStream;

  const LabelAndNumberRenderer(this.label, this.numberStream, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .subtitle2
                .copyWith(color: Colors.white)),
        StreamProvider<int>.value(
          value: numberStream,
          child: Consumer<int>(
            builder: (context, number, child) => Center(
              child: Text(
                "$number",
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: Colors.white),
              ),
            ),
          ),
        )
      ],
    );
  }
}
