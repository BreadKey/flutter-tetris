import 'package:flutter/material.dart';

class Metal extends StatelessWidget {
  static const spreadWidth = 8.0;
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final BoxShape? shape;
  final MaterialColor color;

  const Metal(
      {Key? key,
      this.width,
      this.height,
      required this.child,
      this.margin,
      this.padding,
      this.shape,
      this.color = Colors.grey})
      : super(key: key);
  @override
  Widget build(BuildContext context) => Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
          shape: shape ?? BoxShape.rectangle,
          borderRadius: shape != null
              ? null
              : BorderRadius.vertical(
                  top: Radius.circular(24), bottom: Radius.circular(38)),
          gradient: LinearGradient(colors: [
            color.shade400,
            color.shade500,
            color.shade600,
            color.shade700,
          ], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [
            BoxShadow(color: color.shade800, blurRadius: 14),
            BoxShadow(
              color: color,
              spreadRadius: spreadWidth,
            ),
          ]),
      child: child);
}
