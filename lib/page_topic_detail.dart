import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/model/web/item_topic_reply.dart';
import 'package:flutter_app/model/web/item_topic_subtle.dart';
import 'package:flutter_app/model/web/model_topic_detail.dart';
import 'package:flutter_app/model/web/node.dart';
import 'package:flutter_app/network/dio_singleton.dart';
import 'package:flutter_app/page_node_topics.dart';
import 'package:flutter_app/resources/colors.dart';
import 'package:flutter_app/utils/events.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:flutter_app/utils/url_helper.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//final key = GlobalKey<_TopicDetailViewState>();

bool isLogin = false;

// 话题详情页+评论列表
class TopicDetails extends StatefulWidget {
  final String topicId;

  TopicDetails(this.topicId);

  @override
  _TopicDetailsState createState() => _TopicDetailsState();
}

class _TopicDetailsState extends State<TopicDetails> {
  @override
  void initState() {
    super.initState();
    // check login state
    checkLoginState();
    print('initState');
  }

  checkLoginState() {
    var spUsername = SpHelper.sp.getString(SP_USERNAME);
    if (spUsername != null && spUsername.length > 0) {
      isLogin = true;
    } else {
      isLogin = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    //监听登录事件
    print('监听登录事件:' + (isLogin == true ? 'true' : 'false'));

    return new TopicDetailView(widget.topicId);
  }
}

class DialogOfComment extends StatefulWidget {
  final String topicId;
  final String initialValue;
  final void Function(String) onValueChange;

  DialogOfComment(this.topicId, this.initialValue, this.onValueChange);

  @override
  _DialogOfCommentState createState() => _DialogOfCommentState();
}

class _DialogOfCommentState extends State<DialogOfComment> {
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialValue;
    _isComposing = widget.initialValue.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
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
          decoration: InputDecoration.collapsed(hintText: "(u_u) 请尽量让回复有助于他人"),
          controller: _textController,
          onChanged: (String text) => setState(() {
                _isComposing = text.length > 0;
                widget.onValueChange(text);
              }),
          onSubmitted: _onTextMsgSubmitted,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Triggered when text is submitted (send button pressed).
  Future<Null> _onTextMsgSubmitted(String text) async {
    bool loginResult = await dioSingleton.replyTopic(widget.topicId, text);
    if (loginResult) {
      Fluttertoast.showToast(msg: '回复成功!', gravity: ToastGravity.CENTER);
      // Clear input text field.
      _textController.clear();
      widget.onValueChange("");
      _isComposing = false;
      Navigator.of(context, rootNavigator: true).pop();
      eventBus.fire(new MyEventRefreshTopic());
      //key.currentState._onRefresh();
    } else {
      print('帖子详情页面：回复失败');
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}

class TopicDetailView extends StatefulWidget {
  final String topicId;

  TopicDetailView(this.topicId);

  @override
  _TopicDetailViewState createState() => _TopicDetailViewState();
}

class _TopicDetailViewState extends State<TopicDetailView> {
  bool _saving = false;

  List<Action> actions = <Action>[
    Action(id: 'thank', title: '感谢', icon: FontAwesomeIcons.kissWinkHeart),
    Action(id: 'favorite', title: '收藏', icon: FontAwesomeIcons.star),
    Action(id: 'reply', title: '回复', icon: FontAwesomeIcons.reply),
    Action(id: 'web', title: '浏览器打开', icon: Icons.explore),
    Action(id: 'link', title: '复制链接', icon: Icons.link),
    Action(id: 'copy', title: '复制内容', icon: Icons.content_copy),
    Action(id: 'share', title: '分享', icon: Icons.share),
  ];

  String _lastEditCommentDraft = '';

  int p = 1;
  int maxPage = 1;

  bool isUpLoading = false;

  TopicDetailModel _detailModel;
  List<ReplyItem> replyList = List();

  ScrollController _scrollController = new ScrollController();
  bool showToTopBtn = false; //是否显示“返回到顶部”按钮

  @override
  void initState() {
    super.initState();
    // 获取数据
    getData();
    // 监听是否滑到了页面底部
    _scrollController.addListener(() {
      // print(_scrollController.offset); //打印滚动位置
      if (_scrollController.offset < 1000 && showToTopBtn) {
        setState(() {
          showToTopBtn = false;
        });
      } else if (_scrollController.offset >= 1000 && showToTopBtn == false) {
        setState(() {
          showToTopBtn = true;
        });
      }

      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        print("滑到底部了，尝试加载更多...");
        if (replyList.length > 0 && p <= maxPage) {
          getData();
        } else {
          print("没有更多...");
        }
      }
    });
    //监听自定义主页Tab的变动
    eventBus.on<MyEventRefreshTopic>().listen((event) {
      _onRefresh();
      print("eventBus.on<MyEventRefreshTopic>");
    });
  }

  @override
  void dispose() {
    //为了避免内存泄露
    _scrollController.dispose();
    super.dispose();
  }

  Future getData() async {
    if (!isUpLoading) {
      isUpLoading = true;
      TopicDetailModel topicDetailModel = await dioSingleton.getTopicDetailAndReplies(widget.topicId, p++);

      // 用来判断主题是否需要登录: 正常获取到的主题 title 是不能为空的
      if (topicDetailModel.topicTitle.isEmpty) {
        Navigator.pop(context);
        return;
      }

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

  void _onValueChange(String value) {
    _lastEditCommentDraft = value;
  }

  Future _thankTopic() async {
    setState(() {
      _saving = true;
    });
    bool isSuccess = await dioSingleton.thankTopic(widget.topicId, _detailModel.token);
    if (isSuccess) {
      Fluttertoast.showToast(msg: '感谢已送达 😁', gravity: ToastGravity.CENTER);
      setState(() {
        _saving = false;
        _detailModel.isThank = true;
      });
    } else {
      Fluttertoast.showToast(msg: '操作失败 😞', gravity: ToastGravity.CENTER);
      setState(() {
        _saving = false;
      });
    }
  }

  Future _favoriteTopic() async {
    setState(() {
      _saving = true;
    });
    bool isSuccess = await dioSingleton.favoriteTopic(_detailModel.isFavorite, widget.topicId, _detailModel.token);
    if (isSuccess) {
      Fluttertoast.showToast(msg: _detailModel.isFavorite ? '已取消收藏！' : '收藏成功！', gravity: ToastGravity.CENTER);
      setState(() {
        _saving = false;
        _detailModel.isFavorite = !_detailModel.isFavorite;
      });
    } else {
      Fluttertoast.showToast(msg: '操作失败 😞', gravity: ToastGravity.CENTER);
      setState(() {
        _saving = false;
      });
    }
  }

  Future _thankReply(String replyID) async {
    setState(() {
      _saving = true;
    });
    bool isSuccess = await dioSingleton.thankTopicReply(replyID, _detailModel.token);
    if (isSuccess) {
      setState(() {
        _saving = false;
        // todo 更新UI：❤️后面的数字
        Fluttertoast.showToast(msg: '感谢已送达 😁', gravity: ToastGravity.CENTER);
      });
    } else {
      Fluttertoast.showToast(msg: '操作失败 😞', gravity: ToastGravity.CENTER);
      setState(() {
        _saving = false;
      });
    }
  }

  void _select(Action action) {
    switch (action.id) {
      case 'reply':
        print(action.title);
        showDialog(
          context: context,
          builder: (BuildContext context) => DialogOfComment(widget.topicId, _lastEditCommentDraft, _onValueChange),
        );
        break;
      case 'thank':
        print(action.title);
        if (_detailModel.isThank) {
          Fluttertoast.showToast(msg: '已经发送过感谢了 😉', gravity: ToastGravity.CENTER);
        } else {
          if (_detailModel.token.isNotEmpty) {
            // ⏏ 确认对话框
            showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      content: Text('你确定要向本主题创建者发送谢意？'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('取消'),
                          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                        ),
                        FlatButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
                              // 发送感谢
                              _thankTopic();
                            },
                            child: Text('确定')),
                      ],
                    ));
          } else {
            Fluttertoast.showToast(msg: '操作失败,无法获取 token 😞', gravity: ToastGravity.CENTER);
          }
        }
        break;
      case 'favorite':
        print(action.title);
        if (_detailModel.token.isNotEmpty) {
          // 收藏 / 取消收藏
          _favoriteTopic();
        } else {
          Fluttertoast.showToast(msg: '操作失败,无法获取 token 😞', gravity: ToastGravity.CENTER);
        }
        break;
      case 'web':
        print(action.title);
        // 用默认浏览器打开帖子链接
        launch(DioSingleton.v2exHost + '/t/' + widget.topicId, forceSafariVC: false);
        break;
      case 'link':
        print(action.title);
        // 复制链接到剪贴板
        Clipboard.setData(ClipboardData(text: DioSingleton.v2exHost + '/t/' + widget.topicId));
        Fluttertoast.showToast(msg: '已复制好帖子链接', gravity: ToastGravity.CENTER);
        break;
      case 'copy':
        print(action.title);
        // 复制帖子内容到剪贴板
        if (_detailModel != null && _detailModel.content.isNotEmpty) {
          Clipboard.setData(ClipboardData(text: _detailModel.content));
          Fluttertoast.showToast(msg: '已复制好帖子内容', gravity: ToastGravity.CENTER);
        } else {
          Fluttertoast.showToast(msg: '帖子内容为空！', gravity: ToastGravity.CENTER);
        }
        break;
      case 'share':
        print(action.title);
        // 分享: 帖子标题+链接
        if (_detailModel != null) {
          var text = _detailModel.topicTitle.isNotEmpty
              ? _detailModel.topicTitle + " " + DioSingleton.v2exHost + '/t/' + widget.topicId
              : _detailModel.content + " " + DioSingleton.v2exHost + '/t/' + widget.topicId;
          Share.share(text);
        }
        break;
      case 'reply_comment':
        print(action.title);
        _lastEditCommentDraft = _lastEditCommentDraft + " @" + action.title + " ";
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return DialogOfComment(widget.topicId, _lastEditCommentDraft, _onValueChange);
            });
        break;
      case 'thank_reply':
        print(action.title);
        if (_detailModel.token.isNotEmpty) {
          showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    content: Text('你确定要向 TA 发送谢意？'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('取消'),
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                      ),
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                            // 感谢回复
                            _thankReply(action.title);
                          },
                          child: Text('确定')),
                    ],
                  ));
        } else {
          Fluttertoast.showToast(msg: '操作失败,无法获取 token 😞', gravity: ToastGravity.CENTER);
        }
        break;
      case 'reply_copy':
        print(action.title);
        // 复制评论内容到剪贴板
        Clipboard.setData(ClipboardData(text: action.title));
        Fluttertoast.showToast(msg: '已复制好评论内容', gravity: ToastGravity.CENTER);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: CupertinoColors.lightBackgroundGray,
      appBar: new AppBar(
        actions: <Widget>[
          Offstage(
            child: Row(
              children: <Widget>[
                IconButton(
                    icon: Icon(_detailModel != null && _detailModel.isThank
                        ? FontAwesomeIcons.solidKissWinkHeart
                        : actions[0].icon),
                    onPressed: () {
                      _select(actions[0]);
                    }),
                IconButton(
                    icon: Icon(
                        _detailModel != null && _detailModel.isFavorite ? FontAwesomeIcons.solidStar : actions[1].icon),
                    onPressed: () {
                      _select(actions[1]);
                    }),
                IconButton(
                    icon: Icon(actions[2].icon),
                    onPressed: () {
                      _select(actions[2]);
                    }),
              ],
            ),
            offstage: !isLogin,
          ),
          PopupMenuButton<Action>(
            onSelected: _select,
            itemBuilder: (BuildContext context) {
              return actions.skip(3).map<PopupMenuItem<Action>>((Action action) {
                return PopupMenuItem<Action>(
                  value: action,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: IconTheme.merge(data: IconThemeData(color: Colors.black45), child: Icon(action.icon)),
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
      //body: new TopicDetailView(key, widget.topicId,_select),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: _detailModel != null
            ? RefreshIndicator(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        // 详情view
                        detailCard(context),
                        // 评论view
                        commentCard(_select),
                      ],
                    ),
                    controller: _scrollController,
                  ),
                ),
                onRefresh: _onRefresh)
            : new Container(
                padding: const EdgeInsets.all(40.0),
                child: new Center(
                  child: new CircularProgressIndicator(),
                )),
      ),
      floatingActionButton: Offstage(
        offstage: !showToTopBtn,
        child: FloatingActionButton(
            tooltip: '滑动到顶部',
            child: Icon(Icons.arrow_upward),
            mini: true,
            onPressed: () {
              _scrollController.animateTo(0, duration: Duration(milliseconds: 200), curve: Curves.ease);
            }),
      ),
//      这种方式不知道为啥，在iOS上正常，但是在Android上child死活显示不出来，怪！！！
//      floatingActionButton: !showToTopBtn ? null : FloatingActionButton(
//          tooltip: '滑动到顶部',
//          child: Icon(Icons.arrow_upward),
//          mini: true,
//          onPressed: () {
//            _scrollController.animateTo(0, duration: Duration(milliseconds: 200), curve: Curves.ease);
//          }),
    );
  }

  Card detailCard(BuildContext context) {
    return Card(
      elevation: 0.0,
      margin: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.all(10.0),
              child: new Row(
                children: <Widget>[
                  // 头像
                  GestureDetector(
                    child: ClipOval(
                      child: new CachedNetworkImage(
                        imageUrl: 'https:' + _detailModel.avatar,
                        height: 40.0,
                        width: 40.0,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Icon(Icons.account_circle, size: 40.0, color: Color(0xFFcccccc)),
                      ),
                    ),
                    onTap: () => _launchURL(DioSingleton.v2exHost + '/member/' + _detailModel.createdId),
                  ),
                  SizedBox(width: 10.0),
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
                      Row(
                        children: <Widget>[
                          new Icon(
                            Icons.keyboard,
                            size: 16.0,
                            color: Colors.grey[500],
                          ),
                          new Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              _detailModel.smallGray,
                              style: new TextStyle(fontSize: 12.0, color: Colors.grey[500]),
                            ),
                          )
                        ],
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
                  fontSize: 19.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // topic content
            new Container(
              padding: const EdgeInsets.all(10.0),
              child: Html(
                data: _detailModel.contentRendered,
                defaultTextStyle: TextStyle(color: Colors.black87, fontSize: 14.0),
                linkStyle: TextStyle(
                    color: ColorT.appMainColor[400],
                    decoration: TextDecoration.underline,
                    decorationColor: ColorT.appMainColor[400]),
                onLinkTap: (url) {
                  _launchURL(url);
                },
                useRichText: true,
              ),
            ),
            // 附言
            Offstage(
              offstage: _detailModel.subtleList.length == 0,
              child: Column(
                  children: _detailModel.subtleList.map((TopicSubtleItem subtle) {
                return _buildSubtle(subtle);
              }).toList()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtle(TopicSubtleItem subtle) {
    return Column(
      children: <Widget>[
        Divider(
          height: 0,
        ),
        Container(
          color: const Color(0xFFfffff9),
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 4.0, bottom: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                subtle.fade,
                style: TextStyle(color: Colors.grey, fontSize: 12.0),
              ),
              Html(
                data: subtle.content,
                padding: EdgeInsets.only(top: 4.0),
                defaultTextStyle: TextStyle(color: Colors.black87, fontSize: 12.0),
                linkStyle: TextStyle(
                    color: ColorT.appMainColor[400],
                    decoration: TextDecoration.underline,
                    decorationColor: ColorT.appMainColor[400]),
                onLinkTap: (url) {
                  _launchURL(url);
                },
                useRichText: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  StatelessWidget commentCard(void Function(Action action) select) {
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
                      behavior: HitTestBehavior.opaque, // GestureDetector 默认只监听不透明的 widget。当你点击空白的地方的时候，会监听不到。
                      child: new Container(
                        color: reply.userName == _detailModel.createdId ? Colors.red[100] : null,
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // 评论item头像
                            GestureDetector(
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: 'https:' + reply.avatar,
                                  width: 25.0,
                                  height: 25.0,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Icon(
                                        Icons.account_circle,
                                        size: 25,
                                        color: Color(0xFFcccccc),
                                      ),
                                ),
                              ),
                              onTap: () => _launchURL(DioSingleton.v2exHost + '/member/' + reply.userName),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            new Expanded(
                                child: new Container(
                              margin: const EdgeInsets.only(top: 2.0),
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Row(
                                    children: <Widget>[
                                      // 评论用户ID
                                      new Text(
                                        reply.userName,
                                        style:
                                            new TextStyle(fontSize: 14.0, color: Colors.grey, fontWeight: FontWeight.bold),
                                      ),
                                      // 评论时间和平台
                                      new Padding(
                                        padding: const EdgeInsets.only(left: 6.0, right: 4.0),
                                        child: new Text(
                                          reply.lastReplyTime,
                                          style: new TextStyle(
                                            color: const Color(0xFFcccccc),
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ),
                                      // 获得感谢数
                                      Offstage(
                                        offstage: reply.favorites.isEmpty,
                                        child: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.favorite,
                                              color: Color(0xFFcccccc),
                                              size: 14.0,
                                            ),
                                            SizedBox(width: 2.0),
                                            Text(
                                              reply.favorites,
                                              style: TextStyle(
                                                color: const Color(0xFFcccccc),
                                                fontSize: 12.0,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      Material(
                                        color: Color(0xFFf0f0f0),
                                        shape: new StadiumBorder(),
                                        child: new Container(
                                          width: 20.0,
                                          height: 14.0,
                                          alignment: Alignment.center,
                                          child: new Text(
                                            reply.number,
                                            style: new TextStyle(fontSize: 9.0, color: Color(0xFFa2a2a2)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  new Container(
                                      padding: const EdgeInsets.only(bottom: 10.0, top: 5.0),
                                      // 评论内容
                                      child: Html(
                                        data: reply.contentRendered,
                                        defaultTextStyle: TextStyle(color: Colors.black, fontSize: 14.0),
                                        linkStyle: TextStyle(
                                            color: ColorT.appMainColor[400],
                                            decoration: TextDecoration.underline,
                                            decorationColor: ColorT.appMainColor[400]),
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
                                        useRichText: true,
                                      )),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                      onTap: () {
                        if (isLogin) {
                          // 点击评论列表item，弹出操作 bottom sheet
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(Icons.local_florist),
                                      title: Text('感谢评论'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        select(Action(id: 'thank_reply', title: reply.replyId));
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.reply),
                                      title: Text('回复评论'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        select(Action(id: 'reply_comment', title: reply.userName));
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.content_copy),
                                      title: Text('拷贝评论'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        select(Action(id: 'reply_copy', title: reply.content));
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.forum),
                                      title: Text('查看对话'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        Fluttertoast.showToast(msg: 'Developing...');
                                      },
                                    ),
                                  ],
                                );
                              });
                        } else {
                          Fluttertoast.showToast(
                              msg: '登录后有更多操作 😬',
                              toastLength: Toast.LENGTH_SHORT,
                              timeInSecForIos: 1,
                              gravity: ToastGravity.CENTER);
                        }
                      });
                }
              },
              separatorBuilder: (context, index) {
                return new Container(
                  margin: const EdgeInsets.only(left: 45.0),
                  width: 300.0,
                  height: 1,
                  color: Theme.of(context).dividerColor,
                );
              },
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), // 禁用滚动事件
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
    if (mounted) {
      setState(() {
        _detailModel = topicDetailModel;
        replyList.clear();
        replyList.addAll(topicDetailModel.replyList);
        if (p == 2) {
          maxPage = topicDetailModel.maxPage;
          print("####详情页-评论的页数：" + maxPage.toString());
        }
      });
    } else {
      print("####详情页-_onRefresh() mounted no !!!!");
    }
  }
}

class Action {
  const Action({this.id, this.title, this.icon});

  final String id;
  final String title;
  final IconData icon;
}

// 外链跳转
_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true, statusBarBrightness: Platform.isIOS ? Brightness.light : null);
  } else {
    Fluttertoast.showToast(
        msg: 'Could not launch $url', toastLength: Toast.LENGTH_SHORT, timeInSecForIos: 1, gravity: ToastGravity.BOTTOM);
  }
}
