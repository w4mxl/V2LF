// 近期已读下的item
class RecentReadTopicItem {
  String memberId = '';
  String topicId = '';
  String avatar = '';
  String topicContent = '';
  String nodeId = '';
  String nodeName = '';

  RecentReadTopicItem({this.topicId, this.topicContent, this.avatar, this.memberId, this.nodeName, this.nodeId});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['memberId'] = memberId;
    map['topicId'] = topicId;
    map['avatar'] = avatar;
    map['topicContent'] = topicContent;
    map['nodeId'] = nodeId;
    map['nodeName'] = nodeName;
    return map;
  }

  RecentReadTopicItem.fromMap(Map<String, dynamic> map) {
    memberId = map['memberId'];
    topicId = map['topicId'];
    avatar = map['avatar'];
    topicContent = map['topicContent'];
    nodeId = map['nodeId'];
    nodeName = map['nodeName'];
  }
}
