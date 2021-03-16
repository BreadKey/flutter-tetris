import 'package:tetris/models/audio_manager.dart';

class MockAudioManager extends AudioManager {
  @override
  bool get isMuted => true;
  
  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  void pause() {
    // TODO: implement pause
  }

  @override
  void playEffect(Effect effect) {
    // TODO: implement playEffect
  }

  @override
  void resume() {
    // TODO: implement resume
  }

  @override
  void startBgm(Bgm bgm) {
    // TODO: implement startBgm
  }

  @override
  void stopBgm(Bgm bgm) {
    // TODO: implement stopBgm
  }

  @override
  void toggleMute() {
    // TODO: implement toggleMute
  }
}
