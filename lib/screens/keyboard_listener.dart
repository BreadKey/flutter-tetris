import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/input_manager.dart';

class KeyboardListener extends StatefulWidget {
  final Widget child;

  const KeyboardListener({Key key, this.child}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _KeyboardListenerState();
}

class _KeyboardListenerState extends State<KeyboardListener> {
  FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RawKeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        child: widget.child,
        onKey: onKey,
      );

  void onKey(RawKeyEvent event) {
    if (event is RawKeyUpEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      InputManager.instance.enterDirection(Direction.left);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      InputManager.instance.enterDirection(Direction.right);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      InputManager.instance.enterDirection(Direction.up);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      InputManager.instance.enterDirection(Direction.down);
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      InputManager.instance.enterButton(ButtonKey.b);
    } else if (event.logicalKey == LogicalKeyboardKey.keyZ) {
      InputManager.instance.enterButton(ButtonKey.a);
    } else if (event.logicalKey == LogicalKeyboardKey.keyX) {
      InputManager.instance.enterButton(ButtonKey.c);
    } else if (event.logicalKey == LogicalKeyboardKey.shiftLeft) {
      InputManager.instance.enterButton(ButtonKey.special2);
    }
  }
}
