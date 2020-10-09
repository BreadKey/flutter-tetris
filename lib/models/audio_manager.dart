import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

enum Bgm { play, gameOver }

class AudioManager {
  static final instance = AudioManager._();

  final _bgmPlayers = <Bgm, Future<AudioPlayer>>{};
  final _bgmCache = AudioCache();

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  AudioManager._();

  void startBgm(Bgm bgm) async {
    if (_isMuted) return;

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
    } else {
      final bgmPlayer = await _bgmPlayers[bgm];

      bgmPlayer.resume();
    }
  }

  void stopBgm(Bgm bgm) async {
    final bgmPlayer = await _bgmPlayers[bgm];

    bgmPlayer.stop();
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
}
