import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';

enum Bgm { play, gameOver }

enum Effect {
  lock,
  move,
  rotate,
  hold,
  hardDrop,
  softDrop,
  lineClear,
  event,
  levelUp
}

const _effectFiles = {
  Effect.lock: "lock.wav",
  Effect.move: "move.wav",
  Effect.rotate: "rotate.wav",
  Effect.hold: "hold.wav",
  Effect.hardDrop: "hard_drop.wav",
  Effect.softDrop: "hard_drop.wav",
  Effect.lineClear: "line_clear.wav",
  Effect.event: "event.wav",
  Effect.levelUp: "level_up.wav",
};

abstract class IAudioManager {
  bool get isMuted;
  void startBgm(Bgm bgm);
  void stopBgm(Bgm bgm);
  void toggleMute();
  void dispose();
  void pause();
  void resume();
  void playEffect(Effect effect);
}

class FlameAudioManager implements IAudioManager {
  static const bgmVolume = 0.618;

  AudioPlayer? _bgmPlayer;

  bool _isMuted = false;
  @override
  bool get isMuted => _isMuted;
  @override
  void dispose() {
    _bgmPlayer?.dispose();
  }

  @override
  void pause() {
    _bgmPlayer?.pause();
  }

  @override
  void playEffect(Effect effect) {
    if (effect == Effect.softDrop) {
      HapticFeedback.lightImpact();
    } else if (effect == Effect.hardDrop) {
      HapticFeedback.heavyImpact();
    }
    if (_isMuted) return;

    FlameAudio.play(_effectFiles[effect]!);
  }

  @override
  void resume() {
    _bgmPlayer?.resume();
  }

  @override
  void startBgm(Bgm bgm) async {
    await _bgmPlayer?.stop();
    await _bgmPlayer?.dispose();

    if (_isMuted) return;

    switch (bgm) {
      case Bgm.play:
        _bgmPlayer = await FlameAudio.loopLongAudio("tetris-gameboy-02.mp3",
            volume: bgmVolume);
        break;
      case Bgm.gameOver:
        _bgmPlayer = await FlameAudio.loopLongAudio("tetris-gameboy-01.mp3",
            volume: bgmVolume);
        break;
      default:
        break;
    }
  }

  @override
  void stopBgm(Bgm bgm) {
    _bgmPlayer?.stop();
  }

  @override
  void toggleMute() async {
    _isMuted = !_isMuted;
    if (_isMuted) {
      await _bgmPlayer?.setVolume(0);
    } else {
      await _bgmPlayer?.setVolume(bgmVolume);
    }
  }
}
