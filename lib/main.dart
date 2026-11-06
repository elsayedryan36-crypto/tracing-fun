import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sizer/sizer.dart';

import 'app/app.dart';
import 'app/bloc_observer.dart';
import 'data/services/ad_request_config.dart';
import 'data/services/rewarded_ad_service.dart';
import 'data/services/return_interstitial_service.dart';
import 'features/settings/settings_cubit.dart';
import 'presentation/common/localization/app_language.dart';
import 'presentation/common/services/sound_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await AppLanguage.load();

  final settings = SettingsCubit();
  await settings.load();
  await BrushSoundService.instance.initialize();

  // Ads: child-directed settings first, then preload. Test IDs by default.
  await MobileAds.instance.initialize();
  await AdRequestConfig.applyGlobalChildDirectedSettings();
  RewardedAdService.instance.preload();
  ReturnInterstitialService.instance.preload();

  runApp(
    BlocProvider.value(
      value: settings,
      child: Sizer(
        builder: (context, orientation, deviceType) => const TracingApp(),
      ),
    ),
  );
}
