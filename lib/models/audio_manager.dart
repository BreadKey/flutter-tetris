import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:rxdart/rxdart.dart';

enum Bgm { play, gameOver }
enum Effect {
  lock,
  move,
  rotate,
  hardDrop,
  softDrop,
  breakLine,
  event,
  levelUp
}

void _callback(AudioPlayerState value) {
  print("state => $value");
}

class AudioManager {
  static final instance = AudioManager._();
  static const bgmVolume = 0.618;

  final _bgmPlayer = AudioPlayer();
  final _bgmCache = AudioCache();

  final _effectCache = AudioCache();

  final _effectSubject = PublishSubject<Effect>();
  Map<Effect, StreamSubscription> _effectThrotllers;

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  AudioManager._() {
    _bgmPlayer.monitorNotificationStateChanges(_callback);
    _bgmCache.fixedPlayer = _bgmPlayer;
    _effectThrotllers = Map.fromEntries(Effect.values.map((e) => MapEntry(
        e,
        _effectSubject
            .where((event) => event == e)
            .throttleTime(const Duration(milliseconds: 100))
            .listen((effect) {
          _playEffect(effect);
        }))));
  }

  void startBgm(Bgm bgm) async {
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

  void stopBgm(Bgm bgm) async {
    _bgmPlayer.stop();
  }

  void toggleMute() async {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _bgmPlayer.setVolume(0);
    } else {
      _bgmPlayer.setVolume(bgmVolume);
    }
  }

  void dispose() {
    _bgmPlayer.dispose();
    _effectSubject.close();
    _effectThrotllers.values.forEach((throtller) {
      throtller.cancel();
    });
  }

  void pause() {
    _bgmPlayer.pause();
  }

  void resume() {
    _bgmPlayer.resume();
  }

  void playEffect(Effect effect) {
    if (_isMuted) return;

    _effectSubject.sink.add(effect);
  }

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
        .then((player) => player.monitorNotificationStateChanges(_callback));
  }
}
