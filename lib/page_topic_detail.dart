import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/model/resp_replies.dart';
import 'package:flutter_app/model/resp_topics.dart';
import 'package:flutter_app/network/api_network.dart';
import 'package:flutter_app/network/dio_singleton.dart';
import 'package:flutter_app/utils/time_base.dart';
import 'package:flutter_app/utils/url_helper.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

// 话题详情页+评论列表
class TopicDetails extends StatelessWidget {
  //final TabTopicItem topic;
  final int topicId;

  TopicDetails(this.topicId);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: const Color(0xFFD8D2D1),
      appBar: new AppBar(),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: new TopicDetailView(topicId),
        ),
      ),
    );
  }
}

class Merged {
  final TopicsResp topicsResp;
  final RepliesResp repliesResp;

  Merged({this.topicsResp, this.repliesResp});
}

class TopicDetailView extends StatefulWidget {
  final int topicId;

  TopicDetailView(this.topicId);

  @override
  _TopicDetailViewState createState() => _TopicDetailViewState();
}

class _TopicDetailViewState extends State<TopicDetailView> {
  var _futureBuilderFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureBuilderFuture = Future.wait(
            [NetworkApi.getTopicDetails(widget.topicId), NetworkApi.getReplies(widget.topicId)])
        .then((response) => new Merged(topicsResp: response[0], repliesResp: response[1]));
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new FutureBuilder(
          future: _futureBuilderFuture,
          builder: (context, AsyncSnapshot<Merged> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return new Container(
                  padding: const EdgeInsets.all(40.0),
                  child: new Center(
                    child: new CircularProgressIndicator(),
                  ),
                );
              default:
                if (snapshot.hasError)
                  return new Center(
                    child: new Text("Error：${snapshot.error}"),
                  );
                else {
                  return Column(
                    children: <Widget>[
                      new Card(
                        elevation: 0.4,
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
                                            snapshot.data.topicsResp.list[0].member.avatar_large),
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
                                              snapshot.data.topicsResp.list[0].member.username,
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
                                              snapshot.data.topicsResp.list[0].node.title,
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
                                                new TimeBase(snapshot
                                                        .data.topicsResp.list[0].last_modified)
                                                    .getShowTime(), // todo:   + "，100次点击"
                                                style: new TextStyle(
                                                    fontSize: 12.0, color: Colors.grey[500]),
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
                                      snapshot.data.topicsResp.list[0].replies.toString(),
                                      style: new TextStyle(fontSize: 12.0, color: Colors.grey[700]),
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
                                snapshot.data.topicsResp.list[0].title,
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
                              child: Html(
                                data: snapshot.data.topicsResp.list[0].content_rendered,
                                defaultTextStyle: TextStyle(color: Colors.black87, fontSize: 14.0),
                                onLinkTap: (url) {
                                  _launchURL(url);
                                },
                              ),
                              /*MarkdownBody(
                          data: result.data.list[0].content, onTapLink: (href) => _launchURL(href)),*/
                              /*child: new Text(
                        result.data.list[0].content,
                        softWrap: true,
                        style: new TextStyle(color: Colors.black87, fontSize: 14.0),
                      ),*/
                            ),
                          ],
                        ),
                      ),
                      snapshot.data.repliesResp.list.length == 0
                          ? Center(
                              child: new Text("目前尚无回复",
                                  style: new TextStyle(color: const Color.fromRGBO(0, 0, 0, 0.25))),
                            )
                          : new Card(
                              elevation: 0.0,
                              margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
                              color: Colors.white,
                              child: ListView.separated(
                                itemBuilder: (context, index) {
                                  Reply reply = snapshot.data.repliesResp.list[index];
                                  return GestureDetector(
                                    onTap: () {
                                      print('wml');
                                    },
                                    child: new Container(
                                      padding:
                                          const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
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
                                                    // 评论内容
                                                    child: Html(
                                                      data: reply.content_rendered,
                                                      defaultTextStyle: TextStyle(
                                                          color: Colors.black, fontSize: 14.0),
                                                      onLinkTap: (url) {
                                                        if (UrlHelper.canLaunchInApp(
                                                            context, url)) {
                                                          return;
                                                        } else if (url.contains("/member/")) {
                                                          // @xxx 需要补齐 base url
                                                          url = DioSingleton.v2exHost + url;
                                                          print(url);
                                                        }
                                                        _launchURL(url);
                                                      },
                                                    )),
                                              ],
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return new Container(
                                    margin: const EdgeInsets.only(left: 45.0),
                                    width: 300.0,
                                    height: 0.2,
                                    color: Colors.black87,
                                  );
                                },
                                itemCount: snapshot.data.repliesResp.list.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                              ),
                            )
                    ],
                  );
                }
            }
          }),
    );
  }
}

// 外链跳转
_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true, statusBarBrightness: Brightness.light);
  } else {
    Fluttertoast.showToast(
        msg: 'Could not launch $url',
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIos: 1,
        gravity: ToastGravity.BOTTOM);
  }
}
