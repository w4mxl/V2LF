// 我的主题收藏列表页面

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/components/listview_favourite_topics.dart';
import 'package:flutter_app/i10n/localization_intl.dart';
import 'package:flutter_app/utils/events.dart';

class FavTopics extends StatefulWidget {
  @override
  _FavTopicsState createState() => _FavTopicsState();
}

class _FavTopicsState extends State<FavTopics> {
  int count = 0;
  StreamSubscription loginSubscription;

  @override
  Widget build(BuildContext context) {
    //监听事件
    loginSubscription = eventBus.on<MyEventFavCounts>().listen((event) {
      setState(() {
        count = int.parse(event.count);
      });
    });

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(MyLocalizations.of(context).favorites +' [ $count ]'),
      ),
      body: new FavTopicListView(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    loginSubscription.cancel();
  }
}
