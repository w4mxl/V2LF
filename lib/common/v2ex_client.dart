import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:flutter_app/utils/utils.dart';

/// @author: wml
/// @date  : 2019/4/12 11:56 PM
/// @email : mxl1989@gmail.com
/// @desc  : 存放 app 通用方法

class V2exClient{

  static Future logout() async {
    // 清除 cookie
    String cookiePath = await Utils.getCookiePath();
    PersistCookieJar cookieJar = new PersistCookieJar(dir: cookiePath);
    cookieJar.deleteAll();
    // 清除用户信息
    SpHelper.sp.remove(SP_USERNAME);
    SpHelper.sp.remove(SP_AVATAR);
  }
}