part of tetris;

const kPlayfieldWidth = 10;
const kPlayfieldHeight = 22;
const kVisibleHeight = 20;
const kFps = 64;
const kDelayedAutoShiftHz = 20;

const kTetriminoColors = {
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
const kSpawnPoint = const Point<int>(4, 21);

const kMaxLevel = 15;

const kGravitiesPerFrame = [
  1 / kFps,
  (0.021017 * 60) / kFps,
  (0.026977 * 60) / kFps,
  (0.035256 * 60) / kFps,
  (0.04693 * 60) / kFps,
  (0.06361 * 60) / kFps,
  (0.0879 * 60) / kFps,
  (0.1236 * 60) / kFps,
  (0.1775 * 60) / kFps,
  (0.2598 * 60) / kFps,
  (0.388 * 60) / kFps,
  (0.59 * 60) / kFps,
  (0.92 * 60) / kFps,
  (1.46 * 60) / kFps,
  (2.36 * 60) / kFps
];

const kHardDropGravityPerFrame = (20 * 60) / kFps;

const kLinesCountToLevelUp = 10;
