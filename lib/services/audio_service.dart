import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  Future<void> playBoomLoop() async {
    if (_isPlaying) return;

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('sound/boom.mp3'));
    _isPlaying = true;
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  bool get isPlaying => _isPlaying;
}
