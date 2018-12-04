// 话题详情页+评论列表

import 'package:flutter/material.dart';
import 'package:flutter_app/model/RepliesResp.dart';
import 'package:flutter_app/model/TopicsResp.dart';
import 'package:flutter_app/model/web/TabTopicItem.dart';
import 'package:flutter_app/network/NetworkApi.dart';
import 'package:flutter_app/utils/TimeBase.dart';

class TopicDetails extends StatelessWidget {
  final TabTopicItem topic;

  TopicDetails(this.topic);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Topic detils',
      theme: new ThemeData(
        primaryColor: Colors.blueGrey,
      ),
      home: new Scaffold(
          appBar: new AppBar(
            // title: new Text(topic.title),
            leading: new GestureDetector(
              onTap: () {
                print('back');
                Navigator.pop(context);
              },
              child: new Icon(Icons.arrow_back),
            ),
          ),
          body: new Container(
            color: const Color(0xFFD8D2D1),
            child: new ListView(
              children: <Widget>[
                /// topic content
                new TopicContentView(int.parse(topic.topicId)),

                /// topic replies
                new RepliesView(int.parse(topic.topicId)),
              ],
            ),
          )),
    );
  }
}

class TopicContentView extends StatelessWidget {
  final int topicId;

  TopicContentView(this.topicId);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new FutureBuilder<TopicsResp>(
          future: NetworkApi.getTopicDetails(topicId),
          builder: (context, result) {
            if (result.hasData) {
              return new Card(
                margin: const EdgeInsets.all(8.0),
                color: Colors.white,
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                      padding: const EdgeInsets.all(10.0),
                      child: new Row(
                        children: <Widget>[
                          new Container(
                            margin: const EdgeInsets.only(right: 10.0),
                            width: 40.0,
                            height: 40.0,
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                fit: BoxFit.fill,
                                image: new NetworkImage('https:' +
                                    result.data.list[0].member.avatar_large),
                              ),
                            ),
                          ),
                          new Expanded(
                              child: new Column(
                            children: <Widget>[
                              new Container(
                                padding: const EdgeInsets.only(bottom: 2.0),
                                child: new Row(
                                  children: <Widget>[
                                    new Text(
                                      result.data.list[0].member.username,
                                      textAlign: TextAlign.left,
                                      maxLines: 1,
                                      style: new TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    new Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Colors.green,
                                      size: 16.0,
                                    ),
                                    new Text(
                                      result.data.list[0].node.title,
                                      textAlign: TextAlign.left,
                                      maxLines: 1,
                                      style: new TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  new Icon(
                                    Icons.keyboard,
                                    size: 16.0,
                                    color: Colors.grey[500],
                                  ),
                                  new Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: new Text(
                                        new TimeBase(result
                                                    .data.list[0].last_modified)
                                                .getShowTime() +
                                            "，100次点击", // todo
                                        style: new TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.grey[500]),
                                      ))
                                ],
                              )
                            ],
                          )),
                          new Icon(
                            Icons.comment,
                            size: 18.0,
                            color: Colors.grey,
                          ),
                          new Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: new Text(
                              result.data.list[0].replies.toString(),
                              style: new TextStyle(
                                  fontSize: 12.0, color: Colors.grey[700]),
                            ),
                          )
                        ],
                      ),
                    ),
                    // topic title
                    new Container(
                      padding: const EdgeInsets.only(
                          left: 10.0, top: 10.0, bottom: 5.0, right: 10.0),
                      width: 500.0,
                      child: new Text(
                        result.data.list[0].title,
                        softWrap: true,
                        style: new TextStyle(
                          color: Colors.black87,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // topic content
                    new Container(
                      padding: const EdgeInsets.only(
                          left: 10.0, top: 10.0, bottom: 10.0, right: 10.0),
                      child: new Text(
                        result.data.list[0].content,
                        softWrap: true,
                        style: new TextStyle(
                            color: Colors.black87, fontSize: 14.0),
                      ),
                    ),
                  ],
                ),
              );
            }

            return new Container(width: 0.0, height: 0.0);
          }),
    );
  }
}

class RepliesView extends StatelessWidget {
  final int topicId;

  RepliesView(this.topicId);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new FutureBuilder<RepliesResp>(
          future: NetworkApi.getReplies(topicId),
          builder: (context, result) {
            if (result.hasData) {
              // 返回数据为空
              if (result.data.list.length == 0) {
                return new Center(
                  child: new Text("目前尚无回复",
                      style: new TextStyle(
                          color: const Color.fromRGBO(0, 0, 0, 0.25))),
                );
              }
              return new Card(
                margin:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                color: Colors.white,
                child: new Column(
                  children: result.data.list.map((Reply reply) {
                    return new Container(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 10.0),
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Container(
                            margin: const EdgeInsets.only(right: 10.0),
                            width: 25.0,
                            height: 25.0,
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                fit: BoxFit.fill,
                                image: new NetworkImage(
                                  'https:' + reply.member.avatar_large,
                                ),
                              ),
                            ),
                          ),
                          new Expanded(
                              child: new Container(
                            margin: const EdgeInsets.only(top: 2.0),
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Row(
                                  children: <Widget>[
                                    new Text(
                                      reply.member.username,
                                      style: new TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    new Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: new Text(
                                        new TimeBase(reply.last_modified)
                                            .getShowTime(),
                                        style: new TextStyle(
                                          color: const Color(0xFFcccccc),
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                new Container(
                                  padding: const EdgeInsets.only(
                                      bottom: 10.0, top: 5.0),
                                  child: new Text(
                                    reply.content.toString(),
                                    softWrap: true,
                                    overflow: TextOverflow.clip,
                                    style: new TextStyle(
                                        fontSize: 14.0, color: Colors.black),
                                  ),
                                ),
                                new Container(
                                  width: 300.0,
                                  height: 0.2,
                                  color: Colors.black87,
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            } else if (result.hasError) {
              return new Center(
                child: new Text("${result.error}"),
              );
            }

            return new Container(
              padding: const EdgeInsets.all(10.0),
              child: new Center(
                child: new CircularProgressIndicator(),
              ),
            );
          }),
    );
  }
}
