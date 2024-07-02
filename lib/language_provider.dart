import 'package:flutter/material.dart';
import 'package:senslinq/constants/app_translation.dart'; 

enum AppLanguage { English, Arabic }

class LanguageProvider with ChangeNotifier {
  AppLanguage _appLanguage = AppLanguage.English;

  AppLanguage get appLanguage => _appLanguage;

  void changeLanguage(AppLanguage language) {
    _appLanguage = language;
    notifyListeners();
  }

  String getTranslatedValue(String key) {
    final languageKey = _appLanguage == AppLanguage.English ? 'en' : 'ar';
    final translationMap = Translations.data[languageKey];

    if (translationMap != null && translationMap.containsKey(key)) {
      return translationMap[key] ?? key;
    } else {
      return key;
    }
  }
  bool isCurrentLanguageArabic() {
    return _appLanguage == AppLanguage.Arabic;
  }
}