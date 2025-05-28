import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  late AudioPlayer _player;
  double _volume = 0.7;

  AudioManager._internal() {
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.loop);
    _player.setVolume(_volume);
  }

  Future<void> playBackgroundMusic() async {
    await _player.play(AssetSource('audio/bg_music.mp3'));
  }

  void setVolume(double volume) {
    _volume = volume;
    _player.setVolume(volume);
  }

  double get volume => _volume;

  void pause() => _player.pause();
  void resume() => _player.resume();
}
