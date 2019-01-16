import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> getSP() async {
  SharedPreferences sp;
  if (sp == null) {
    sp = await SharedPreferences.getInstance();
  }
  return sp;
}

const List<String> poems = [
  '晚食以当肉，安步以当车',
  '月上柳梢头，人约黄昏后',
  '春悄悄，夜迢迢',
  '露从今夜白，月是故乡明',
  '君不见走马川行雪海边',
  '问君何能尔，心远地自偏',
  '白发催年老，青阳逼岁除',
  '风不定，人初静',
  '朝而往，暮而归',
  '夕阳无限好，只是近黄昏',
  '一竿风月，一蓑烟雨',
  '潮生理棹，潮平系缆'
];
