import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class BrushSoundService {
  static final BrushSoundService instance = BrushSoundService._();

  BrushSoundService._();

  final AudioPlayer _loopPlayer = AudioPlayer();

  // Tracks currently-playing one-shot players so we can stop/dispose
  // them deterministically instead of letting them pile up when the
  // user taps multiple tools rapidly (this was causing the app to
  // get "stuck" — too many concurrent native audio instances).
  final List<AudioPlayer> _oncePlayers = [];

  bool _isDisposed = false;
  bool _isInitialized = false;

  // NEW: the brush sounds level from the Sound levels popup (0..1).
  // Click sounds play at a fifth of it, so the default (0.5) keeps the
  // click loudness the app always had; the pencil/eraser loop uses it directly.
  double _level = 0.5;
  double get level => _level;
  double get _oneShotVolume => _level * 0.2;

  void setLevel(double value) {
    _level = value.clamp(0.0, 1.0);
  }

  // Serializes every play/stop call so rapid tool switching can never
  // fire overlapping native audio operations.
  Future<void> _lock = Future.value();

  Future<void> _runExclusive(Future<void> Function() action) {
    final previous = _lock;
    final completer = Completer<void>();
    _lock = completer.future;

    previous.whenComplete(() async {
      if (_isDisposed) {
        completer.complete();
        return;
      }
      try {
        await action();
      } catch (e) {
        debugPrint('BrushSoundService error: $e');
      } finally {
        completer.complete();
      }
    });

    return completer.future;
  }

  Future<void> initialize() async {
    if (_isInitialized || _isDisposed) return;
    try {
      await _loopPlayer.setReleaseMode(ReleaseMode.loop);
      _isInitialized = true;
    } catch (e) {
      debugPrint('BrushSoundService.initialize error: $e');
    }
  }

  /// Continuous sound (pencil, eraser)
  Future<void> playLoop(String asset) {
    if (_isDisposed) return Future.value();
    return _runExclusive(() async {
      // Stop any one-shot sounds first so loop & one-shot never overlap.
      await _stopAllOnceInternal();

      try {
        await _loopPlayer.stop();
        await _loopPlayer.setReleaseMode(ReleaseMode.loop);
        await _loopPlayer.setVolume(_level); // NEW: brush sounds level
        await _loopPlayer.play(AssetSource(asset));
      } catch (e) {
        debugPrint('BrushSoundService.playLoop error: $e');
      }
    });
  }

  /// One click sound (fill, magic, stamp)
  Future<void> playOnce(String asset) {
    // (old) Future<void> playOnce(String asset, double kSoundVolum) {
    if (_isDisposed) return Future.value();
    return _runExclusive(() async {
      // Stop the loop sound so pencil/eraser loop never bleeds into a
      // fill/magic/stamp one-shot.
      try {
        await _loopPlayer.stop();
      } catch (e) {
        debugPrint('Error stopping loop player: $e');
      }

      // Stop any still-playing one-shot players before starting a new
      // one — prevents unbounded AudioPlayer instances piling up when
      // the user taps rapidly across tools.
      await _stopAllOnceInternal();

      final player = AudioPlayer();
      _oncePlayers.add(player);

      try {
        await player.setReleaseMode(ReleaseMode.release);
        await player.setVolume(
          _oneShotVolume,
        ); // NEW: from the brush sounds level
        // (old)         await player.setVolume(kSoundVolum); // <-- volume bug fixed
        await player.play(AssetSource(asset));

        player.onPlayerComplete.listen((_) async {
          _oncePlayers.remove(player);
          try {
            await player.dispose();
          } catch (_) {}
        });
      } catch (e) {
        debugPrint('BrushSoundService.playOnce error: $e');
        _oncePlayers.remove(player);
        try {
          await player.dispose();
        } catch (_) {}
      }
    });
  }

  Future<void> _stopAllOnceInternal() async {
    if (_oncePlayers.isEmpty) return;
    final players = List<AudioPlayer>.from(_oncePlayers);
    _oncePlayers.clear();
    for (final p in players) {
      try {
        await p.stop();
        await p.dispose();
      } catch (e) {
        debugPrint('Error stopping one-shot player: $e');
      }
    }
  }

  Future<void> stop() {
    if (_isDisposed) return Future.value();
    return _runExclusive(() async {
      try {
        await _loopPlayer.stop();
      } catch (e) {
        debugPrint('Error stopping loop player: $e');
      }
      await _stopAllOnceInternal();
    });
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    try {
      await _loopPlayer.stop();
      await _loopPlayer.dispose();
    } catch (e) {
      debugPrint('Error disposing loop player: $e');
    }

    await _stopAllOnceInternal();
  }
}
