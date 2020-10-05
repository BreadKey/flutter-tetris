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
