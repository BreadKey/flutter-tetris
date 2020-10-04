import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Block {
  Point<int> point;
  final Color color;

  Block({@required this.color, this.point}) : assert(color != null);
}
