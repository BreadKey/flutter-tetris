part of '../tetris.dart';

const playfieldWidth = 10;
const playfieldHeight = 22;
const visibleHeight = 20;
const fps = 64;
const delayedAutoShiftHz = 20;

const tetriminoColors = {
  TetrominoName.iMino: Colors.cyan,
  TetrominoName.oMino: Colors.yellow,
  TetrominoName.tMino: Colors.purple,
  TetrominoName.sMino: Colors.green,
  TetrominoName.zMino: Colors.red,
  TetrominoName.jMino: Colors.blue,
  TetrominoName.lMino: Colors.orange
};

/*
 * Bottom Left Point is 0, 0 
 */
const spawnPoint = const Point<int>(4, 21);

const maxLevel = 15;

const gravities = {
  1: 1 / fps,
  2: 0.021017 * 60 / fps,
  3: 0.026977 * 60 / fps,
  4: 0.035256 * 60 / fps,
  5: 0.04693 * 60 / fps,
  6: 0.06361 * 60 / fps,
  7: 0.0879 * 60 / fps,
  8: 0.1236 * 60 / fps,
  9: 0.1775 * 60 / fps,
  10: 0.2598 * 60 / fps,
  11: 0.388 * 60 / fps,
  12: 0.59 * 60 / fps,
  13: 0.92 * 60 / fps,
  14: 1.46 * 60 / fps,
  15: 2.36 * 60 / fps
};
