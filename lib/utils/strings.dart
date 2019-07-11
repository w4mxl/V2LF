import 'dart:io';

/// @author: wml
/// @date  : 2019/3/31 9:49 PM
/// @email : mxl1989@gmail.com
/// @desc  : string 常量

const String MyEventSettingChange = 'MyEventSettingChange'; // 设置中变动
const String MyEventTabsChange = 'MyEventTabsChange'; // 设置中自定义了主页 tabs
const String MyEventRefreshTopic = 'MyEventRefreshTopic'; // 话题详情页刷新
const String MyEventNodeIsFav = 'MyEventNodeIsFav'; // 节点是否被收藏
const String MyEventHasNewNotification = 'MyEventHasNewNotification'; // 检测到有新未读通知

class Strings {
  static String v2exHost = "https://www.v2ex.com";
  static String nodeDefaultImag = "https://www.v2ex.com/static/img/node_large.png";
  static String storeUrl = Platform.isIOS
      ? 'https://itunes.apple.com/cn/app/v2lf/id1455778208?mt=8'
      : 'https://play.google.com/store/apps/details?id=io.github.w4mxl.v2lf'; // todo
}
