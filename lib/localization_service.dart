import 'dart:ui';

import 'package:get/get.dart';

import 'lang/en_us.dart';
import 'lang/zh_hk.dart';

import 'package:bus_eta/main_controller.dart';

class LocalizationService extends Translations {
  // Default locale
  static const locale = Locale('zh', 'HK');
  static const fallbackLocale = Locale('en', 'US');

  // Supported languages
  // Needs to be same order with locales
  static final langs = [
    'English',
    '繁體中文',
  ];

  // Supported locales
  // Needs to be same order with langs
  static const locales = [
    Locale('en', 'US'),
    Locale('zh', 'HK'),
  ];

  // Keys and their translations
  // Translations are separated maps in `lang` file
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'zh_HK': zhHK,
      };

  // Gets locale from language, and updates the locale
  static void changeLocale(String lang) {
    final locale = _getLocaleFromLanguage(lang);
    Get.updateLocale(locale);

    final MainController mainController = Get.find<MainController>();
    mainController.onLanuageChangeStream.sink.add(null);
  }

  // Finds language in `langs` list and returns it as Locale
  static Locale _getLocaleFromLanguage(String lang) {
    for (int i = 0; i < langs.length; i++) {
      if (lang == langs[i]) return locales[i];
    }
    return Get.locale!;
  }
}
