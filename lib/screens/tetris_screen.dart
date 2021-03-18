import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen/screen.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/retro_colors.dart';
import 'package:tetris/screens/controller.dart';
import 'package:tetris/screens/metal.dart';
import 'package:tetris/screens/playfield_renderer.dart';
import 'package:tetris/screens/tetris_screen/event_board.dart';
import 'package:tetris/screens/tetris_screen/hold_board.dart';
import 'package:tetris/screens/tetris_screen/logo.dart';
import 'package:tetris/screens/tetris_screen/next_tetromino_board.dart';
import 'package:tetris/screens/tetris_screen/rank_board.dart';
import 'package:tetris/screens/tetris_screen/scoreboard.dart';

class TetrisScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TetrisScreenState();
}

class _TetrisScreenState extends State<TetrisScreen>
    with SingleTickerProviderStateMixin {
  static const controllerHeight = 280;
  static const dividerSize = 6.0;
  static const logoHeight = 28.0;

  Tetris tetris;

  AnimationController hardDropAnimController;
  Animation<Offset> fastDropAnimation;

  StreamSubscription tetrisEventSubscriber;

  @override
  void initState() {
    super.initState();
    tetris = Tetris();

    tetris.startGame();

    hardDropAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));

    fastDropAnimation = Tween(begin: Offset(0, 0), end: Offset(0, 0.01))
        .animate(CurvedAnimation(
            parent: hardDropAnimController, curve: Curves.bounceOut));

    hardDropAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        hardDropAnimController.reverse();
      }
    });

    tetrisEventSubscriber = tetris.eventStream.listen((event) {
      if (event == TetrisEvent.hardDrop || event == TetrisEvent.softDrop) {
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
    final sizeOfScreen = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: ChangeNotifierProvider.value(
          value: tetris,
          child: WillPopScope(
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                      navyBlue.shade400,
                      navyBlue.shade500,
                      navyBlue.shade600,
                      navyBlue.shade700
                    ])),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Metal(
                        color: neutralBlackC,
                        width:
                            sizeOfScreen.height - kToolbarHeight - logoHeight,
                        margin: EdgeInsets.symmetric(horizontal: 14),
                        padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                        child: SafeArea(
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
                                    child: PlayfieldRenderer(tetris),
                                  ),
                                  const VerticalDivider(
                                      color: Colors.transparent,
                                      width: dividerSize),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: NextTetrominoBoard(tetris),
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
                            const Logo(
                              height: logoHeight,
                            )
                          ],
                        )),
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: controllerHeight -
                              MediaQuery.of(context).padding.bottom,
                          child: Controller(
                              longPressDelay: const Duration(milliseconds: 200),
                              longPressInterval: const Duration(
                                  milliseconds: 1000 ~/ delayedAutoShiftHz)),
                        ))
                  ],
                ),
              ),
              onWillPop: () async {
                dispose();
                return true;
              }),
        ));
  }
}
