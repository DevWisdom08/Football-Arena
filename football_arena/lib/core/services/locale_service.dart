import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_service.dart';

class LocaleService {
  static const String _languageKey = 'language';
  static const Locale defaultLocale = Locale('en');
  static const List<Locale> supportedLocales = [Locale('en'), Locale('ar')];

  static Future<Locale> getSavedLocale() async {
    final languageCode = StorageService.instance.getString(_languageKey);
    if (languageCode != null) {
      return Locale(languageCode);
    }
    return defaultLocale;
  }

  static Future<void> saveLocale(Locale locale) async {
    await StorageService.instance.setString(_languageKey, locale.languageCode);
  }

  static bool isRTL(Locale locale) {
    return locale.languageCode == 'ar';
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(LocaleService.defaultLocale) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final locale = await LocaleService.getSavedLocale();
    state = locale;
  }

  Future<void> setLocale(Locale locale) async {
    await LocaleService.saveLocale(locale);
    state = locale;
  }
}
