import 'package:flutter/material.dart';
import 'package:flutter_app/utils/navigator_app_page.dart';

// url 判断、拼接

class UrlHelper {
  static bool canLaunchInApp(BuildContext context, String url) {
    if (url.contains("https://www.v2ex.com/t/")) {
      NavigatorInApp.toTopicDetails(context, url.replaceAll("https://www.v2ex.com/t/", ""));
      return true;
    } else if (url.startsWith('/t/')) {
      // <a href="/t/484922#reply11">
      NavigatorInApp.toTopicDetails(context, url.replaceFirst("/t/", "").split('#')[0]);
      return true;
    } else if (url.startsWith('/go/')) {
      NavigatorInApp.toNodeTopics(context, url.replaceFirst("/go/", ""));
      return true;
    }

    return false;
  }
}
