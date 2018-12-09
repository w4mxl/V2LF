// 特定节点话题列表页面

import 'package:flutter/material.dart';
import 'package:flutter_app/components/node_topic_listview.dart';
import 'package:flutter_app/model/web/node.dart';

class NodeTopics extends StatefulWidget {
  final NodeItem node;

  NodeTopics(this.node);

  @override
  _NodeTopicsState createState() => _NodeTopicsState();
}

class _NodeTopicsState extends State<NodeTopics> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.node.nodeName),
      ),
      body: new NodeTopicListView(widget.node.nodeId),
    );
  }
}
