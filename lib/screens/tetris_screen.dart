import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/retro_colors.dart';
import 'package:tetris/screens/controller.dart';
import 'package:tetris/screens/next_mino_renderder.dart';
import 'package:tetris/screens/playfield_renderer.dart';
import 'package:tetris/screens/tetris_screen/label_and_number_renderer.dart';

class TetrisScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TetrisScreenState();
}

class _TetrisScreenState extends State<TetrisScreen>
    with SingleTickerProviderStateMixin {
  static const gameScreenRatio = 4 / 5;
  Tetris tetris;

  AnimationController hardDropAnimController;
  Animation<Offset> hardDropAnimation;

  StreamSubscription tetrisEventSubscriber;

  @override
  void initState() {
    super.initState();
    tetris = Tetris();

    tetris.startGame();

    hardDropAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));

    hardDropAnimation = Tween(begin: Offset(0, 0), end: Offset(0, 0.01))
        .animate(CurvedAnimation(
            parent: hardDropAnimController, curve: Curves.bounceOut));

    hardDropAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        hardDropAnimController.reverse();
      }
    });

    tetrisEventSubscriber = tetris.eventStream.listen((event) {
      if (event == TetrisEvent.hardDrop) {
        hardDropAnimController.forward();
      }
    });
  }

  @override
  void dispose() {
    tetris.dispose();
    hardDropAnimController.dispose();
    tetrisEventSubscriber.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizeOfScreen = MediaQuery.of(context).size;

    final height = min(
            min(sizeOfScreen.width, sizeOfScreen.height) / gameScreenRatio,
            sizeOfScreen.height) -
        30;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: antiqueWhite,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: height * gameScreenRatio,
              height: height,
              margin: EdgeInsets.symmetric(horizontal: 14),
              padding: EdgeInsets.only(left: 24, right: 24, bottom: 38),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24), bottom: Radius.circular(38)),
                  gradient: LinearGradient(colors: [
                    Colors.grey[400],
                    Colors.grey[500],
                    Colors.grey[600],
                    Colors.grey[700],
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: [
                    BoxShadow(color: Colors.grey[800], blurRadius: 14),
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 8,
                    ),
                  ]),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SlideTransition(
                    position: hardDropAnimation,
                    child: PlayfieldRenderer(tetris),
                  ),
                  const VerticalDivider(
                    color: Colors.transparent,
                  ),
                  Expanded(
                    child: SafeArea(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NextMinoRenderer(tetris),
                        const Divider(
                          color: Colors.transparent,
                        ),
                        LabelAndNumberRenderer("Level", tetris.levelStream),
                        const Divider(
                          color: Colors.transparent,
                        ),
                        LabelAndNumberRenderer("Score", tetris.scoreStream),
                        const Divider(
                          color: Colors.transparent,
                        ),
                        Expanded(
                          child: Material(
                            color: neutralBlackC,
                            elevation: 4,
                            child: const SizedBox.expand(),
                          ),
                        )
                      ],
                    )),
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 220 - MediaQuery.of(context).padding.bottom,
              child: Controller(
                longPressInterval:
                    const Duration(milliseconds: 1000 ~/ delayedAutoShiftHz),
              ),
            ),
          )
        ],
      ),
    );
  }
}
