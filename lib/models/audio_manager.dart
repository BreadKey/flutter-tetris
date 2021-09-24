import 'dart:async';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

enum Bgm { play, gameOver }
enum Effect {
  lock,
  move,
  rotate,
  hardDrop,
  softDrop,
  lineClear,
  event,
  levelUp
}

const _effectFiles = {
  Effect.lock: "assets/audios/lock.wav",
  Effect.move: "assets/audios/move.wav",
  Effect.rotate: "assets/audios/rotate.wav",
  Effect.hold: "assets/audios/hold.wav",
  Effect.hardDrop: "assets/audios/hard_drop.wav",
  Effect.softDrop: "assets/audios/hard_drop.wav",
  Effect.lineClear: "assets/audios/line_clear.wav",
  Effect.event: "assets/audios/event.wav",
  Effect.levelUp: "assets/audios/level_up.wav",
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

class AudioManager extends IAudioManager {
  static const effectThrottleDuration = const Duration(milliseconds: 100);
  static const bgmVolume = 0.618;

  final _bgmPlayer = AudioPlayer();
  final _effectPlayer = AudioPlayer();
  final _effectThrottlers = <Effect, Timer>{};

  bool _isMuted = false;
  @override
  bool get isMuted => _isMuted;

  String? _currentEffectFile;

  late Completer _loadCompleter;

  AudioManager() {
    _loadCompleter = Completer();
    Future.wait(_effectFiles.values.map((element) {
      return _effectPlayer.setAsset(element);
    })).then((value) async {
      await _bgmPlayer.setLoopMode(LoopMode.all);
      _loadCompleter.complete();
    });
  }

  @override
  void startBgm(Bgm bgm) async {
    switch (bgm) {
      case Bgm.play:
        await _bgmPlayer.setAsset("assets/audios/tetris-gameboy-02.mp3");
        break;
      case Bgm.gameOver:
        await _bgmPlayer.setAsset("assets/audios/tetris-gameboy-01.mp3");
        break;
      default:
        break;
    }

    await _bgmPlayer.setVolume(_isMuted ? 0 : bgmVolume);
    await _bgmPlayer.play();
  }

  @override
  void stopBgm(Bgm bgm) async {
    await _bgmPlayer.stop();
  }

  @override
  void toggleMute() async {
    _isMuted = !_isMuted;
    if (_isMuted) {
      await _bgmPlayer.setVolume(0);
    } else {
      await _bgmPlayer.setVolume(bgmVolume);
    }
  }

  @override
  void dispose() {
    _bgmPlayer.dispose();
    _effectThrottlers.values.forEach((throttler) {
      throttler.cancel();
    });
  }

  @override
  void pause() {
    _bgmPlayer.pause();
  }

  @override
  void resume() async {
    await _bgmPlayer.setLoopMode(LoopMode.all);
    _bgmPlayer.play();
  }

  @override
  void playEffect(Effect effect) {
    if (canPlayEffect(effect)) {
      _playEffect(effect);
      _throttleEffect(effect);
    }
  }

  bool canPlayEffect(Effect effect) =>
      !_isMuted && _effectThrottlers[effect]?.isActive != true;

  void _playEffect(Effect effect) async {
    if (!_loadCompleter.isCompleted &&
        !(effect == Effect.event ||
            effect == Effect.lineClear ||
            effect == Effect.hardDrop ||
            effect == Effect.softDrop)) return;

    if (effect == Effect.softDrop) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }

    if (_currentEffectFile != _effectFiles[effect]) {
      _currentEffectFile = _effectFiles[effect];

      await _effectPlayer.setAsset(_currentEffectFile!);
    } else {
      await _effectPlayer.seek(Duration.zero);
    }
    _effectPlayer.play();
  }

  void _throttleEffect(Effect effect) {
    _effectThrottlers[effect] = Timer(effectThrottleDuration, () {});
  }
}
