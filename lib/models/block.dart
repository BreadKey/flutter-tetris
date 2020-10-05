import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tetris/models/tetromino.dart';

class Block {
  Point<int> point;
  MaterialColor color;
  final bool isGhost;

  Block({@required this.color, this.point, this.isGhost: false})
      : assert(color != null);

  bool isPartOf(Tetromino tetromino) => tetromino.blocks.contains(this);
}
