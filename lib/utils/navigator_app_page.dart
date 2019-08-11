import 'package:flutter/material.dart';
import 'package:flutter_app/pages/page_node_topics.dart';
import 'package:flutter_app/pages/page_topic_detail.dart';

// app 内页面跳转

class NavigatorInApp {
  // => 帖子详情页 TopicDetails
  static toTopicDetails(BuildContext context, String topicId) {
    Navigator.push(context, new MaterialPageRoute(builder: (context) => TopicDetails(topicId)));
  }

  // => 特定节点话题列表页面 NodeTopics
  static toNodeTopics(BuildContext context, String nodeId) {
    Navigator.push(context, new MaterialPageRoute(builder: (context) => NodeTopics(nodeId)));
  }
}
