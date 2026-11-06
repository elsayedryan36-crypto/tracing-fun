import 'package:flutter/material.dart';

import '../../data/services/return_interstitial_service.dart';
import '../../data/services/ad_unit_ids.dart';
import '../../presentation/common/localization/app_language.dart';
import '../../presentation/common/resources/color_manager.dart';
import '../../presentation/common/resources/routs_manager.dart';
import '../../presentation/common/resources/values_manager.dart';
import '../../presentation/common/widgets/ad_banner_strip.dart';
import '../letters/letter_item.dart';
import '../settings/settings_dialog.dart';

/// Home menu: three big buttons, a settings button, and one labelled banner.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  Future<void> _openGroup(BuildContext context, LetterGroup group) async {
    await Navigator.of(context).pushNamed(Routes.letters, arguments: group);
    // Back on the menu: count the return (only after a tracing session).
    ReturnInterstitialService.instance.onReturnToMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    top: AppPx.p8,
                    right: AppPx.p8,
                    child: IconButton(
                      tooltip: tr('settings'),
                      icon: const Icon(Icons.settings),
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => const SettingsDialog(),
                      ),
                    ),
                  ),
                  Center(
                    child: ValueListenableBuilder<String>(
                      valueListenable: AppLanguage.current,
                      builder: (context, _, _) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _MenuButton(
                            label: tr('menu_arabic'),
                            glyph: 'ا',
                            color: ColorManager.darkPrimary,
                            onTap: () =>
                                _openGroup(context, LetterGroup.arabic),
                          ),
                          SizedBox(width: AppPx.p20),
                          _MenuButton(
                            label: tr('menu_english'),
                            glyph: 'A',
                            color: ColorManager.pinkPrimary,
                            onTap: () =>
                                _openGroup(context, LetterGroup.english),
                          ),
                          SizedBox(width: AppPx.p20),
                          _MenuButton(
                            label: tr('menu_numbers'),
                            glyph: '123',
                            color: ColorManager.gold,
                            onTap: () =>
                                _openGroup(context, LetterGroup.numbers),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // The only banner in this screen. It is labelled "Advertisement".
            AdBannerStrip(adUnitId: AdUnitIds.menuBanner),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.glyph,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String glyph;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppPx.p20),
      onTap: onTap,
      child: Container(
        width: AppPx.p100,
        padding: EdgeInsets.all(AppPx.p12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppPx.p20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              glyph,
              style: TextStyle(
                fontSize: AppPx.p40,
                fontWeight: FontWeight.w800,
                color: ColorManager.white,
              ),
            ),
            SizedBox(height: AppPx.p8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppPx.p12,
                fontWeight: FontWeight.w700,
                color: ColorManager.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
