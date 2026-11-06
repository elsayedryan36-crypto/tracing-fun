import 'package:flutter/material.dart';
import 'package:tracing_app/data/services/ad_request_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A single reusable banner widget. Pass in whichever ad unit ID
/// belongs to the screen using it (see AdUnitIds) — this widget has
/// no knowledge of *which* screen it's on, keeping it fully reusable.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key, required this.adUnitId});

  final String adUnitId;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: AdRequestConfig.request(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null || !_isLoaded) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
