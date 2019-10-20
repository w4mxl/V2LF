import 'package:flutter/material.dart';
import 'package:flutter_app/theme/theme_data.dart';
import 'package:flutter_app/utils/sp_helper.dart';

/// @author: wml
/// @date  : 2019-10-17 19:44
/// @email : mxl1989@gmail.com
/// @desc  : 主题颜色 theme、外观 appearance、字体 font

class DisplayModel extends ChangeNotifier {
  // 主题颜色
  MaterialColor _materialColor = themeColorMap[SpHelper.getThemeColor()];
  // 外观模式
  int _nightMode = SpHelper.getNightMode();
  // 字体选择
  String _fontName = SpHelper.getFontFamily();

  get materialColor => _materialColor;
  get fontName => _fontName;

  switchColor(String newColor) {
    _materialColor = themeColorMap[newColor];
    notifyListeners();
    SpHelper.sp.setString(KEY_THEME_COLOR, newColor);
  }

  switchFont(String newFontName) {
    _fontName = newFontName;
    notifyListeners();
    SpHelper.sp.setString(SP_FONT_FAMILY, newFontName);
  }
}
