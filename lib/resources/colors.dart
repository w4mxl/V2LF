import 'package:flutter/material.dart';

class ColorT {
  static MaterialColor appMainColor = Colors.blueGrey;

  static bool isDark = false; // 用来判断是否 dark mode

  static const Color gray_66 = Color(0xFF666666); //102
  static const Color gray_99 = Color(0xFF999999); //153
}

Map<String, MaterialColor> themeColorMap = {
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
