import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'translations.dart';

/// One language the app can speak. [nativeName] is shown in the picker so a
/// child can find their own language even if they cannot read the others.
class LanguageOption {
  final String code;
  final String nativeName;
  final bool rtl;

  const LanguageOption(this.code, this.nativeName, {this.rtl = false});
}

/// Language state for the whole app.
///
/// First launch: follow the phone's language. If the phone's language is not
/// one of ours, use English. After a language is picked in Settings, it is
/// remembered and wins over the phone's language.
class AppLanguage {
  AppLanguage._();

  static const String fallbackCode = 'en';
  static const String _prefsKey = 'app_language';

  static const List<LanguageOption> options = [
    LanguageOption('en', 'English'),
    LanguageOption('ar', 'العربية', rtl: true),
    LanguageOption('fr', 'Français'),
    LanguageOption('es', 'Español'),
    LanguageOption('de', 'Deutsch'),
    LanguageOption('pt', 'Português'),
    LanguageOption('tr', 'Türkçe'),
    LanguageOption('id', 'Bahasa Indonesia'),
    LanguageOption('it', 'Italiano'),
    LanguageOption('ru', 'Русский'),
    LanguageOption('hi', 'हिन्दी'),
    LanguageOption('zh', '简体中文'),
    LanguageOption('ja', '日本語'),
    LanguageOption('ko', '한국어'),
  ];

  /// The language code the UI currently uses. MaterialApp listens to this.
  static final ValueNotifier<String> current = ValueNotifier<String>(
    fallbackCode,
  );

  static List<Locale> get supportedLocales => [
    for (final option in options) Locale(option.code),
  ];

  static bool isSupported(String code) =>
      options.any((option) => option.code == code);

  /// Maps a device locale to one of our codes, or English if we do not have it.
  static String resolveDevice(Locale deviceLocale) {
    // Older Android builds report Indonesian as 'in'.
    final code = deviceLocale.languageCode == 'in'
        ? 'id'
        : deviceLocale.languageCode;
    return isSupported(code) ? code : fallbackCode;
  }

  /// Call once at start-up, before runApp.
  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved != null && isSupported(saved)) {
        current.value = saved;
        return;
      }
    } catch (_) {
      // Storage problems must never block the app; fall through to the device.
    }
    current.value = resolveDevice(PlatformDispatcher.instance.locale);
  }

  /// Switches the language and remembers the choice.
  static Future<void> select(String code) async {
    if (!isSupported(code)) return;
    current.value = code;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, code);
    } catch (_) {
      // The switch still applies for this session.
    }
  }
}

/// Looks up a UI string in the current language, falling back to English.
/// `{name}` placeholders are filled from [args].
String tr(String key, [Map<String, String> args = const {}]) {
  final table = kTranslations[AppLanguage.current.value];
  var text =
      table?[key] ?? kTranslations[AppLanguage.fallbackCode]?[key] ?? key;
  args.forEach((name, value) {
    text = text.replaceAll('{$name}', value);
  });
  return text;
}

/// Translates a display name the app stores in English, such as a world name
/// ('Zoo'), a brush size ('Thin brush') or 'Pictures'. Unknown names are shown
/// as they are.
String trName(String englishName) {
  final key = 'name_${englishName.toLowerCase().replaceAll(' ', '_')}';
  final table = kTranslations[AppLanguage.current.value];
  return table?[key] ??
      kTranslations[AppLanguage.fallbackCode]?[key] ??
      englishName;
}
