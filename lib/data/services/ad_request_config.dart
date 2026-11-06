import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Builds every ad request and global SDK config for this app.
///
/// Kept in one place because a kids' app has hard requirements:
/// non-personalized ads only, G-rated content, child-directed tag on
/// every request. Every screen should pull requests from here instead
/// of constructing `AdRequest()` directly, so it's impossible to
/// accidentally ship a non-compliant request.
class AdRequestConfig {
  AdRequestConfig._();

  /// Call once, before any ad is loaded (right after MobileAds.instance.initialize()).
  static Future<void> applyGlobalChildDirectedSettings() async {
    final config = RequestConfiguration(
      ageRestrictedTreatment: AgeRestrictedTreatment.child,
      maxAdContentRating: MaxAdContentRating.g,
    );
    await MobileAds.instance.updateRequestConfiguration(config);
  }

  /// Use this for every individual ad load call (banner, interstitial, rewarded).
  /// `nonPersonalizedAds: true` disables personalized targeting per-request,
  /// which is required for child-directed inventory.
  static AdRequest request() {
    return const AdRequest(
      nonPersonalizedAds: true,
    );
  }
}
