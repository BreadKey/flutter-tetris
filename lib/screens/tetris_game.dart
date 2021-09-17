import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/retro_colors.dart';
import 'package:tetris/screens/controller.dart';
import 'package:tetris/screens/tetris_screen.dart';

import 'action_icons.dart';
import 'controller/joystick.dart';
import 'metal.dart';
import 'logo.dart';

class TetrisGame extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const controllerHeight = 280;
  static const logoHeight = 28.0;

  Tetris? tetris;

  @override
  void initState() {
    super.initState();
    tetris = Tetris();

    tetris!.startGame();

    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    tetris!.dispose();
    WidgetsBinding.instance!.removeObserver(this);
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
        body: Container(
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
            child: ChangeNotifierProvider.value(
              value: tetris,
              child: WillPopScope(
                  child: Stack(
                    children: [
                      Align(
                          alignment: Alignment.topCenter,
                          child: Metal(
                            color: neutralBlackC,
                            width: sizeOfScreen.height -
                                kToolbarHeight -
                                logoHeight,
                            margin: EdgeInsets.symmetric(horizontal: 14),
                            padding:
                                EdgeInsets.only(left: 8, right: 8, bottom: 8),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TetrisScreen(),
                                  const Logo(
                                    height: logoHeight,
                                  )
                                ]),
                          )),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: controllerHeight -
                                MediaQuery.of(context).padding.bottom,
                            child: Controller(
                              longPressDelay: const Duration(milliseconds: 200),
                              longPressInterval: const Duration(
                                  milliseconds: 1000 ~/ delayedAutoShiftHz),
                              buttonIcons: {
                                ButtonKey.a: const RotateIcon(
                                  clockwise: false,
                                ),
                                ButtonKey.b: const HardDropIcon(),
                                ButtonKey.c: const RotateIcon(),
                                ButtonKey.special1: Selector<Tetris, bool>(
                                  selector: (_, tetris) => tetris.isMuted,
                                  builder: (_, isMuted, __) => isMuted
                                      ? const Icon(Icons.volume_up,
                                          color: Colors.white54)
                                      : const Icon(
                                          Icons.volume_off,
                                          color: Colors.white54,
                                        ),
                                ),
                                ButtonKey.special2: Text(
                                  "Hold",
                                  style: TextStyle(color: Colors.white54),
                                )
                              },
                              actionButtonColor: bitOfBlue,
                              specialButtonColor: bitOfBlue,
                              onButtonEntered: onButtonEntered,
                              onDirectionEntered: onDirectionEntered,
                            ),
                          ))
                    ],
                  ),
                  onWillPop: () async {
                    dispose();
                    return true;
                  }),
            )));
  }

  void onDirectionEntered(JoystickDirection direction) {
    switch (direction) {
      case JoystickDirection.bottomLeft:
      case JoystickDirection.centerLeft:
      case JoystickDirection.topLeft:
        handleDirection(Direction.left);
        break;
      default:
        break;
    }
    switch (direction) {
      case JoystickDirection.topLeft:
      case JoystickDirection.topCenter:
      case JoystickDirection.topRight:
        handleDirection(Direction.up);
        break;
      default:
        break;
    }
    switch (direction) {
      case JoystickDirection.topRight:
      case JoystickDirection.centerRight:
      case JoystickDirection.bottomRight:
        handleDirection(Direction.right);
        break;
      default:
        break;
    }
    switch (direction) {
      case JoystickDirection.bottomRight:
      case JoystickDirection.bottomCenter:
      case JoystickDirection.bottomLeft:
        handleDirection(Direction.down);
        break;
      default:
        break;
    }
  }

  void handleDirection(Direction direction) {
    if (tetris!.isGameOver) return;
    if (direction == Direction.up) {
      tetris!.commandRotate();
    } else {
      tetris!.commandMove(direction);
    }
  }

  void onButtonEntered(ButtonKey key) {
    if (tetris!.isGameOver) {
      tetris!.startGame();
      return;
    }

    switch (key) {
      case ButtonKey.a:
        tetris!.commandRotate(clockwise: false);
        break;
      case ButtonKey.b:
        tetris!.dropHard();
        break;
      case ButtonKey.c:
        tetris!.commandRotate();
        break;
      case ButtonKey.special1:
        tetris!.toggleMute();
        break;
      case ButtonKey.special2:
        tetris!.hold();
        break;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      tetris!.pause();
    } else if (state == AppLifecycleState.resumed) {
      tetris!.resume();
    }
  }
}
