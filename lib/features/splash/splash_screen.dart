import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../presentation/common/localization/app_language.dart';
import '../../presentation/common/resources/assets_manager.dart';
import '../../presentation/common/resources/color_manager.dart';
import '../../presentation/common/resources/routs_manager.dart';
import '../../presentation/common/resources/values_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) Navigator.of(context).pushReplacementNamed(Routes.menu);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      body: Center(
        child: ValueListenableBuilder<String>(
          valueListenable: AppLanguage.current,
          builder: (context, _, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: AppPx.p150,
                height: AppPx.p150,
                child: Lottie.asset(JsonAssets.loading),
              ),
              Text(
                tr('app_name'),
                style: TextStyle(
                  fontSize: AppPx.p20,
                  fontWeight: FontWeight.w800,
                  color: ColorManager.darkPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
