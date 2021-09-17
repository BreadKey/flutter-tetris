part of controller;

class _SpecialButton extends StatelessWidget {
  final ButtonKey? buttonKey;

  const _SpecialButton({Key? key, this.buttonKey}) : super(key: key);

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: -pi / 6,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
                offset: Offset(0, 18),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 24),
                  child: Controller.of(context).buttonIcons[buttonKey!] ??
                      const SizedBox.shrink(),
                )),
            MaterialButton(
              onPressed: () {
                Controller.of(context).onButtonEntered?.call(buttonKey!);
              },
              materialTapTargetSize: MaterialTapTargetSize.padded,
              color: Controller.of(context).specialButtonColor,
              minWidth: 24,
              height: 10,
            ),
          ],
        ),
      );
}
