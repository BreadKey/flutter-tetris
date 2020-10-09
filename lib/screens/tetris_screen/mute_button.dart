import 'package:flutter/material.dart';
import 'package:tetris/models/audio_manager.dart';

class MuteButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MuteButtonState();
}

class _MuteButtonState extends State<MuteButton> {
  final audioManager = AudioManager.instance;
  bool canMute;

  @override
  void initState() {
    super.initState();

    canMute = !audioManager.isMuted;
  }

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        canMute ? const Icon(Icons.volume_off) : const Icon(Icons.volume_up),
        MaterialButton(
          onPressed: () {
            audioManager.toggleMute();
            setState(() {
              canMute = !audioManager.isMuted;
            });
          },
          color: Theme.of(context).buttonColor,
          minWidth: 24,
          height: 8,
        ),
      ]);
}
