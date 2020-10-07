import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/models/tetris.dart';

class BlockRenderer extends StatelessWidget {
  final Block block;

  const BlockRenderer(this.block, {Key key})
      : assert(block != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        elevation: block.isGhost ? 0 : 4 ,
        child: SizedBox.expand(
          child: CustomPaint(
            painter: _BlockPainter(block),
          ),
        ),
      );
}

class _BlockPainter extends CustomPainter {
  final Block block;
  Color lastColor;
  _BlockPainter(this.block) : lastColor = block.color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.height / 6;
    final paint = Paint()..strokeWidth = strokeWidth;

    final blockRect = Rect.fromLTWH(
        0, 0, size.width - strokeWidth / 2, size.height - strokeWidth / 2);

    canvas.drawRect(blockRect, paint..color = getBlockBackgroundColor());

    final shadowRect = blockRect;

    if (!block.isGhost) {
      // canvas.drawRect(blockRect, paint..style = PaintingStyle.stroke);
      final shadowPath = Path()
        ..moveTo(shadowRect.topLeft.dx, shadowRect.topLeft.dy)
        ..lineTo(shadowRect.topRight.dx, shadowRect.topRight.dy)
        ..lineTo(shadowRect.center.dx, shadowRect.center.dy);

      canvas.drawPath(
          shadowPath,
          paint
            ..color = block.color[200]
            ..style = PaintingStyle.fill);

      canvas.save();
      canvas.translate(blockRect.center.dx * 2, blockRect.center.dy * 2);
      canvas.rotate(pi);
      canvas.drawPath(shadowPath, paint..color = block.color[800]);
      canvas.restore();

      canvas.drawRect(
          Rect.fromCenter(
              center: blockRect.center,
              width: strokeWidth * 3,
              height: strokeWidth * 3),
          paint..color = block.color);
    }
  }

  Color getBlockBackgroundColor() {
    if (block.isGhost) {
      return block.color[300].withOpacity(0.3);
    } else {
      return block.color[600];
    }
  }

  @override
  bool shouldRepaint(covariant _BlockPainter oldDelegate) =>
      oldDelegate.lastColor != block.color;
}
