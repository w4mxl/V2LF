// 我的主题收藏列表页面

import 'package:flutter/material.dart';
import 'package:flutter_app/components/listview_favourite_topics.dart';
import 'package:flutter_app/model/web/node.dart';
import 'package:flutter_app/utils/constants.dart';
import 'package:flutter_app/utils/eventbus.dart';

class FavTopics extends StatefulWidget {
  @override
  _FavTopicsState createState() => _FavTopicsState();
}

class _FavTopicsState extends State<FavTopics> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    //监听登录事件
    bus.on(EVENT_NAME_FAV_COUNTS, (arg) {
      // do something
      setState(() {
        count = arg;
      });
    });

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('主题收藏 [$count]'),
      ),
      body: new FavTopicListView(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    bus.off(EVENT_NAME_FAV_COUNTS);
  }
}
