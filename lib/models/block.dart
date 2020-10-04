import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Block {
  Point<int> point;
  MaterialColor color;
  final bool isGhost;

  Block({@required this.color, this.point, this.isGhost: false})
      : assert(color != null);
}
