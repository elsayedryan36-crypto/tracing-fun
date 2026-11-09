import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/services/return_interstitial_service.dart';
import '../../presentation/common/localization/app_language.dart';
import '../../presentation/common/resources/color_manager.dart';
import '../../presentation/common/resources/font_manager.dart';
import '../../presentation/common/resources/values_manager.dart';
import '../letters/letter_item.dart';
import '../letters/letter_voice.dart';

/// Shown after a successful trace.
///
/// v1: shows the reward picture. Colouring with the painting tools is planned
/// for a later version (see TRACING_APP_SPEC.md).
class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key, required this.item});

  final LetterItem item;

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  @override
  void initState() {
    super.initState();
    LetterVoice.play(widget.item.wordAudio);
  }

  @override
  Widget build(BuildContext context) => _RewardBody(item: widget.item);
}

class _RewardBody extends StatelessWidget {
  const _RewardBody({required this.item});

  final LetterItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ValueListenableBuilder<String>(
          valueListenable: AppLanguage.current,
          builder: (context, _, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tr('well_done'),
                style: TextStyle(
                  fontSize: AppPx.p20,
                  fontWeight: FontWeight.w800,
                  color: ColorManager.darkPrimary,
                ),
              ),
              SizedBox(height: AppPx.p8),
              SizedBox(height: AppPx.p8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: AppPx.p150,
                    height: AppPx.p150,
                    child: SvgPicture.asset(item.picture, fit: BoxFit.contain),
                  ),
                  if (item.wordPicture != null) ...[
                    SizedBox(width: AppPx.p12),
                    SizedBox(
                      width: AppPx.p150,
                      height: AppPx.p150,
                      child: Image.asset(item.wordPicture!, fit: BoxFit.contain),
                    ),
                  ],
                ],
              ),
              if (item.word != null) ...[
                SizedBox(height: AppPx.p8),
                Text(
                  item.word!,
                  style: TextStyle(
                    fontFamily: item.group == LetterGroup.arabic
                        ? FontConstants.arabicFont
                        : null,
                    fontSize: AppPx.p20,
                    fontWeight: FontWeight.w800,
                    color: ColorManager.darkPrimary,
                  ),
                ),
              ],
              SizedBox(height: AppPx.p12),
              ElevatedButton(
                onPressed: () {
                  ReturnInterstitialService.instance.markTracingSession();
                  Navigator.of(context).pop();
                },
                child: Text(tr('next')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
