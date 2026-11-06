import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Background music. One player, looping, switched on and off from settings.
class MusicPlayer {
  MusicPlayer._();
  static final MusicPlayer instance = MusicPlayer._();

  static const double _volume = 0.4;
  final AudioPlayer _player = AudioPlayer();

  Future<void> setEnabled(bool on) async {
    try {
      if (on) {
        await _player.setReleaseMode(ReleaseMode.loop);
        await _player.setVolume(_volume);
        await _player.play(AssetSource('sounds/main.mp3'));
      } else {
        await _player.stop();
      }
    } catch (e) {
      debugPrint('MusicPlayer error: $e');
    }
  }
}
