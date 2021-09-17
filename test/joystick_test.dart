import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/screens/controller/joystick.dart';

void main() {
  late JoystickHandler handler;
  setUp(() {
    handler = JoystickHandler(const Duration(milliseconds: 200),
        const Duration(milliseconds: 50), 1, (direction) {});
  });
  tearDown(() {
    handler.dispose();
  });
  test("detect direction", () {
    handler.holdLever();
    handler.moveLever(Offset(-0.5, 0));
    expect(handler.direction, null);
    handler.moveLever(Offset(-0.5, 0));
    expect(handler.direction, JoystickDirection.centerLeft);
    handler.moveLever(Offset(0, -1));
    expect(handler.direction, JoystickDirection.topLeft);
    handler.moveLever(Offset(1, 0));
    expect(handler.direction, JoystickDirection.topCenter);
    handler.moveLever(Offset(1, 0));
    expect(handler.direction, JoystickDirection.topRight);
    handler.moveLever(Offset(0, 1));
    expect(handler.direction, JoystickDirection.centerRight);
    handler.moveLever(Offset(0, 1));
    expect(handler.direction, JoystickDirection.bottomRight);
    handler.moveLever(Offset(-1, 0));
    expect(handler.direction, JoystickDirection.bottomCenter);
    handler.moveLever(Offset(-1, 0));
    expect(handler.direction, JoystickDirection.bottomLeft);
    handler.moveLever(Offset(0, -0.5));
    expect(handler.direction, JoystickDirection.centerLeft);
    handler.releaseLever();
    expect(handler.direction, null);
  });
}
