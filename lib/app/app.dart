import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../presentation/common/localization/app_language.dart';
import '../presentation/common/resources/routs_manager.dart';
import '../presentation/common/resources/theme_manager.dart';

class TracingApp extends StatelessWidget {
  const TracingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.current,
      builder: (context, code, _) {
        return MaterialApp(
          locale: Locale(code),
          supportedLocales: AppLanguage.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          initialRoute: Routes.splash,
          debugShowCheckedModeBanner: false,
          theme: getApplicationTheme(),
          onGenerateRoute: RouteGenerator.getRoute,
        );
      },
    );
  }
}
