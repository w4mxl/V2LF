/// @author: wml
/// @date  : 2019-10-24 11:38
/// @email : mxl1989@gmail.com
/// @desc  : APP语言状态

import 'package:flutter/material.dart';
import 'package:flutter_app/utils/sp_helper.dart';

// 方便存取的常量名称；
const String LOCALE_SYSTEM = 'system';
const String LOCALE_ZH = 'zh';
const String LOCALE_EN = 'en';

class LocaleModel extends ChangeNotifier {
  Locale _locale = SpHelper.getLocale();

  get locale => _locale;

  switchLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
    SpHelper.sp.setString(
        SP_LANGUAGE, (newLocale == null ? LOCALE_SYSTEM : (newLocale.languageCode == LOCALE_ZH ? LOCALE_ZH : LOCALE_EN)));
  }
}
