import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/model/web/item_topic_reply.dart';
import 'package:flutter_app/model/web/item_topic_subtle.dart';
import 'package:flutter_app/model/web/model_topic_detail.dart';
import 'package:flutter_app/model/web/node.dart';
import 'package:flutter_app/network/dio_singleton.dart';
import 'package:flutter_app/page_node_topics.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:flutter_app/utils/url_helper.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

// 话题详情页+评论列表
class TopicDetails extends StatefulWidget {
  final int topicId;

  TopicDetails(this.topicId);

  @override
  _TopicDetailsState createState() => _TopicDetailsState();
}

class _TopicDetailsState extends State<TopicDetails> {
  bool isLogin = false;

  List<Action> actions = <Action>[
    // todo 多语言处理
    Action(id: 'reply', title: '回复', icon: Icons.reply),
    Action(id: 'favorite', title: '收藏', icon: Icons.favorite_border),
    Action(id: 'thank', title: '感谢', icon: Icons.thumb_up),
    Action(id: 'web', title: '浏览器', icon: Icons.explore),
    Action(id: 'link', title: '复制链接', icon: Icons.link),
    Action(id: 'copy', title: '复制内容', icon: Icons.content_copy),
    Action(id: 'share', title: '分享', icon: Icons.share),
  ];

  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();

    // check login state
    var spUsername = SpHelper.sp.getString(SP_USERNAME);
    if (spUsername != null && spUsername.length > 0) {
      isLogin = true;
    } else {
      // 没登录还不能'感谢'
      actions.removeAt(2);
    }
  }

  void _select(Action action) {
    switch (action.id) {
      case 'reply':
        print(action.title);
        showDialog(
            context: context,
            builder: (BuildContext context) => SimpleDialog(
                  contentPadding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 40.0),
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          child: Text('取消'),
                          onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                        ),
                        Expanded(
                            child: Center(
                                child: Text(
                          '回复',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ))),
                        IconButton(
                          icon: Icon(Icons.send),
                          onPressed: _isComposing ? () => _onTextMsgSubmitted(_textController.text) : null,
                        ),
                      ],
                    ),
                    Divider(),
                    TextField(
                      autofocus: true,
                      keyboardType: TextInputType.multiline,
                      // Setting maxLines=null makes the text field auto-expand when one
                      // line is filled up.
                      maxLines: null,
                      // maxLength: 200,
                      decoration: InputDecoration.collapsed(hintText: "(u_u) 请尽量让自己的回复有助于他人"),
                      controller: _textController,
                      onChanged: (String text) => setState(() => _isComposing = text.length > 0),
                      onSubmitted: _onTextMsgSubmitted,
                    ),
                  ],
                ));

        break;
      case 'favorite':
        print(action.title);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: const Color(0xFFD8D2D1),
      appBar: new AppBar(
        actions: <Widget>[
          Offstage(
            child: Row(
              children: <Widget>[
                IconButton(
                    icon: Icon(actions[0].icon),
                    onPressed: () {
                      _select(actions[0]);
                    }),
                IconButton(
                    icon: Icon(actions[1].icon),
                    onPressed: () {
                      _select(actions[1]);
                    }),
              ],
            ),
            offstage: !isLogin,
          ),
          PopupMenuButton<Action>(
            onSelected: _select,
            itemBuilder: (BuildContext context) {
              return actions.skip(2).map<PopupMenuItem<Action>>((Action action) {
                return PopupMenuItem<Action>(
                  value: action,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(action.icon),
                      ),
                      Text(action.title)
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: new TopicDetailView(widget.topicId),
    );
  }

  // Triggered when text is submitted (send button pressed).
  Future<Null> _onTextMsgSubmitted(String text) async {
    // Clear input text field.
    _textController.clear();
    _isComposing = false;
    Navigator.of(context, rootNavigator: true).pop();
    /*setState(() {

    });*/
    // todo send reply
  }
}

class Action {
  const Action({this.id, this.title, this.icon});

  final String id;
  final String title;
  final IconData icon;
}

class TopicDetailView extends StatefulWidget {
  final int topicId;

  TopicDetailView(this.topicId);

  @override
  _TopicDetailViewState createState() => _TopicDetailViewState();
}

class _TopicDetailViewState extends State<TopicDetailView> {
  int p = 1;
  int maxPage = 1;

  bool isUpLoading = false;

  TopicDetailModel _detailModel;
  List<ReplyItem> replyList = List();

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    // 获取数据
    getData();
    // 监听是否滑到了页面底部
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        print("滑到底部了，尝试加载更多...");
        if (replyList.length > 0 && p <= maxPage) {
          getData();
        } else {
          print("没有更多...");
        }
      }
    });
  }

  Future getData() async {
    if (!isUpLoading) {
      isUpLoading = true;
      TopicDetailModel topicDetailModel = await dioSingleton.getTopicDetailAndReplies(widget.topicId, p++);
      setState(() {
        _detailModel = topicDetailModel;
        replyList.addAll(topicDetailModel.replyList);
        isUpLoading = false;
        if ((p - 1) == 1) {
          // 其实是表示第一页的请求时
          maxPage = topicDetailModel.maxPage;
          print("####详情页-评论的页数：" + maxPage.toString());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_detailModel != null) {
      return RefreshIndicator(
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    // 详情view
                    detailCard(context),
                    // 评论view
                    commentCard(),
                  ],
                ),
              ),
              controller: _scrollController,
            ),
          ),
          onRefresh: _onRefresh);
    }
    return new Container(
        padding: const EdgeInsets.all(40.0),
        child: new Center(
          child: new CircularProgressIndicator(),
        ));
  }

  Card detailCard(BuildContext context) {
    return Card(
      elevation: 0.4,
      margin: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.all(10.0),
            child: new Row(
              children: <Widget>[
                // 头像
                GestureDetector(
                  child: new Container(
                    margin: const EdgeInsets.only(right: 10.0),
                    width: 40.0,
                    height: 40.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new NetworkImage('https:' + _detailModel.avatar),
                      ),
                    ),
                  ),
                  onTap: () => _launchURL(DioSingleton.v2exHost + '/member/' + _detailModel.createdId),
                ),
                new Expanded(
                    child: new Column(
                  children: <Widget>[
                    new Container(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: new Row(
                        children: <Widget>[
                          // 用户ID
                          GestureDetector(
                            child: new Text(
                              _detailModel.createdId,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              style: new TextStyle(fontSize: 14.0, color: Colors.black87, fontWeight: FontWeight.bold),
                            ),
                            onTap: () => _launchURL(DioSingleton.v2exHost + '/member/' + _detailModel.createdId),
                          ),
                          new Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.green,
                            size: 16.0,
                          ),
                          // 节点名称
                          GestureDetector(
                            child: new Text(
                              _detailModel.nodeName,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              style: new TextStyle(fontSize: 14.0, color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                            onTap: () => Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) =>
                                        NodeTopics(NodeItem(_detailModel.nodeId, _detailModel.nodeName)))),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          new Icon(
                            Icons.keyboard,
                            size: 16.0,
                            color: Colors.grey[500],
                          ),
                          new Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Html(
                              // todo 这里还有点展示问题(不能连在一行)，是flutter_html那边的问题
                              data: _detailModel.smallGray,
                              defaultTextStyle: TextStyle(color: Colors.grey[500], fontSize: 12.0),
                              onLinkTap: (url) {
                                if (UrlHelper.canLaunchInApp(context, url)) {
                                  return;
                                } else if (url.contains("/member/")) {
                                  // @xxx 需要补齐 base url
                                  url = DioSingleton.v2exHost + url;
                                  print(url);
                                }
                                _launchURL(url);
                              },
                            ),
//                                        new Text(
//                                          _detailModel.lastReplyTime,
//                                          style: new TextStyle(fontSize: 12.0, color: Colors.grey[500]),
//                                        ),
                          )
                        ],
                      ),
                    )
                  ],
                )),
                new Icon(
                  Icons.chat_bubble_outline,
                  size: 18.0,
                  color: Colors.grey,
                ),
                new Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: new Text(
                    _detailModel.replyCount,
                    style: new TextStyle(fontSize: 12.0, color: Colors.grey[700]),
                  ),
                )
              ],
            ),
          ),
          // topic title
          new Container(
            padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 5.0, right: 10.0),
            width: 500.0,
            child: new Text(
              _detailModel.topicTitle,
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
            padding: const EdgeInsets.all(10.0),
            child: Html(
              data: _detailModel.content,
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
          // 附言
          Offstage(
            offstage: _detailModel.subtleList.length == 0,
            child: Column(
                children:
                _detailModel.subtleList.map((TopicSubtleItem subtle) {
                  return _buildSubtle(subtle);
                }).toList()),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtle(TopicSubtleItem subtle) {
    return Column(
      children: <Widget>[
        Divider(height: 0,),
        Container(
          color: const Color(0xFFfffff9),
          padding: const EdgeInsets.only(left:10.0,right: 10.0,top: 4.0,bottom: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(subtle.fade,style: TextStyle(color: Colors.grey, fontSize: 12.0),),
              Html(
                data: subtle.content,
                padding: EdgeInsets.only(top: 4.0),
                defaultTextStyle: TextStyle(color: Colors.black87, fontSize: 12.0),
                onLinkTap: (url) {
                  _launchURL(url);
                },
              ),
            ],
          ),),
      ],
    );
  }

  StatelessWidget commentCard() {
    return replyList.length == 0
        ? Container(
            // 无回复
            padding: const EdgeInsets.only(top: 2.0, bottom: 10.0),
            child: Center(
              child: new Text("目前尚无回复", style: new TextStyle(color: const Color.fromRGBO(0, 0, 0, 0.25))),
            ))
        : Card(
            elevation: 0.0,
            margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
            color: Colors.white,
            child: ListView.separated(
              // +1 是展示 _buildLoadText
              itemCount: replyList.length + 1,
              itemBuilder: (context, index) {
                if (index == replyList.length) {
                  // 渲染到了最后一个item
                  return _buildLoadText();
                } else {
                  ReplyItem reply = replyList[index];
                  return GestureDetector(
                    child: new Container(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
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
                                  'https:' + reply.avatar,
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
                                      reply.userName,
                                      style: new TextStyle(fontSize: 14.0, color: Colors.grey, fontWeight: FontWeight.bold),
                                    ),
                                    new Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: new Text(
                                        reply.lastReplyTime,
                                        style: new TextStyle(
                                          color: const Color(0xFFcccccc),
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                new Container(
                                    padding: const EdgeInsets.only(bottom: 10.0, top: 5.0),
                                    // 评论内容
                                    child: Html(
                                      data: reply.content,
                                      defaultTextStyle: TextStyle(color: Colors.black, fontSize: 14.0),
                                      onLinkTap: (url) {
                                        if (UrlHelper.canLaunchInApp(context, url)) {
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
                    onTap: () {
                      Fluttertoast.showToast(
                          msg: 'clicked comment item',
                          toastLength: Toast.LENGTH_SHORT,
                          timeInSecForIos: 1,
                          gravity: ToastGravity.BOTTOM);
                    },
                  );
                }
              },
              separatorBuilder: (context, index) {
                return new Container(
                  margin: const EdgeInsets.only(left: 45.0),
                  width: 300.0,
                  height: 0.2,
                  color: Colors.black87,
                );
              },
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
            ),
          );
  }

  Widget _buildLoadText() {
    return Container(
      padding: const EdgeInsets.all(18.0),
      child: Center(
        child: Text(p <= maxPage ? "正在加载第" + p.toString() + "页..." : "---- 🙄 ----"),
      ),
    );
  }

  //刷新数据,重新设置future就行了
  Future _onRefresh() async {
    print("刷新数据...");
    p = 1;
    TopicDetailModel topicDetailModel = await dioSingleton.getTopicDetailAndReplies(widget.topicId, p++);
    setState(() {
      _detailModel = topicDetailModel;
      replyList.clear();
      replyList.addAll(topicDetailModel.replyList);
      if (p == 2) {
        maxPage = topicDetailModel.maxPage;
        print("####详情页-评论的页数：" + maxPage.toString());
      }
    });
  }
}

// 外链跳转
_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true); // , statusBarBrightness: Brightness.light
  } else {
    Fluttertoast.showToast(
        msg: 'Could not launch $url', toastLength: Toast.LENGTH_SHORT, timeInSecForIos: 1, gravity: ToastGravity.BOTTOM);
  }
}
