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
    final map = Map<String, dynamic>();
    map['memberId'] = this.memberId;
    map['topicId'] = this.topicId;
    map['avatar'] = this.avatar;
    map['topicContent'] = this.topicContent;
    map['nodeId'] = this.nodeId;
    map['nodeName'] = this.nodeName;
    return map;
  }

  RecentReadTopicItem.fromMap(Map<String, dynamic> map) {
    this.memberId = map['memberId'];
    this.topicId = map['topicId'];
    this.avatar = map['avatar'];
    this.topicContent = map['topicContent'];
    this.nodeId = map['nodeId'];
    this.nodeName = map['nodeName'];
  }
}
