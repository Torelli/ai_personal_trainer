import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  Locale _appLocale = const Locale('en');

  Locale get appLocal => _appLocale;
  fetchLocale() async {
    String deviceLocale =
        Platform.localeName.split('_')[0] == 'pt' ? 'pt' : 'en';
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      _appLocale = Locale(deviceLocale);
      return Null;
    }
    _appLocale = Locale(prefs.getString('language_code').toString());
    return Null;
  }

  void changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      return;
    }
    if (type == const Locale("pt")) {
      _appLocale = const Locale("pt");
      await prefs.setString('language_code', 'pt');
      await prefs.setString('countryCode', '');
    } else {
      _appLocale = const Locale("en");
      await prefs.setString('language_code', 'en');
      await prefs.setString('countryCode', 'US');
    }
    notifyListeners();
  }
}
