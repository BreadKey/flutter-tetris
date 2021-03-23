part of '../tetris.dart';

const playfieldWidth = 10;
const playfieldHeight = 22;
const visibleHeight = 20;
const fps = 64;
const delayedAutoShiftHz = 20;

const tetriminoColors = {
  TetrominoName.I: Colors.cyan,
  TetrominoName.O: Colors.yellow,
  TetrominoName.T: Colors.purple,
  TetrominoName.S: Colors.green,
  TetrominoName.Z: Colors.red,
  TetrominoName.J: Colors.blue,
  TetrominoName.L: Colors.orange
};

/*
 * Bottom Left Point is 0, 0 
 */
const spawnPoint = const Point<int>(4, 21);

const maxLevel = 15;

const gravitiesPerFrame = [
  1 / fps,
  (0.021017 * 60) / fps,
  (0.026977 * 60) / fps,
  (0.035256 * 60) / fps,
  (0.04693 * 60) / fps,
  (0.06361 * 60) / fps,
  (0.0879 * 60) / fps,
  (0.1236 * 60) / fps,
  (0.1775 * 60) / fps,
  (0.2598 * 60) / fps,
  (0.388 * 60) / fps,
  (0.59 * 60) / fps,
  (0.92 * 60) / fps,
  (1.46 * 60) / fps,
  (2.36 * 60) / fps
];

const hardDropGravityPerFrame = (20 * 60) / fps;

const linesCountToLevelUp = 10;
