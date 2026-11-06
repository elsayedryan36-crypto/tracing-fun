import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ad_request_config.dart';
import 'ad_unit_ids.dart';

/// Shows one full-screen ad on every 5th return to the menu from a tracing
/// session. Never shown during tracing, the reward screen, or the rewarded flow.
///
/// If no ad is loaded on the 5th return, the ad is skipped (it is not queued),
/// so the child is never kept waiting.
class ReturnInterstitialService {
  ReturnInterstitialService._();
  static final ReturnInterstitialService instance =
      ReturnInterstitialService._();

  static const int everyNReturns = 5;
  static const String _countKey = 'return_to_menu_count';

  InterstitialAd? _ad;
  bool _isLoading = false;
  bool _tracedSinceLastReturn = false;

  /// Call when a child completes a trace (the reward screen opens).
  /// Only a return after tracing counts toward the every-5th rule.
  void markTracingSession() => _tracedSinceLastReturn = true;

  void preload() {
    if (_isLoading || _ad != null) return;
    _isLoading = true;
    InterstitialAd.load(
      adUnitId: AdUnitIds.returnInterstitial,
      request: AdRequestConfig.request(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('return interstitial failed to load: ${error.message}');
          _ad = null;
          _isLoading = false;
        },
      ),
    );
  }

  /// Call once each time the child returns to the menu from a tracing session.
  Future<void> onReturnToMenu() async {
    if (!_tracedSinceLastReturn) return;
    _tracedSinceLastReturn = false;

    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_countKey) ?? 0) + 1;
    await prefs.setInt(_countKey, count);

    final isEveryFifth = count % everyNReturns == 0;
    final ad = _ad;
    if (!isEveryFifth || ad == null) {
      preload();
      return;
    }

    _ad = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        preload();
      },
    );
    await ad.show();
  }
}
