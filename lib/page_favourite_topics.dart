// 我的主题收藏列表页面

import 'package:flutter/material.dart';
import 'package:flutter_app/components/listview_favourite_topics.dart';
import 'package:flutter_app/model/web/node.dart';

class FavTopics extends StatefulWidget {

  @override
  _FavTopicsState createState() => _FavTopicsState();
}

class _FavTopicsState extends State<FavTopics> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('我的收藏 · 161'),
      ),
      body: new FavTopicListView(),
    );
  }
}
