import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info/device_info.dart';
import 'package:ovprogresshud/progresshud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static IosDeviceInfo iosInfo;
  static AndroidDeviceInfo androidInfo;

  // 获取设备系统版本号
  static deviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.version.sdkInt}');
    } else if (Platform.isIOS) {
      iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.systemVersion}');
    }
  }

  static Future<String> getCookiePath() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path + "/v2lf_cookie";
    Directory dir = new Directory(tempPath);
    bool b = await dir.exists();
    if (!b) {
      dir.createSync(recursive: true);
    }
    return tempPath;
  }

  // 外链跳转
  static launchURL(String url) async {
    // 处理有些链接是 //xxxx 形式
    if (url.startsWith('//')) {
      url = 'https:$url';
    }

    if (await canLaunch(url)) {
      await launch(url, statusBarBrightness: Platform.isIOS ? Brightness.light : null);
    } else {
      Progresshud.showErrorWithStatus('Could not launch $url');
    }
  }

  // 头像转成大图
  static String avatarLarge(String avatar) {
    //// 获取到的是24*24大小，改成73*73
    ////cdn.v2ex.com/gravatar/3896b6baf91ec1933c38f370964647b7?s=24&d=retro%0A
    //cdn.v2ex.com/gravatar/3896b6baf91ec1933c38f370964647b7?s=32&d=retro 登录后获取的头像（移动端样式下）
    //cdn.v2ex.com/avatar/d8fe/ee94/193847_normal.png?m=1477551256
    //cdn.v2ex.com/avatar/d0df/5707/71698_mini.png?m=1408718789
    var regExp1 = RegExp(r's=24|s=32');
    var regExp2 = RegExp(r'normal');
    var regExp3 = RegExp(r'mini');
    if (avatar.contains(regExp1)) {
      avatar = avatar.replaceFirst(regExp1, 's=73');
    } else if (avatar.contains(regExp2)) {
      avatar = avatar.replaceFirst(regExp2, 'large');
    } else if (avatar.contains(regExp3)) {
      avatar = avatar.replaceFirst(regExp3, 'large');
    }

    return avatar;
  }
}
