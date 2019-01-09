import 'package:flutter/material.dart';
import 'package:flutter_app/utils/navigator_app_page.dart';

// url 判断、拼接

class UrlHelper {
  static canLaunchInApp(BuildContext context, String url) {
    if (url.contains("https://www.v2ex.com/t/")) {
      NavigatorInApp.toTopicDetails(
          context, int.parse(url.replaceAll("https://www.v2ex.com/t/", "")));
      return true;
    }

    return false;
  }
}
