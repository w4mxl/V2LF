import 'item_profile_recent_reply.dart';
import 'item_profile_recent_topic.dart';

/// @author: wml
/// @date  : 2019-09-18 17:07
/// @email : mxl1989@gmail.com
/// @desc  : 用户个人信息页：个人信息；最近主题；最近回复

class MemberProfileModel {
  String avatar = '';
  String userName = '';
  String sign = ''; // 签名
  String company = ''; // 所在公司 / 职位
  String memberInfo = ''; // V2EX 第 62179 号会员，加入于 2014-05-08 13:33:07 +08:00

  List<Clips> clips; // 网站、位置、社交媒体id 等
  String memberIntro = ''; // 个人简介

  String token = '';
  bool isFollow = false; // 是否关注
  bool isBlock = false; // 是否屏蔽

  List<ProfileRecentTopicItem> topicList; // 近期主题
  List<ProfileRecentReplyItem> replyList; // 近期回复
}

class Clips {
  String url = '';
  String icon = '';
  String name = '';
}
