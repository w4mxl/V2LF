import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> getSP() async {
  SharedPreferences sp;
  if (sp == null) {
    sp = await SharedPreferences.getInstance();
  }
  return sp;
}
