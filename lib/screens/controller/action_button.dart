part of controller;

class _ActionButton extends StatelessWidget {
  final ButtonKey buttonKey;

  const _ActionButton({Key? key, required this.buttonKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Controller.of(context);

    return Stack(alignment: Alignment.center, children: [
      Material(
        color: controller.actionButtonColor!.shade600,
        shape: const CircleBorder(),
        elevation: 4,
        child: SizedBox(
            width: controller.actionButtonSize,
            height: controller.actionButtonSize,
            child: Center(
              child: Container(
                width: controller.actionButtonSize - 12,
                height: controller.actionButtonSize - 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        controller.actionButtonColor!.shade50,
                        controller.actionButtonColor!.shade200,
                        controller.actionButtonColor!,
                        controller.actionButtonColor!,
                        controller.actionButtonColor!.shade600,
                        controller.actionButtonColor!.shade800
                      ]),
                ),
              ),
            )),
      ),
      LongPressButton(
        delay: controller.longPressDelay,
        interval: controller.longPressInterval,
        onPressed: () {
          Controller.of(context).onButtonEntered?.call(buttonKey);
        },
        child: controller.buttonIcons[buttonKey] ??
            Text(buttonKey.toString().split('.').last.toUpperCase()),
        minWidth: controller.actionButtonSize,
        height: controller.actionButtonSize,
        shape: const CircleBorder(),
        textColor: Colors.grey,
      ),
    ]);
  }
}
