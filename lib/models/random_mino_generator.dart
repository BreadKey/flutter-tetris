import 'dart:collection';
import 'dart:math';

import 'package:tetris/models/tetromino.dart';

class RandomMinoGenerator {
  final _bag = Queue<TetrominoName>();

  TetrominoName getNext() {
    if (_bag.isEmpty) {
      _bag.addAll(List.from(TetrominoName.values)
        ..sort((a, b) {
          return Random().nextInt(7);
        }));
    }

    return _bag.removeFirst();
  }
}
