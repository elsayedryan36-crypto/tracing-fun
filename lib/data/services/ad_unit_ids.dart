/// Every AdMob ad unit ID the tracing app uses, in one place.
///
/// IMPORTANT:
/// - The IDs below are Google's public TEST IDs. They are the only IDs used
///   until this app has its own AdMob app and ad units.
/// - Do NOT reuse the Coloring World production IDs here. Each ad unit belongs
///   to one AdMob app, so they must not be shipped in this app.
/// - When you create the new AdMob app, replace the `_prod*` values and keep
///   `USE_TEST_ADS` true for debug and test builds.
class AdUnitIds {
  AdUnitIds._();

  /// Release builds: `--dart-define=USE_TEST_ADS=false`.
  static const bool useTestAds = bool.fromEnvironment(
    'USE_TEST_ADS',
    defaultValue: true,
  );

  /// Menu screen banner (labelled "Advertisement" in the UI).
  static String get menuBanner => useTestAds ? _testBanner : _prodMenuBanner;

  /// Rewarded ad that unlocks a locked letter.
  static String get unlockImageRewarded =>
      useTestAds ? _testRewarded : _prodUnlockRewarded;

  /// Full-screen ad shown on every 5th return to the menu.
  static String get returnInterstitial =>
      useTestAds ? _testInterstitial : _prodReturnInterstitial;

  static const String _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';

  // TODO(owner): replace with the new app's AdMob ad unit IDs.
  static const String _prodMenuBanner = 'REPLACE_WITH_NEW_APP_BANNER_ID';
  static const String _prodUnlockRewarded = 'REPLACE_WITH_NEW_APP_REWARDED_ID';
  static const String _prodReturnInterstitial =
      'REPLACE_WITH_NEW_APP_INTERSTITIAL_ID';
}
