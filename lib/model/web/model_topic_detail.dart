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

  String token = ''; // 用于操作：对主题收藏、感谢
  // <a href="#;" onclick="if (confirm('确定不想再看到这个主题？')) { location.href = '/ignore/topic/583319?once=62479'; }"
  // class="op" style="user-select: auto;">忽略主题</a>
  // String once = ''; // 用于操作：对忽略主题、对评论发送感谢
  bool isFavorite = false; // 是否已收藏
  bool isThank = false; // 是否已感谢

  int maxPage = 1; // 共有多少页数评论

  List<ReplyItem> replyList;
}
