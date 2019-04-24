import 'package:flutter_app/model/web/item_topic_reply.dart';

/// @author: wml
/// @date  : 2019/4/24 18:14
/// @email : mxl1989@gmail.com
/// @desc  : 帖子评论数据

class TopicRepliesModel {
  int maxPage = 1; // 共有多少页数评论
  List<ReplyItem> replyList;
}
