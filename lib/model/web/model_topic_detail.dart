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

  String content = '';
  List<TopicSubtleItem> subtleList; // 附言

  int maxPage = 1; // 共有多少页数评论

  List<ReplyItem> replyList;
}