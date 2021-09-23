part of joystick;

class Lever extends StatelessWidget {
  final double diameter;
  final JoystickHandler handler;

  const Lever({Key? key, required this.diameter, required this.handler})
      : super(key: key);
  build(BuildContext context) => Draggable(
        child: _LeverDraggable(diameter: diameter, handler: handler),
        feedback: _LeverDraggable(diameter: diameter, handler: handler),
        childWhenDragging: SizedBox(
          width: diameter * 0.618,
          height: diameter * 0.618,
          child: Material(
            color: Colors.black,
            shape: const CircleBorder(),
          ),
        ),
        onDragStarted: handler.holdLever,
        onDragUpdate: (details) {
          handler.moveLever(details.delta);
        },
        onDragEnd: (_) => handler.releaseLever(),
      );
}

class _LeverDraggable extends StatelessWidget {
  final double diameter;
  final JoystickHandler handler;

  const _LeverDraggable(
      {Key? key, required this.diameter, required this.handler})
      : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox(
        width: diameter,
        height: diameter,
        child: Material(
          elevation: 8,
          shape: CircleBorder(),
          color: Colors.grey,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                      RetroColors.neutralBlackC.shade400,
                      RetroColors.neutralBlackC,
                      RetroColors.neutralBlackC.shade600,
                      RetroColors.neutralBlackC.shade800
                    ])),
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey)),
                ),
              ),
            ]..addAll(List.generate(4, (index) {
                final direction = JoystickDirection.values[index * 2];

                return Transform.rotate(
                    angle: pi / 2 * index,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: LongPressButton(
                        minWidth: 24,
                        height: 48,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: const SizedBox(),
                        padding: const EdgeInsets.all(0),
                        delay: handler.holdDelay,
                        interval: handler.holdInterval,
                        onPressed: () {
                          handler.onDirectionEntered?.call(direction);
                        },
                      ),
                    ));
              })),
          ),
        ),
      );
}
