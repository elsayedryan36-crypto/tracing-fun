import 'package:audioplayers/audioplayers.dart';

/// Plays the spoken letter name and word (generated voice, see docs/credits.md).
///
/// One player is used for voice, so a new sound stops the one before it.
class LetterVoice {
  LetterVoice._();

  static final AudioPlayer _player = AudioPlayer();

  /// Plays an asset path such as `assets/audio/ar_0_letter.mp3`. Null does nothing.
  static Future<void> play(String? assetPath) async {
    if (assetPath == null) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (_) {
      // A missing or broken sound must never stop the child from tracing.
    }
  }

  static Future<void> stop() => _player.stop();
}
