import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/retro_colors.dart';

class LabelAndNumberRenderer extends StatelessWidget {
  final String label;
  final Stream<int> numberStream;

  const LabelAndNumberRenderer(this.label, this.numberStream, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 5 / 4,
      child: Material(
          color: neutralBlackC,
          elevation: 4,
          child: Column(
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
          )),
    );
  }
}
