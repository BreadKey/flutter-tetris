import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/retro_colors.dart';
import 'package:tetris/screens/controller.dart';
import 'package:tetris/screens/tetris_screen.dart';

import 'action_icons.dart';
import 'controller/joystick.dart';
import 'logo.dart';
import 'metal.dart';

class TetrisGame extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const controllerHeight = 280.0;
  static const logoHeight = 28.0;

  late final Tetris tetris;

  late final FocusNode keyNode;

  @override
  void initState() {
    super.initState();
    tetris = Tetris();

    tetris.ready();

    keyNode = FocusNode();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    tetris.dispose();
    keyNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizeOfScreen = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: KeyboardListener(
          onKeyEvent: (value) {
            if (value is KeyDownEvent || value is KeyRepeatEvent) {
              _onKeyEntered(value.logicalKey);
            }
          },
          autofocus: true,
          focusNode: keyNode,
          child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                    RetroColors.navyBlue.shade400,
                    RetroColors.navyBlue.shade500,
                    RetroColors.navyBlue.shade600,
                    RetroColors.navyBlue.shade700
                  ])),
              child: ChangeNotifierProvider.value(
                value: tetris,
                child: Stack(
                  children: [
                    Align(
                        alignment: Alignment.topCenter,
                        child: Metal(
                          color: RetroColors.neutralBlackC,
                          width: min(sizeOfScreen.width,
                              sizeOfScreen.height * (1 - 0.1618)),
                          margin: EdgeInsets.symmetric(horizontal: 14),
                          padding:
                              EdgeInsets.only(left: 8, right: 8, bottom: 8),
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            TetrisScreen(),
                            const Logo(
                              height: logoHeight,
                            )
                          ]),
                        )),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          height: controllerHeight,
                          child: Controller(
                            longPressDelay: const Duration(milliseconds: 200),
                            longPressInterval: const Duration(
                                milliseconds: 1000 ~/ kDelayedAutoShiftHz),
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
                            actionButtonColor: RetroColors.bitOfBlue,
                            specialButtonColor: RetroColors.bitOfBlue,
                            onButtonEntered: onButtonEntered,
                            onDirectionEntered: onDirectionEntered,
                          ),
                        ))
                  ],
                ),
              )),
        ));
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
    if (tetris.isGameOver) return;
    if (direction == Direction.up) {
      tetris.commandRotate();
    } else {
      tetris.commandMove(direction);
    }
  }

  void onButtonEntered(ButtonKey key) {
    if (tetris.isGameOver) {
      tetris.startGame();
      return;
    }

    switch (key) {
      case ButtonKey.a:
        tetris.commandRotate(clockwise: false);
        break;
      case ButtonKey.b:
        tetris.dropHard();
        break;
      case ButtonKey.c:
        tetris.commandRotate();
        break;
      case ButtonKey.special1:
        tetris.toggleMute();
        break;
      case ButtonKey.special2:
        tetris.hold();
        break;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      tetris.pause();
    } else if (state == AppLifecycleState.resumed) {
      tetris.resume();
    }
  }

  void _onKeyEntered(LogicalKeyboardKey key) {
    switch (key) {
      case LogicalKeyboardKey.arrowLeft:
        return handleDirection(Direction.left);
      case LogicalKeyboardKey.arrowRight:
        return handleDirection(Direction.right);
      case LogicalKeyboardKey.arrowDown:
        return handleDirection(Direction.down);
      case LogicalKeyboardKey.arrowUp:
        return handleDirection(Direction.up);
      case LogicalKeyboardKey.keyX:
        return onButtonEntered(ButtonKey.c);
      case LogicalKeyboardKey.keyZ:
        return onButtonEntered(ButtonKey.a);
      case LogicalKeyboardKey.space:
        return onButtonEntered(ButtonKey.b);
      case LogicalKeyboardKey.keyC:
        return onButtonEntered(ButtonKey.special2);
    }
  }
}
