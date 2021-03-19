part of joystick;

class JoystickHandler {
  final Duration holdDelay;
  final Duration holdInterval;
  final double minMoveDistance;
  final int _directionLength = JoystickDirection.values.length;
  final Function(JoystickDirection direction) onDirectionEntered;

  Offset _leverPosition = Offset.zero;

  Timer _holdDelayTimer;
  Timer _holdIntervalTimer;

  JoystickDirection _lastDirection;
  JoystickDirection get direction => _lastDirection;

  JoystickHandler(
    this.holdDelay,
    this.holdInterval,
    this.minMoveDistance,
    this.onDirectionEntered,
  );

  void holdLever() {
    _holdDelayTimer = Timer(holdDelay, () {
      _holdIntervalTimer = Timer.periodic(holdInterval, (_) {
        onDirectionEntered?.call(_lastDirection);
      });
    });
  }

  void moveLever(Offset delta) {
    _leverPosition += delta;

    if (_leverPosition.distance < minMoveDistance) {
      _lastDirection = null;
    } else {
      final direction = _detectDirection();

      if (direction != _lastDirection) {
        _lastDirection = direction;
        onDirectionEntered?.call(_lastDirection);
      }
    }
  }

  JoystickDirection _detectDirection() {
    const crossDirectionRadian = 6 / 16 * pi;
    const diagonalDirectionRadian = 2 / 16 * pi;
    const startRadian = pi + crossDirectionRadian / 2;

    double minRadian = startRadian;

    for (int index = 0; index < _directionLength; index++) {
      minRadian -=
          index % 2 == 0 ? crossDirectionRadian : diagonalDirectionRadian;

      if (_leverPosition.direction * -1 >= minRadian) {
        return JoystickDirection.values[index];
      }
    }

    return JoystickDirection.centerLeft;
  }

  void releaseLever() {
    _leverPosition = Offset.zero;
    _lastDirection = null;
    _holdDelayTimer?.cancel();
    _holdIntervalTimer?.cancel();
  }

  void dispose() {
    _holdDelayTimer?.cancel();
    _holdIntervalTimer?.cancel();
  }
}
