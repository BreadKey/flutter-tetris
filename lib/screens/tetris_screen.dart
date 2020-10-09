import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:screen/screen.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/retro_colors.dart';
import 'package:tetris/screens/controller.dart';
import 'package:tetris/screens/metal.dart';
import 'package:tetris/screens/mino_renderder.dart';
import 'package:tetris/screens/playfield_renderer.dart';
import 'package:tetris/screens/tetris_screen/event_renderer.dart';
import 'package:tetris/screens/tetris_screen/hold_button.dart';
import 'package:tetris/screens/tetris_screen/mute_button.dart';
import 'package:tetris/screens/tetris_screen/scoreboard_renderer.dart';

class TetrisScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TetrisScreenState();
}

class _TetrisScreenState extends State<TetrisScreen>
    with SingleTickerProviderStateMixin {
  static const gameScreenRatio = 3 / 4;
  static const controllerHeight = 280;

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

    Screen.keepOn(true);
  }

  @override
  void dispose() {
    tetris.dispose();
    hardDropAnimController.dispose();
    tetrisEventSubscriber.cancel();

    Screen.keepOn(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final sizeOfScreen = mediaQuery.size;

    final height = min(
        min(sizeOfScreen.width, sizeOfScreen.height) / gameScreenRatio,
        sizeOfScreen.height -
            (mediaQuery.orientation == Orientation.portrait
                ? controllerHeight
                : 40));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
            Colors.white,
            antiqueWhite,
            antiqueWhite,
            Color(0xFFccc0af)
          ])),
      child: Stack(
        children: [
          Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Metal(
                      width: height * gameScreenRatio,
                      height: height,
                      margin: EdgeInsets.symmetric(horizontal: 14),
                      padding: EdgeInsets.only(left: 24, right: 24, bottom: 24),
                      child: SafeArea(
                          child: Column(
                        children: [
                          Expanded(
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
                                    child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    MinoRenderer(tetris.nextMinoStream,
                                        info: "Next"),
                                    const Divider(
                                      color: Colors.transparent,
                                    ),
                                    MinoRenderer(tetris.holdingMinoStream,
                                        info: "Hold"),
                                    const Divider(
                                      color: Colors.transparent,
                                    ),
                                    EventRenderer(tetris),
                                    const Divider(color: Colors.transparent),
                                    Expanded(
                                      child: Material(
                                        color: neutralBlackC,
                                        elevation: 4,
                                        child: const SizedBox.expand(),
                                      ),
                                    )
                                  ],
                                )),
                              ],
                            ),
                          ),
                          const Divider(),
                          ScoreboardRenderer(tetris)
                        ],
                      )),
                    ),
                  ),
                  buildSpecialButtons(context)
                ],
              )),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: controllerHeight - MediaQuery.of(context).padding.bottom,
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

  Widget buildSpecialButtons(BuildContext context) => Theme(
        data: Theme.of(context).copyWith(
          iconTheme: IconThemeData(color: Colors.grey),
          buttonColor: roseViolet,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: Align(
              alignment: Alignment.centerRight,
              child: MuteButton(),
            )),
            Expanded(
                child: Align(
              alignment: Alignment.centerLeft,
              child: HoldButton(tetris),
            ))
          ],
        ),
      );
}
