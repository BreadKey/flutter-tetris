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

  final _bgmPlayers = <Bgm, Future<AudioPlayer>>{};
  final _bgmCache = AudioCache();

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  AudioManager._();

  void startBgm(Bgm bgm) async {
    if (_bgmPlayers[bgm] == null) {
      switch (bgm) {
        case Bgm.play:
          _bgmPlayers[bgm] = _bgmCache.loop("audios/tetris-gameboy-02.mp3");
          break;
        case Bgm.gameOver:
          _bgmPlayers[bgm] = _bgmCache.loop("audios/tetris-gameboy-01.mp3");
          break;
        default:
          break;
      }
    }

    final bgmPlayer = await _bgmPlayers[bgm];
    if (_isMuted) {
      bgmPlayer.setVolume(0);
    }
    bgmPlayer.resume();
  }

  void stopBgm(Bgm bgm) async {
    final bgmPlayer = await _bgmPlayers[bgm];

    bgmPlayer?.stop();
  }

  void toggleMute() async {
    _isMuted = !_isMuted;

    final bgmPlayers = await Future.wait(_bgmPlayers.values);

    for (AudioPlayer bgmPlayer in bgmPlayers) {
      if (_isMuted) {
        bgmPlayer.setVolume(0);
      } else {
        bgmPlayer.setVolume(1);
      }
    }
  }

  void dispose() {
    _bgmPlayers.values.forEach((future) {
      future.then((player) => player.dispose());
    });
  }

  void pause() {
    _bgmPlayers.values.forEach((future) {
      future.then((player) => player.setVolume(0));
    });
  }

  void resume() {
    _bgmPlayers.values.forEach((future) {
      future.then((player) {
        if (!isMuted) {
          player.setVolume(1);
        }
      });
    });
  }

  void playEffect(Effect effect) {
    if (_isMuted) return;

    switch (effect) {
      case Effect.lock:
        _bgmCache.play("audios/lock.wav");
        break;
      case Effect.move:
        _bgmCache.play("audios/move.wav");
        break;
      case Effect.rotate:
        _bgmCache.play("audios/rotate.wav");
        break;
      case Effect.hardDrop:
      case Effect.softDrop:
        _bgmCache.play("audios/hard_drop.wav");
        break;
      case Effect.breakLine:
        _bgmCache.play("audios/break_line.wav");
        break;
      case Effect.event:
        _bgmCache.play("audios/event.wav");
        break;
      case Effect.levelUp:
        _bgmCache.play("audios/level_up.wav");
        break;
    }
  }
}
