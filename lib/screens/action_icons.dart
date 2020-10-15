import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/retro_colors.dart';
import 'package:tetris/screens/tetris_screen/block_renderer.dart';

class RotateIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool clockwise;

  const RotateIcon({Key key, double size, this.color, bool clockwise})
      : this.size = size ?? 24,
        this.clockwise = clockwise ?? true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final iconOpacity = iconTheme.opacity;
    Color iconColor = color ?? iconTheme.color;

    if (iconOpacity != 1.0)
      iconColor = iconColor.withOpacity(iconColor.opacity * iconOpacity);

    final space = SizedBox(
      width: size / 3,
      height: size / 3,
    );

    final block = Container(
        width: size / 3,
        height: size / 3,
        child: BlockRenderer(
          Block(color: justWhite),
          drawShadow: false,
        ));

    final effectLong = Container(
      width: size / 3,
      height: size / 3,
      child: Container(
        margin: EdgeInsets.only(
            top: size / 12, bottom: size / 12, right: size / 12),
        color: iconColor,
      ),
    );
    final effectMiddle = Container(
      width: size / 3,
      height: size / 3,
      child: Container(
        margin: EdgeInsets.only(
            top: size / 12,
            bottom: size / 12,
            right: size / 12,
            left: size / 12),
        color: iconColor,
      ),
    );
    final effectShort = Container(
      width: size / 3,
      height: size / 3,
      child: Container(
        margin: EdgeInsets.only(
            top: size / 12,
            bottom: size / 12,
            right: size / 12,
            left: size / 6),
        color: iconColor,
      ),
    );

    return Transform.rotate(
      angle: clockwise ? 0 : pi,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
              mainAxisSize: MainAxisSize.min,
              children: [clockwise ? effectLong : effectShort, block, space]),
          Row(
              mainAxisSize: MainAxisSize.min,
              children: [effectMiddle, block, block]),
          Row(
              mainAxisSize: MainAxisSize.min,
              children: [clockwise ? effectShort : effectLong, block, space])
        ],
      ),
    );
  }
}

class HardDropIcon extends StatelessWidget {
  final double size;
  final Color color;

  const HardDropIcon({Key key, double size, this.color, bool clockwise})
      : this.size = size ?? 24,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final iconOpacity = iconTheme.opacity;
    Color iconColor = color ?? iconTheme.color;

    if (iconOpacity != 1.0)
      iconColor = iconColor.withOpacity(iconColor.opacity * iconOpacity);

    final block = Container(
        width: size / 3,
        height: size / 3,
        child: BlockRenderer(
          Block(color: justWhite),
          drawShadow: false,
        ));

    final effectTop = Container(
      width: size / 3,
      height: size / 3,
      child: Container(
        margin: EdgeInsets.only(
            left: size / 12, right: size / 12, bottom: size / 6),
        color: iconColor,
      ),
    );

    final effectBottom = Container(
      width: size / 3,
      height: size / 3,
      child: Container(
        margin:
            EdgeInsets.only(left: size / 12, right: size / 12, top: size / 6),
        color: iconColor,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
            mainAxisSize: MainAxisSize.min,
            children: [effectBottom, effectTop, effectBottom]),
        Row(
            mainAxisSize: MainAxisSize.min,
            children: [effectTop, block, effectTop]),
        Row(mainAxisSize: MainAxisSize.min, children: [block, block, block])
      ],
    );
  }
}
