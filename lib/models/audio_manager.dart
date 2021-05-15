import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

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
  Effect.lock: "audios/lock.wav",
  Effect.move: "audios/move.wav",
  Effect.rotate: "audios/rotate.wav",
  Effect.hold: "audios/hold.wav",
  Effect.hardDrop: "audios/hard_drop.wav",
  Effect.softDrop: "audios/hard_drop.wav",
  Effect.lineClear: "audios/line_clear.wav",
  Effect.event: "audios/event.wav",
  Effect.levelUp: "audios/level_up.wav",
};

void _callback(AudioPlayerState value) {
  print("state => $value");
}

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
  final _bgmCache = AudioCache();

  final _effectCache = AudioCache();
  final _effectThrottlers = <Effect, Timer>{};

  bool _isMuted = false;
  @override
  bool get isMuted => _isMuted;

  Completer _loadCompleter;

  AudioManager() {
    if (Platform.isIOS) {
      _bgmPlayer.monitorNotificationStateChanges(_callback);
    }
    _bgmCache.fixedPlayer = _bgmPlayer;
    _loadCompleter = Completer();
    _effectCache.loadAll(_effectFiles.values.toList()).then((_) {
      _loadCompleter.complete();
    });
  }

  @override
  void startBgm(Bgm bgm) {
    switch (bgm) {
      case Bgm.play:
        _bgmCache.loop("audios/tetris-gameboy-02.mp3",
            volume: _isMuted ? 0 : _bgmVolume);
        break;
      case Bgm.gameOver:
        _bgmCache.loop("audios/tetris-gameboy-01.mp3",
            volume: _isMuted ? 0 : _bgmVolume);
        break;
      default:
        break;
    }
  }

  @override
  void stopBgm(Bgm bgm) async {
    _bgmPlayer.stop();
  }

  @override
  void toggleMute() async {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _bgmPlayer.setVolume(0);
    } else {
      _bgmPlayer.setVolume(_bgmVolume);
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
  void resume() {
    _bgmPlayer.resume();
  }

  @override
  void playEffect(Effect effect) {
    if (canPlayEffect(effect)) {
      _playEffect(effect);
      _throttle(effect);
    }
  }

  bool canPlayEffect(Effect effect) =>
      !_isMuted && _effectThrottlers[effect]?.isActive != true;

  void _playEffect(Effect effect) {
    if (!_loadCompleter.isCompleted &&
        !(effect == Effect.event || effect == Effect.lineClear)) return;

    HapticFeedback.heavyImpact();

    _effectCache.play(_effectFiles[effect],
        mode: PlayerMode.LOW_LATENCY, isNotification: false);
  }

  void _throttle(Effect effect) {
    _effectThrottlers[effect] = Timer(effectThrottleDuration, () {});
  }
}
