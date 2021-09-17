import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:tetris/dao/rank_dao.dart';
import 'package:tetris/models/audio_manager.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/tetris.dart';

import 'mocks/mock_audio_manager.dart';
import 'mocks/mock_rank_dao.dart';
import 'tetromino_test.dart';

void main() {
  late Tetris tetris;
  Injector.appInstance
      .registerSingleton<IAudioManager>(() => MockAudioManager());
  Injector.appInstance.registerSingleton<RankDao>(() => MockRankDao());

  setUp(() {
    tetris = Tetris();
    tetris.initPlayfield();
  });

  tearDown(() {
    tetris.dispose();
  });
  test("spawn I mino", () {
    tetris.spawn(TetrominoName.I);
    expectIMinoSpawned(tetris);
  });

  test("spawn T mino", () {
    tetris.spawn(TetrominoName.T);

    expectPoints(tetris.currentTetromino!,
        [Point(3, 19), Point(4, 19), Point(5, 19), Point(4, 20)]);
  });

  test("point equals", () {
    expect(Point(1, 2), Point(1, 2));
  });

  test("can move", () {
    tetris.spawn(TetrominoName.I);

    expect(
        tetris.canMove(tetris.currentTetromino!,
            tetris.playfield as List<List<Block?>>, Direction.down),
        true);

    tetris.moveCurrentMino(Direction.down);

    tetris.spawn(TetrominoName.I);

    expect(
        tetris.canMove(tetris.currentTetromino!,
            tetris.playfield as List<List<Block?>>, Direction.down),
        false);
  });

  test("super rotation system", () {
    final dynamic mino = null; //just more readable;
    final grey = Block(color: Colors.grey);
    final playfield = [
      <Block?>[null, null, null, null, grey, grey, null, null, null, null],
      <Block?>[null, null, null, null, null, grey, grey, grey, null, null],
      <Block?>[null, null, null, null, mino, null, grey, grey, grey, grey],
      <Block?>[null, grey, grey, grey, mino, mino, mino, grey, grey, grey],
      <Block?>[grey, grey, null, null, null, null, grey, grey, grey, grey],
      <Block?>[grey, grey, grey, grey, null, null, grey, grey, grey, grey],
      <Block?>[grey, grey, grey, grey, grey, null, grey, grey, grey, grey],
    ].reversed.toList();

    final jMino = Tetromino.spawn(TetrominoName.J, Point(5, 3));

    tetris.rotateBySrs(jMino, playfield, clockwise: false);

    expectPoints(jMino, [Point(4, 1), Point(5, 1), Point(5, 2), Point(5, 3)]);
  });

  test("kick T test", () {
    final List<List<Block?>> playfield = [
      [null, null, null, null],
      [null, null, null, null],
      [null, null, null, null]
    ];

    final tMino = Tetromino.spawn(TetrominoName.T, Point(1, 2));

    tetris.rotateBySrs(tMino, playfield);
    expectPoints(tMino, [Point(1, 0), Point(1, 1), Point(1, 2), Point(2, 1)]);

    tetris.move(tMino, playfield, Direction.left);

    tetris.rotateBySrs(tMino, playfield);
    expectPoints(tMino, [Point(0, 1), Point(1, 1), Point(2, 1), Point(1, 0)]);

    tetris.rotateBySrs(tMino, playfield, clockwise: false);
    expectPoints(tMino, [Point(1, 0), Point(1, 1), Point(1, 2), Point(2, 1)]);

    tetris.move(tMino, playfield, Direction.left);

    tetris.rotateBySrs(tMino, playfield, clockwise: false);

    expectPoints(tMino, [Point(0, 1), Point(1, 1), Point(2, 1), Point(1, 2)]);

    tetris.rotateBySrs(tMino, playfield, clockwise: false);

    tetris.move(tMino, playfield, Direction.right);
    tetris.move(tMino, playfield, Direction.right);

    tetris.rotateBySrs(tMino, playfield);
    expectPoints(tMino, [Point(1, 1), Point(2, 1), Point(3, 1), Point(2, 2)]);
  });

  test("T spin test", () {
    final grey = Block(color: Colors.grey);
    final List<List<Block?>> playfield = [
      [null, null, grey, grey],
      [null, null, grey, grey],
      [null, null, null, grey],
      [grey, grey, null, grey],
      [grey, null, null, grey],
      [grey, grey, null, grey]
    ].reversed.toList();

    final tMino = Tetromino.spawn(TetrominoName.T, Point(1, 4));

    tetris.rotateBySrs(tMino, playfield, clockwise: false);

    expectPoints(tMino, [Point(1, 1), Point(2, 2), Point(2, 1), Point(2, 0)]);
  });

  test("hold test", () {
    tetris.spawn(TetrominoName.T);
    tetris.addMinoToBag(TetrominoName.I);
    tetris.moveCurrentMino(Direction.down);
    tetris.moveCurrentMino(Direction.down);

    final lastBlocks = tetris.currentTetromino!.blocks;

    tetris.hold();
    expect(tetris.currentTetromino!.name, TetrominoName.I);
    expect(tetris.holdingMino, TetrominoName.T);

    tetris.playfield.forEach((line) {
      lastBlocks.forEach((block) {
        expect(line.contains(block), false);
      });
    });

    expectIMinoSpawned(tetris);
  });
}

void expectIMinoSpawned(Tetris tetris) {
  expectPoints(tetris.currentTetromino!,
      [Point(3, 19), Point(4, 19), Point(5, 19), Point(6, 19)]);
}
