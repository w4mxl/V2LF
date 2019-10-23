import 'package:flutter/material.dart';
import 'package:flutter_app/utils/sp_helper.dart';

/// @author: wml
/// @date  : 2019-10-17 19:44
/// @email : mxl1989@gmail.com
/// @desc  : 主题颜色 theme、外观 appearance、字体 font

class DisplayModel extends ChangeNotifier {
  // 主题颜色
  MaterialColor _materialColor = themeColorMap[SpHelper.getThemeColor()];

  // 外观模式
  ThemeMode _themeMode = SpHelper.getThemeMode();

  // 字体选择
  String _fontName = SpHelper.getFontFamily();

  get materialColor => _materialColor;

  get themeMode => _themeMode;

  get fontName => _fontName;

  ThemeData themeDate({bool darkTheme: false}) => ThemeData(
        primarySwatch: _materialColor,
        fontFamily: _fontName,
        brightness: darkTheme ? Brightness.dark : Brightness.light,
      );

  switchColor(String newColor) {
    _materialColor = themeColorMap[newColor];
    notifyListeners();
    SpHelper.sp.setString(KEY_THEME_COLOR, newColor);
  }

  switchThemeMode(ThemeMode newThemeMode) {
    _themeMode = newThemeMode;
    notifyListeners();
    SpHelper.sp.setString(
        SP_THEME_MODE,
        (_themeMode == ThemeMode.system)
            ? THEME_MODE_SYSTEM
            : (_themeMode == ThemeMode.light ? THEME_MODE_LIGHT : THEME_MODE_DARK));
  }

  switchFont(String newFontName) {
    _fontName = newFontName;
    notifyListeners();
    SpHelper.sp.setString(SP_FONT_FAMILY, newFontName);
  }
}

const String THEME_MODE_SYSTEM = 'system';
const String THEME_MODE_LIGHT = 'light';
const String THEME_MODE_DARK = 'dark';

const Map<String, MaterialColor> themeColorMap = {
  'red': Colors.red,
  'pink': Colors.pink,
  'purple': Colors.purple,
  'deepPurple': Colors.deepPurple,
  'indigo': Colors.indigo,
  'blue': Colors.blue,
  'lightBlue': Colors.lightBlue,
  'cyan': Colors.cyan,
  'teal': Colors.teal,
  'green': Colors.green,
  'lightGreen': Colors.lightGreen,
  'lime': Colors.lime,
  'yellow': Colors.yellow,
  'amber': Colors.amber,
  'orange': Colors.orange,
  'deepOrange': Colors.deepOrange,
  'brown': Colors.brown,
  'blueGrey': Colors.blueGrey,
  //'grey': Colors.grey,
  //'black': Colors.black,
};
