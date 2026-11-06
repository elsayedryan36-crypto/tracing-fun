import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tracing_app/data/services/ad_request_config.dart';
import 'package:tracing_app/data/services/ad_unit_ids.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'unlocked_images_store.dart';

/// What happened when a child tapped a locked picture.
enum UnlockResult {
  /// The child watched the whole ad and the picture is unlocked.
  unlocked,

  /// No ad was ready yet. The request is kept, and the ad opens by itself
  /// as soon as it loads (for up to [RewardedAdService.queueLife]).
  queued,

  /// The ad was closed before the reward, or could not be shown.
  notFinished,
}

/// Manages the single rewarded placement in the app: "watch an ad to
/// unlock this image". The image is only unlocked inside
/// `onUserEarnedReward` — never before the ad actually completes.
///
/// Why the old version failed: a tap on a locked card returned at once when
/// no ad was loaded yet, and `RewardedAd.show` returns before the reward is
/// earned, so the card reported a failure even after a full ad.
class RewardedAdService {
  RewardedAdService._();
  static final RewardedAdService instance = RewardedAdService._();

  /// How long a queued request stays alive.
  static const Duration queueLife = Duration(seconds: 90);

  /// Pause before trying to load again after a failed load.
  static const Duration retryDelay = Duration(seconds: 5);

  RewardedAd? _ad;
  bool _isLoading = false;
  _QueuedUnlock? _queued;

  /// When the child last tapped a locked picture (for timing logs).
  DateTime? _tapAt;

  void preload() {
    if (_isLoading || _ad != null) return;
    _isLoading = true;
    final started = DateTime.now();
    RewardedAd.load(
      adUnitId: AdUnitIds.unlockImageRewarded,
      request: AdRequestConfig.request(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
          debugPrint(
            'rewarded ad loaded in '
            '${DateTime.now().difference(started).inMilliseconds} ms',
          );
          _showQueuedIfAny();
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _ad = null;
          debugPrint(
            'rewarded ad failed to load: ${error.code} ${error.message}',
          );
          final queued = _queued;
          if (queued != null && !queued.expired) {
            Future<void>.delayed(retryDelay, preload);
          }
        },
      ),
    );
  }

  /// Called when a child taps a locked picture. Never waits: if the ad is
  /// ready it opens now; if not, the request is queued and the ad opens by
  /// itself as soon as it loads.
  Future<UnlockResult> showToUnlock({
    required String imageId,
    VoidCallback? onUnlocked,
  }) {
    _tapAt = DateTime.now();
    final ad = _ad;
    if (ad == null) {
      debugPrint('unlock tap: ad not ready, queued');
      _queued = _QueuedUnlock(imageId, onUnlocked);
      preload();
      return Future.value(UnlockResult.queued);
    }
    _queued = null;
    return _show(imageId: imageId, onUnlocked: onUnlocked);
  }

  void _showQueuedIfAny() {
    final queued = _queued;
    if (queued == null) return;
    _queued = null;
    if (queued.expired) return;
    _show(imageId: queued.imageId, onUnlocked: queued.onUnlocked);
  }

  Future<UnlockResult> _show({
    required String imageId,
    VoidCallback? onUnlocked,
  }) {
    final ad = _ad;
    if (ad == null) return Future.value(UnlockResult.notFinished);

    final done = Completer<UnlockResult>();
    var earnedReward = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        final tapAt = _tapAt;
        if (tapAt != null) {
          debugPrint(
            'rewarded ad shown '
            '${DateTime.now().difference(tapAt).inMilliseconds} ms after tap',
          );
        }
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        if (!done.isCompleted) {
          done.complete(
            earnedReward ? UnlockResult.unlocked : UnlockResult.notFinished,
          );
        }
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _ad = null;
        debugPrint(
          'rewarded ad failed to show: ${error.code} ${error.message}',
        );
        if (!done.isCompleted) done.complete(UnlockResult.notFinished);
        preload();
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) async {
        earnedReward = true;
        await UnlockedImagesStore.instance.unlock(imageId);
        onUnlocked?.call();
      },
    );

    return done.future;
  }
}

class _QueuedUnlock {
  final String imageId;
  final VoidCallback? onUnlocked;
  final DateTime since = DateTime.now();

  _QueuedUnlock(this.imageId, this.onUnlocked);

  bool get expired =>
      DateTime.now().difference(since) > RewardedAdService.queueLife;
}
