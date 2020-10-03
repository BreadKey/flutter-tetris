import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/models/tetromino.dart';

const width = 10;
const height = 22;

const tetrminoClors = {
  Tetromino.iMino: Colors.cyan,
  Tetromino.oMino: Colors.yellow,
  Tetromino.tMino: Colors.purple,
  Tetromino.sMino: Colors.green,
  Tetromino.zMino: Colors.red,
  Tetromino.jMino: Colors.blue,
  Tetromino.lMino: Colors.orange
};

/*
 * Bottom Left Point is 0, 0 
 */
const spawnPoint = const Point<int>(4, 20);
