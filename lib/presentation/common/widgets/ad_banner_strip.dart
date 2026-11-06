import 'package:flutter/material.dart';
import 'package:tracing_app/presentation/common/localization/app_language.dart';
import 'package:tracing_app/presentation/common/resources/color_manager.dart';
import 'package:tracing_app/presentation/common/resources/values_manager.dart';
import 'package:tracing_app/presentation/common/widgets/banner_ad_widget.dart';

/// A banner ad on a plain grey strip with an "Advertisement" label.
/// It must not look like the game's own artwork (Families ad policy).
class AdBannerStrip extends StatelessWidget {
  const AdBannerStrip({super.key, required this.adUnitId});

  final String adUnitId;

  @override
  Widget build(BuildContext context) {
    // The grey panel wraps the banner, so its size follows the ad.
    return Center(
      child: Container(
        color: ColorManager.hexFFF2F2F2,
        padding: EdgeInsets.all(AppPx.p4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('advertisement'),
              style: TextStyle(
                color: ColorManager.hexFF555555,
                fontSize: AppPx.p10,
              ),
            ),
            SizedBox(height: AppPx.p2),
            DecoratedBox(
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: BorderRadius.circular(AppPx.p6),
                border: Border.all(color: ColorManager.hexFFCFCFCF),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppPx.p6),
                child: BannerAdWidget(adUnitId: adUnitId),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
