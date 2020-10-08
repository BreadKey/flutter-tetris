import 'package:flutter/material.dart';

class Metal extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final BoxShape shape;

  const Metal(
      {Key key,
      this.width,
      this.height,
      @required this.child,
      this.margin,
      this.padding,
      this.shape})
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
            Colors.grey[400],
            Colors.grey[500],
            Colors.grey[600],
            Colors.grey[700],
          ], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [
            BoxShadow(color: Colors.grey[800], blurRadius: 14),
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 8,
            ),
          ]),
      child: child);
}
