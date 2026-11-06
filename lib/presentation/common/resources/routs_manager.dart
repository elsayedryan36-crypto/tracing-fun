import 'package:flutter/material.dart';

import '../../../features/letters/letter_item.dart';
import '../../../features/letters/letters_screen.dart';
import '../../../features/menu/menu_screen.dart';
import '../../../features/reward/reward_screen.dart';
import '../../../features/splash/splash_screen.dart';
import '../../../features/tracing/tracing_screen.dart';

class Routes {
  Routes._();

  static const String splash = '/';
  static const String menu = '/menu';
  static const String letters = '/letters'; // argument: LetterGroup
  static const String tracing = '/tracing'; // argument: LetterItem
  static const String reward = '/reward'; // argument: LetterItem
}

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> getRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case Routes.splash:
        return _page(settings, const SplashScreen());
      case Routes.menu:
        return _page(settings, const MenuScreen());
      case Routes.letters:
        final group = args is LetterGroup ? args : LetterGroup.arabic;
        return _page(settings, LettersScreen(group: group));
      case Routes.tracing:
        if (args is LetterItem) {
          return _page(settings, TracingScreen(item: args));
        }
        break;
      case Routes.reward:
        if (args is LetterItem) {
          return _page(settings, RewardScreen(item: args));
        }
        break;
    }
    return _page(settings, const _UnknownRoute());
  }

  static MaterialPageRoute<dynamic> _page(RouteSettings settings, Widget w) {
    return MaterialPageRoute(settings: settings, builder: (_) => w);
  }
}

class _UnknownRoute extends StatelessWidget {
  const _UnknownRoute();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Route not found')));
  }
}
