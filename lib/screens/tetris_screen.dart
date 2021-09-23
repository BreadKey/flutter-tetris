import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/models/tetris.dart';

import 'tetris_screen/event_board.dart';
import 'tetris_screen/hold_board.dart';
import 'tetris_screen/next_tetromino_board.dart';
import 'tetris_screen/playfield_renderer.dart';
import 'tetris_screen/rank_board.dart';
import 'tetris_screen/scoreboard.dart';

class TetrisScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TetrisScreenState();
}

class _TetrisScreenState extends State<TetrisScreen>
    with SingleTickerProviderStateMixin {
  static const dividerSize = 6.0;

  late AnimationController fastDropAnimController;
  late Animation<Offset> fastDropAnimation;

  late StreamSubscription tetrisEventSubscriber;

  late Tetris tetris;

  @override
  void initState() {
    super.initState();

    tetris = context.read<Tetris>();

    _initAnimations();
  }

  void _initAnimations() {
    fastDropAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));

    fastDropAnimation = Tween(begin: Offset(0, 0), end: Offset(0, 0.01))
        .animate(CurvedAnimation(
            parent: fastDropAnimController, curve: Curves.bounceOut));

    fastDropAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        fastDropAnimController.reverse();
      }
    });

    tetrisEventSubscriber = tetris.eventStream.listen((event) {
      if (event == TetrisEvent.hardDrop || event == TetrisEvent.softDrop) {
        fastDropAnimController.forward();
      }
    });
  }

  @override
  void dispose() {
    fastDropAnimController.dispose();
    tetrisEventSubscriber.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Row(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    HoldBoard(tetris),
                    const Divider(
                      color: Colors.transparent,
                      height: dividerSize,
                    ),
                    EventBoard(tetris),
                    const Divider(
                      color: Colors.transparent,
                      height: dividerSize,
                    ),
                    Expanded(child: RankBoard(tetris))
                  ],
                )),
                const VerticalDivider(
                  color: Colors.transparent,
                  width: dividerSize,
                ),
                SlideTransition(
                  position: fastDropAnimation,
                  child: const PlayfieldRenderer(),
                ),
                const VerticalDivider(
                    color: Colors.transparent, width: dividerSize),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: const NextTetrominoBoard(),
                    ),
                    const Divider(
                      color: Colors.transparent,
                    )
                  ],
                )),
              ],
            ),
          ),
          const Divider(
            color: Colors.transparent,
            height: dividerSize,
          ),
          Scoreboard(tetris),
          const Divider(
            color: Colors.transparent,
            height: dividerSize,
          ),
        ],
      ),
    );
  }
}
