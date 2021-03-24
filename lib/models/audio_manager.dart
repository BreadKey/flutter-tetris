import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

enum Bgm { play, gameOver }
enum Effect {
  lock,
  move,
  rotate,
  hold,
  hardDrop,
  softDrop,
  breakLine,
  event,
  levelUp
}

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

  AudioManager() {
    if (Platform.isIOS) {
      _bgmPlayer.monitorNotificationStateChanges(_callback);
    }
    _bgmCache.fixedPlayer = _bgmPlayer;
  }

  @override
  void startBgm(Bgm bgm) {
    switch (bgm) {
      case Bgm.play:
        _bgmCache.loop("audios/tetris-gameboy-02.mp3",
            volume: _isMuted ? 0 : bgmVolume);
        break;
      case Bgm.gameOver:
        _bgmCache.loop("audios/tetris-gameboy-01.mp3",
            volume: _isMuted ? 0 : bgmVolume);
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
      _bgmPlayer.setVolume(bgmVolume);
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
    String effectFile;

    switch (effect) {
      case Effect.lock:
        effectFile = "audios/lock.wav";
        break;
      case Effect.move:
        effectFile = "audios/move.wav";
        break;
      case Effect.rotate:
        effectFile = "audios/rotate.wav";
        break;
      case Effect.hold:
        effectFile = "audios/hold.wav";
        break;
      case Effect.hardDrop:
      case Effect.softDrop:
        effectFile = "audios/hard_drop.wav";
        break;
      case Effect.breakLine:
        effectFile = "audios/break_line.wav";
        break;
      case Effect.event:
        effectFile = "audios/event.wav";
        break;
      case Effect.levelUp:
        effectFile = "audios/level_up.wav";
        break;
    }

    _effectCache
        .play(effectFile, mode: PlayerMode.LOW_LATENCY, isNotification: false)
        .then((player) {
      if (Platform.isIOS) {
        player.monitorNotificationStateChanges(_callback);
      }
    });
  }

  void _throttle(Effect effect) {
    _effectThrottlers[effect] = Timer(effectThrottleDuration, () {});
  }
}
