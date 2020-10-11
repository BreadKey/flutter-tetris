import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

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

class AudioManager {
  static final instance = AudioManager._();

  final _bgmPlayer = AudioPlayer();
  final _bgmCache = AudioCache();

  final _effectCache = AudioCache();

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  AudioManager._() {
    _bgmCache.fixedPlayer = _bgmPlayer;
  }

  void startBgm(Bgm bgm) async {
    switch (bgm) {
      case Bgm.play:
        _bgmCache.loop("audios/tetris-gameboy-02.mp3");
        break;
      case Bgm.gameOver:
        _bgmCache.loop("audios/tetris-gameboy-01.mp3");
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
      _bgmPlayer.setVolume(1);
    }
  }

  void dispose() {
    _bgmPlayer.dispose();
  }

  void pause() {
    _bgmPlayer.pause();
  }

  void resume() {
    _bgmPlayer.resume();
  }

  void playEffect(Effect effect) {
    if (_isMuted) return;

    String effectFile;

    switch (effect) {
      case Effect.lock:
        effectFile = "audios/lock.wav";
        break;
      case Effect.move:
        effectFile = "audios/move.wav";
        break;
      case Effect.rotate:
        effectFile = ("audios/rotate.wav");
        break;
      case Effect.hardDrop:
      case Effect.softDrop:
        effectFile = ("audios/hard_drop.wav");
        break;
      case Effect.breakLine:
        effectFile = ("audios/break_line.wav");
        break;
      case Effect.event:
        effectFile = "audios/event.wav";
        break;
      case Effect.levelUp:
        effectFile = ("audios/level_up.wav");
        break;
    }

    _effectCache.play(effectFile,
        mode: PlayerMode.LOW_LATENCY, isNotification: false);
  }
}
