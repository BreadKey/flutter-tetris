import 'package:tetris/models/direction.dart';

enum ButtonKey { a, b, c, special1, special2 }

class InputManager {
  static final InputManager _instance = InputManager._();
  static InputManager get instance => _instance;

  InputManager._();

  final Set<InputListener> _listeners = Set();

  void enterDirection(Direction direction) {
    _listeners.forEach((listener) {
      listener.onDirectionEntered(direction);
    });
  }

  void enterButton(ButtonKey key) {
    _listeners.forEach((listener) {
      listener.onButtonEntered(key);
    });
  }

  void addListener(InputListener listener) {
    _listeners.add(listener);
  }

  void removeListener(InputListener listener) {
    _listeners.remove(listener);
  }
}

abstract class InputListener {
  void onDirectionEntered(Direction direction);
  void onButtonEntered(ButtonKey key);
}
