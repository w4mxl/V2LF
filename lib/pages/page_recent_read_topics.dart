/// @author: wml
/// @date  : 2019-06-03 14:17
/// @email : mxl1989@gmail.com
/// @desc  : 近期已读主题列表页面

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/common/database_helper.dart';
import 'package:flutter_app/components/circle_avatar.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/models/web/item_recent_read_topic.dart';

import 'page_topic_detail.dart';

class RecentReadTopicsPage extends StatefulWidget {
  @override
  _RecentReadTopicsPageState createState() => _RecentReadTopicsPageState();
}

class _RecentReadTopicsPageState extends State<RecentReadTopicsPage> {
  bool hasData = false;
  var databaseHelper = DatabaseHelper.instance;

  Future<List<RecentReadTopicItem>> topicListFuture;

  Future<List<RecentReadTopicItem>> getTopics() async {
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
                            FlatButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop(), child: Text('取消')),
                            FlatButton(
                                onPressed: () async {
                                  Navigator.of(context, rootNavigator: true).pop();
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
      body: FutureBuilder<List<RecentReadTopicItem>>(
          future: topicListFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              hasData = snapshot.data.length > 0;

              return snapshot.data.length > 0
                  ? new Container(
                      child: ListView.builder(
                          itemBuilder: (context, index) => TopicItemView(snapshot.data[index]), itemCount: snapshot.data.length))
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

/// topic item view
class TopicItemView extends StatefulWidget {
  final RecentReadTopicItem topic;

  TopicItemView(this.topic);

  @override
  _TopicItemViewState createState() => _TopicItemViewState();
}

class _TopicItemViewState extends State<TopicItemView> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TopicDetails(widget.topic.topicId)),
        );
      },
      child: new Container(
        padding: EdgeInsets.only(left: 18.0, right: 18.0, top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(
              widget.topic.topicContent,
              // 区分：已读 or 未读 todo
              style: TextStyle(
                fontSize: 17,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // 头像
                        CircleAvatarWithPlaceholder(
                          imageUrl: widget.topic.avatar,
                          size: 21,
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Text(
                          widget.topic.memberId,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          style: new TextStyle(fontSize: 13.0, color: Theme.of(context).unselectedWidgetColor),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 1, bottom: 1, left: 4, right: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: new Text(
                            widget.topic.nodeName,
                            style: new TextStyle(
                              fontSize: 12.0,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Divider(
              height: 0,
            ),
          ],
        ),
      ),
    );
  }
}
