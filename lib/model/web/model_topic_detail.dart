import 'package:flutter_app/model/web/item_topic_reply.dart';
import 'package:flutter_app/model/web/item_topic_subtle.dart';

/// @author: wml
/// @date  : 2019/2/27 12:45
/// @email : mxl1989@gmail.com
/// @desc  : 帖子详情（含评论）数据

class TopicDetailModel {
  String topicId = '';
  String nodeId = '';
  String nodeName = '';
  String topicTitle = '';
  String createdId = '';
  String avatar = '';
  String replyCount = '0';
  String smallGray = '';

  String content = ''; // 纯文本
  String contentRendered = ''; // 带html标签
  List<TopicSubtleItem> subtleList; // 附言

  String token = ''; // 用于收藏、感谢、忽略等操作
  bool isFavorite = false; // 是否已收藏
  bool isThank = false; // 是否已感谢

  int maxPage = 1; // 共有多少页数评论

  List<ReplyItem> replyList;
}