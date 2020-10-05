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
  2: 0.79300 / fps,
  3: 0.61780 / fps,
  4: 0.47273 / fps,
  5: 0.35520 / fps,
  6: 0.26200 / fps,
  7: 0.18968 / fps,
  8: 0.13473 / fps,
  9: 0.09388 / fps,
  10: 0.06415 / fps,
  11: 0.04298 / fps,
  12: 0.02822 / fps,
  13: 0.01815 / fps,
  14: 0.01144 / fps,
  15: 0.00706 / fps
};
