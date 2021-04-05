library controller;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/screens/controller/joystick.dart';

import 'long_press_button.dart';

part 'controller/action_button.dart';
part 'controller/special_button.dart';

enum ButtonKey {
  a, b, c, special1, special2
}

class Controller extends InheritedWidget {
  static const double actionButtonSpace = 14 * 1.518;
  static const double defaultCircleButtonSize = 52;

  final Duration longPressDelay;
  final Duration longPressInterval;

  final MaterialColor actionButtonColor;
  final double actionButtonSize;
  final Color specialButtonColor;

  final Map<ButtonKey, Widget> buttonIcons;

  final Function(ButtonKey buttonKey) onButtonEntered;

  Controller({
    Key key,
    @required this.longPressDelay,
    @required this.longPressInterval,
    @required Function(JoystickDirection direction) onDirectionEntered,
    @required this.onButtonEntered,
    this.buttonIcons = const {},
    this.actionButtonColor,
    this.actionButtonSize = defaultCircleButtonSize,
    this.specialButtonColor,
  })  : assert(longPressDelay != null),
        assert(longPressInterval != null),
        super(
            key: key,
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Joystick(
                          holdDelay: longPressDelay,
                          holdInterval: longPressInterval,
                          onDirectionEntered: onDirectionEntered),
                    ),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Transform.translate(
                          offset: Offset(0, actionButtonSpace / 2),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildSpecialButtons(),
                              _buildActionButtons()
                            ],
                          ),
                        ))
                  ],
                )));

  static Widget _buildSpecialButtons() => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Transform.translate(
            offset: Offset(0, actionButtonSpace / 2),
            child: _SpecialButton(
              buttonKey: ButtonKey.special1,
            ),
          ),
          _SpecialButton(
            buttonKey: ButtonKey.special2,
          ),
          const VerticalDivider(
            color: Colors.transparent,
            width: actionButtonSpace,
          )
        ],
      );
  static Widget _buildActionButtons() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                buttonKey: ButtonKey.a,
              )
            ],
          ),
          const VerticalDivider(
            width: 8,
            color: Colors.transparent,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                buttonKey: ButtonKey.b,
              ),
              const Divider(
                height: actionButtonSpace * 2,
              ),
            ],
          ),
          const VerticalDivider(
            width: 8,
            color: Colors.transparent,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                buttonKey: ButtonKey.c,
              ),
              const Divider(
                height: actionButtonSpace * 4,
              ),
            ],
          ),
        ],
      );

  factory Controller.of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Controller>();

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
