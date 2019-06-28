/// @author: wml
/// @date  : 2019-06-03 14:17
/// @email : mxl1989@gmail.com
/// @desc  : 近期已读主题列表页面

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_app/common/database_helper.dart';
import 'package:flutter_app/components/listview_tab_topic.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/model/web/item_tab_topic.dart';

class RecentReadTopicsPage extends StatefulWidget {
  @override
  _RecentReadTopicsPageState createState() => _RecentReadTopicsPageState();
}

class _RecentReadTopicsPageState extends State<RecentReadTopicsPage> {
  bool hasData = false;
  var databaseHelper = DatabaseHelper.instance;

  Future<List<TabTopicItem>> topicListFuture;

  Future<List<TabTopicItem>> getTopics() async {
    return await databaseHelper.getRecentReadTopics();
  }

  @override
  void initState() {
    super.initState();
    topicListFuture = getTopics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("近期已读"),
        actions: <Widget>[
          IconButton(
            tooltip: 'Clear Recent Read',
            icon: Icon(Icons.delete_sweep),
            onPressed: () {
              if (hasData) {
                showDialog(
                    context: (context),
                    builder: (BuildContext context) => AlertDialog(
                          content: Text('你确定要清空已读记录吗?'),
                          actions: <Widget>[
                            FlatButton(
                                onPressed: () => Navigator.of(context, rootNavigator: true).pop(), child: Text('取消')),
                            FlatButton(
                                onPressed: () async {
                                  Navigator.of(context, rootNavigator: true).pop();
                                  // todo 清空已读数据库
                                  await databaseHelper.deleteAll();
                                  setState(() {
                                    topicListFuture = getTopics();
                                  });
                                },
                                child: Text('确定')),
                          ],
                        ));
              }
            },
          )
        ],
      ),
      body: FutureBuilder<List<TabTopicItem>>(
          future: topicListFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              hasData = snapshot.data.length > 0;
              // 近期已读列表不用灰色显示
              snapshot.data.forEach((TabTopicItem topic) {
                topic.readStatus = 'unread';
              });

              return snapshot.data.length > 0
                  ? new Container(
                      child: ListView.builder(
                          itemBuilder: (context, index) => TopicItemView(snapshot.data[index]),
                          itemCount: snapshot.data.length))
                  : Center(
                      child: Text("NO READ YET!"),
                    );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(S.of(context).oops),
              );
            }
            return Center(
              child: Platform.isIOS ? CupertinoActivityIndicator() : CircularProgressIndicator(),
            );
          }),
    );
  }
}
