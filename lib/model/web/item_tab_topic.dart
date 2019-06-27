// 主页tab下的item
class TabTopicItem {
  /// unread 未读
  /// read 已读
  String readStatus = 'unread';
  String memberId = '';
  String topicId = '';
  String avatar = '';
  String topicContent = '';
  String replyCount = '';
  String nodeId = '';
  String nodeName = '';
  String lastReplyMId = '';
  String lastReplyTime = '';

  TabTopicItem();

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map['readStatus'] = this.readStatus;
    map['memberId'] = this.memberId;
    map['topicId'] = this.topicId;
    map['avatar'] = this.avatar;
    map['topicContent'] = this.topicContent;
    map['replyCount'] = this.replyCount;
    map['nodeId'] = this.nodeId;
    map['nodeName'] = this.nodeName;
    map['lastReplyMId'] = this.lastReplyMId;
    map['lastReplyTime'] = this.lastReplyTime;
    return map;
  }

  TabTopicItem.fromMap(Map<String, dynamic> map) {
    this.readStatus = map['readStatus'];
    this.memberId = map['memberId'];
    this.topicId = map['topicId'];
    this.avatar = map['avatar'];
    this.topicContent = map['topicContent'];
    this.replyCount = map['replyCount'];
    this.nodeId = map['nodeId'];
    this.nodeName = map['nodeName'];
    this.lastReplyMId = map['lastReplyMId'];
    this.lastReplyTime = map['lastReplyTime'];
  }
}
