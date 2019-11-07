import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/common/database_helper.dart';
import 'package:flutter_app/components/circle_avatar.dart';
import 'package:flutter_app/components/fullscreen_image_view.dart';
import 'package:flutter_app/models/web/item_recent_read_topic.dart';
import 'package:flutter_app/models/web/item_topic_reply.dart';
import 'package:flutter_app/models/web/item_topic_subtle.dart';
import 'package:flutter_app/models/web/model_topic_detail.dart';
import 'package:flutter_app/network/dio_web.dart';
import 'package:flutter_app/pages/page_node_topics.dart';
import 'package:flutter_app/pages/page_profile.dart';
import 'package:flutter_app/utils/event_bus.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:flutter_app/utils/strings.dart';
import 'package:flutter_app/utils/url_helper.dart';
import 'package:flutter_app/utils/utils.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ovprogresshud/progresshud.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

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

    // 设置默认操作进度加载背景
    Progresshud.setDefaultMaskTypeBlack();

    // check login state
    isLogin = SpHelper.sp.containsKey(SP_USERNAME);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TopicDetailView(widget.topicId),
    );
  }
}

class BottomSheetOfComment extends StatefulWidget {
  final String topicId;
  final String initialValue;
  final void Function(String) onValueChange;

  BottomSheetOfComment(this.topicId, this.initialValue, this.onValueChange);

  @override
  _BottomSheetOfCommentState createState() => _BottomSheetOfCommentState();
}

class _BottomSheetOfCommentState extends State<BottomSheetOfComment> {
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
    return AnimatedPadding(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: CachedNetworkImageProvider('https:${SpHelper.sp.getString(SP_AVATAR)}'),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Scrollbar(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextField(
                        autofocus: true,
                        keyboardType: TextInputType.multiline,
                        // Setting maxLines=null makes the text field auto-expand when one
                        // line is filled up.
                        maxLines: null,
                        decoration: InputDecoration.collapsed(hintText: "发表公开评论..."),
                        controller: _textController,
                        onChanged: (String text) => setState(() {
                          _isComposing = text.length > 0;
                          widget.onValueChange(text);
                        }),
                        onSubmitted: _onTextMsgSubmitted,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.image),
                      onPressed: () => launch('https://sm.ms/', statusBarBrightness: Platform.isIOS ? Brightness.light : null),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _isComposing ? () => _onTextMsgSubmitted(_textController.text) : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      padding: MediaQuery.of(context).viewInsets,
      duration: Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Triggered when text is submitted (send button pressed).
  Future<Null> _onTextMsgSubmitted(String text) async {
    bool loginResult = await DioWeb.replyTopic(widget.topicId, text);
    if (loginResult) {
      Progresshud.showSuccessWithStatus('回复成功!');
      // Clear input text field.
      _textController.clear();
      widget.onValueChange("");
      _isComposing = false;
      Navigator.of(context, rootNavigator: true).pop();
      eventBus.emit(MyEventRefreshTopic);
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
  List<Action> actions = <Action>[
    Action(id: 'thank', title: '感谢', icon: FontAwesomeIcons.kissWinkHeart),
    Action(id: 'favorite', title: '收藏', icon: FontAwesomeIcons.star),
    Action(id: 'reply', title: '回复', icon: FontAwesomeIcons.reply),
    Action(id: 'only_up', title: '楼主 / 全部', icon: Icons.visibility),
    Action(id: 'link', title: '复制链接', icon: Icons.link),
    Action(id: 'copy', title: '复制内容', icon: Icons.content_copy),
    Action(id: 'web', title: '浏览器打开', icon: Icons.explore),
    Action(id: 'share', title: '分享', icon: Icons.share),
    Action(), // for PopupMenuDivider
    Action(id: 'ignore_topic', title: '忽略主题', icon: Icons.do_not_disturb_alt),
    Action(id: 'report_topic', title: '举报主题', icon: Icons.report_problem),
  ];

  String _lastEditCommentDraft = '';

  int p = 1;
  int maxPage = 1;

  bool isUpLoading = false;

  bool isOnlyUp = false; // 只看楼主
  List<ReplyItem> replyListAll = List(); //只看楼主时保存的当前所有评论

  TopicDetailModel _detailModel;
  List<ReplyItem> replyList = List();

  ScrollController _scrollController;

//  bool showToTopBtn = false; //是否显示“返回到顶部”按钮

  @override
  void initState() {
    super.initState();

    eventBus.on(MyEventRefreshTopic, (event) {
      _onRefresh();
      print("eventBus.on<MyEventRefreshTopic>");
    });

    // 获取数据
    getData();
  }

  @override
  void didChangeDependencies() {
    _scrollController = PrimaryScrollController.of(context);
    // 监听是否滑到了页面底部
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        print("滑到底部了，尝试加载更多...");
        if (replyList.length > 0 && p <= maxPage) {
          getData();
        } else {
          print("没有更多...");
          HapticFeedback.heavyImpact(); // 震动反馈
        }
      }
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    eventBus.off(MyEventRefreshTopic);
    //为了避免内存泄露
    _scrollController.dispose();
    super.dispose();
  }

  Future getData() async {
    if (!isUpLoading) {
      isUpLoading = true;
      TopicDetailModel topicDetailModel = await DioWeb.getTopicDetailAndReplies(widget.topicId, p++);

      // 用来判断主题是否需要登录: 正常获取到的主题 title 是不能为空的
      if (topicDetailModel.topicTitle.isEmpty) {
        // 从「近期已读」移除
        //var databaseHelper = DatabaseHelper.instance;
        //await databaseHelper.delete(topicDetailModel.topicId);
        Navigator.pop(context);
        return;
      }

      // 保存到数据库（新增或者修改之前记录到最前面）
      // 添加到「近期已读」
      var dbHelper = DatabaseHelper.instance;
      dbHelper.insert(RecentReadTopicItem(
          topicId: topicDetailModel.topicId,
          topicContent: topicDetailModel.topicTitle,
          avatar: topicDetailModel.avatar,
          memberId: topicDetailModel.createdId,
          nodeName: topicDetailModel.nodeName,
          nodeId: topicDetailModel.nodeId));

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
    Progresshud.show();
    bool isSuccess = await DioWeb.thankTopic(widget.topicId);
    Progresshud.dismiss();
    if (isSuccess) {
      Progresshud.showSuccessWithStatus('感谢已发送');
      eventBus.emit(MyEventRefreshTopic);
    } else {
      Progresshud.showErrorWithStatus('操作失败');
    }
  }

  Future _favoriteTopic() async {
    Progresshud.show();
    bool isSuccess = await DioWeb.favoriteTopic(_detailModel.isFavorite, widget.topicId, _detailModel.token);
    Progresshud.dismiss();
    if (isSuccess) {
      Progresshud.showSuccessWithStatus(_detailModel.isFavorite ? '已取消收藏！' : '收藏成功！');
      eventBus.emit(MyEventRefreshTopic);
    } else {
      Progresshud.showErrorWithStatus('操作失败');
    }
  }

  Future _ignoreTopic() async {
    bool isSuccess = await DioWeb.ignoreTopic(widget.topicId);
    if (isSuccess) {
      Progresshud.showSuccessWithStatus('已完成对 ${widget.topicId} 号主题的忽略');
      Navigator.pop(context);
    } else {
      Progresshud.showErrorWithStatus('操作失败');
    }
  }

  Future _reportTopic() async {
    bool isSuccess = await DioWeb.reportTopic(widget.topicId);
    if (isSuccess) {
      Progresshud.showSuccessWithStatus('举报成功');
    } else {
      Progresshud.showErrorWithStatus('操作失败');
    }
  }

  Future _thankReply(String replyID) async {
    bool isSuccess = await DioWeb.thankTopicReply(replyID);
    if (isSuccess) {
      Progresshud.showSuccessWithStatus('感谢已发送');
      // 更新UI：红心️后面的数字
      eventBus.emit(MyEventRefreshTopic);
    } else {
      Progresshud.showErrorWithStatus('操作失败');
    }
  }

  /// 只看楼主 or 查看全部
  void _onlyUp(bool isOnly) {
    if (isOnly) {
      // 查看全部
      HapticFeedback.heavyImpact(); // 震动反馈
      setState(() {
        isOnlyUp = false;
        replyList.clear();
        replyList.addAll(replyListAll);
      });
    } else if (replyList.length != 0) {
      // 只看楼主
      HapticFeedback.heavyImpact(); // 震动反馈
      replyListAll.clear();
      replyListAll.addAll(replyList);
      setState(() {
        isOnlyUp = true;
        replyList.retainWhere((item) => item.userName == _detailModel.createdId);
      });
    }
  }

  void _select(Action action) {
    switch (action.id) {
      case 'reply':
        print(action.title);
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) => BottomSheetOfComment(widget.topicId, _lastEditCommentDraft, _onValueChange),
        );
        break;
      case 'thank':
        print(action.title);
        if (_detailModel.isThank) {
          Progresshud.showInfoWithStatus('已发送过感谢!');
        } else {
          if (_detailModel.token.isNotEmpty) {
            // ⏏ 确认对话框
            showAlert('你确定要向本主题创建者发送谢意？', _thankTopic);
          } else {
            Progresshud.showErrorWithStatus('无法获取 token');
          }
        }
        break;
      case 'favorite':
        print(action.title);
        if (_detailModel.token.isNotEmpty) {
          // 收藏 / 取消收藏
          HapticFeedback.heavyImpact(); // 震动反馈
          _favoriteTopic();
        } else {
          Progresshud.showErrorWithStatus('无法获取 token');
        }
        break;
      case 'web':
        print(action.title);
        // 用默认浏览器打开帖子链接
        launch(Strings.v2exHost + '/t/' + widget.topicId, forceSafariVC: false);
        break;
      case 'only_up':
        print(action.title);
        // 只看楼主/查看全部
        _onlyUp(isOnlyUp);
        break;
      case 'ignore_topic':
        print(action.title);
        // 判断登录
        if (isLogin) {
          // ⏏ 确认对话框  todo 确定撤销对这个主题的忽略？
          showAlert('您确定不想再看到这个主题？', _ignoreTopic);
        } else {
          Progresshud.showInfoWithStatus('请先登录');
        }
        break;
      case 'report_topic':
        print(action.title);
        // 判断登录
        if (isLogin) {
          // ⏏ 确认对话框
          showAlert('你确认需要报告这个主题？', _reportTopic);
        } else {
          Progresshud.showInfoWithStatus('请先登录');
        }
        break;
      case 'link':
        print(action.title);
        // 复制链接到剪贴板
        Clipboard.setData(ClipboardData(text: Strings.v2exHost + '/t/' + widget.topicId));
        Progresshud.showSuccessWithStatus('已复制好帖子链接');
        break;
      case 'copy':
        print(action.title);
        // 复制帖子内容到剪贴板
        if (_detailModel != null && _detailModel.content.isNotEmpty) {
          Clipboard.setData(ClipboardData(text: _detailModel.content));
          Progresshud.showSuccessWithStatus('已复制好帖子内容');
        } else {
          Progresshud.showInfoWithStatus('帖子内容为空！');
        }
        break;
      case 'share':
        print(action.title);
        // 分享: 帖子标题+链接
        if (_detailModel != null) {
          var text = _detailModel.topicTitle.isNotEmpty
              ? _detailModel.topicTitle + " " + Strings.v2exHost + '/t/' + widget.topicId
              : _detailModel.content + " " + Strings.v2exHost + '/t/' + widget.topicId;
          Share.share(text);
        }
        break;
      case 'reply_comment':
        print(action.title);
        _lastEditCommentDraft = _lastEditCommentDraft + action.title;
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return BottomSheetOfComment(widget.topicId, _lastEditCommentDraft, _onValueChange);
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
          Progresshud.showErrorWithStatus('无法获取 token');
        }
        break;
      case 'reply_copy':
        print(action.title);
        // 复制评论内容到剪贴板
        Clipboard.setData(ClipboardData(text: action.title));
        Progresshud.showSuccessWithStatus('已复制好评论内容');
        break;
      default:
        break;
    }
  }

  // 抽取出功能一致的 alert
  void showAlert(String title, Function() function) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: Text(title),
              actions: <Widget>[
                FlatButton(
                  child: Text('取消'),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                ),
                FlatButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      function();
                    },
                    child: Text('确定')),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : CupertinoColors.lightBackgroundGray,
      appBar: new AppBar(
        actions: <Widget>[
          Offstage(
            child: Row(
              children: <Widget>[
                Offstage(
                  offstage: _detailModel != null && _detailModel.createdId == SpHelper.sp.getString(SP_USERNAME),
                  child: IconButton(
                      icon: Icon(_detailModel != null && _detailModel.isThank ? FontAwesomeIcons.solidKissWinkHeart : actions[0].icon),
                      onPressed: () {
                        _select(actions[0]);
                      }),
                ),
                IconButton(
                    icon: Icon(_detailModel != null && _detailModel.isFavorite ? FontAwesomeIcons.solidStar : actions[1].icon),
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
              return actions.skip(3).map<PopupMenuEntry<Action>>((Action action) {
                return action.id == null
                    ? PopupMenuDivider(
                        height: 0,
                      )
                    : PopupMenuItem<Action>(
                        value: action,
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
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
      //body: new TopicDetailView(key, widget.topicId,_select),
      body: _detailModel != null
          ? RefreshIndicator(
              child: Scrollbar(
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
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
          : Center(
              child: Platform.isIOS ? CupertinoActivityIndicator() : CircularProgressIndicator(),
            ),
    );
  }

  Card detailCard(BuildContext context) {
    return Card(
      elevation: 0.0,
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.all(10.0),
            child: new Row(
              children: <Widget>[
                // 头像
                GestureDetector(
                  child: Hero(
                    tag: 'avatar',
                    transitionOnUserGestures: true,
                    child: CircleAvatarWithPlaceholder(
                      imageUrl: _detailModel.avatar,
                      size: 44,
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage(_detailModel.createdId, 'https:${_detailModel.avatar}')),
                  ),
                ),
                SizedBox(width: 10.0),
                new Expanded(
                    child: new Column(
                  children: <Widget>[
                    new Row(
                      children: <Widget>[
                        // 用户ID
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: new Text(
                              _detailModel.createdId,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              style: new TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfilePage(_detailModel.createdId, 'https:${_detailModel.avatar}')),
                          ),
                        ),
                        new Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.green,
                          size: 16.0,
                        ),
                        // 节点名称
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: new Text(
                              _detailModel.nodeName,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              style: new TextStyle(fontSize: 15.0, color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ),
                          onTap: () => Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => NodeTopics(
                                        _detailModel.nodeId,
                                        nodeName: _detailModel.nodeName,
                                      ))),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        new Icon(
                          Icons.keyboard,
                          size: 16.0,
                          color: Theme.of(context).disabledColor,
                        ),
                        new Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(
                            _detailModel.smallGray,
                            style: new TextStyle(fontSize: 13.0, color: Theme.of(context).disabledColor),
                          ),
                        )
                      ],
                    )
                  ],
                )),
                new Icon(
                  FontAwesomeIcons.comment,
                  size: 16.0,
                  color: Colors.grey,
                ),
                new Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: new Text(
                    _detailModel.replyCount,
                    style: new TextStyle(fontSize: 15.0, color: Theme.of(context).unselectedWidgetColor),
                  ),
                )
              ],
            ),
          ),
          // topic title
          new Container(
            padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 5.0, right: 10.0),
            width: 500.0,
            child: SelectableText(
              _detailModel.topicTitle,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // topic content
          new Container(
            padding: const EdgeInsets.all(10.0),
            child: Html(
              data: _detailModel.contentRendered,
              linkStyle: TextStyle(
                color: Theme.of(context).accentColor,
                decoration: TextDecoration.underline,
              ),
              onLinkTap: (url) {
                if (UrlHelper.canLaunchInApp(context, url)) {
                  return;
                }
                Utils.launchURL(url);
              },
              onImageTap: (source) {
                print(source);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenWrapper(
                      imageProvider: NetworkImage(source),
                    ),
                  ),
                );
              },
            ),
          ),
          // 附言
          Offstage(
            offstage: _detailModel.subtleList.length == 0,
            child: Column(
              children: <Widget>[
                Column(
                    children: _detailModel.subtleList.map((TopicSubtleItem subtle) {
                  return _buildSubtle(subtle);
                }).toList()),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.black12 : const Color(0xFFFFFFF0),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
                  ),
                ),
              ],
            ),
          ),
        ],
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
          color: Theme.of(context).brightness == Brightness.dark ? Colors.black12 : const Color(0xFFFFFFF0),
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 4.0, bottom: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                subtle.fade,
                style: Theme.of(context).textTheme.caption,
              ),
              Html(
                data: subtle.content,
                padding: EdgeInsets.only(top: 4.0),
                defaultTextStyle: TextStyle(fontSize: 14.0),
                linkStyle: TextStyle(
                  color: Theme.of(context).accentColor,
                  decoration: TextDecoration.underline,
                ),
                onLinkTap: (url) {
                  if (UrlHelper.canLaunchInApp(context, url)) {
                    return;
                  }
                  Utils.launchURL(url);
                },
                onImageTap: (source) {
                  print(source);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenWrapper(
                        imageProvider: NetworkImage(source),
                      ),
                    ),
                  );
                },
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
              child: Text(isOnlyUp ? '楼主尚未回复' : '目前尚无回复', style: new TextStyle(color: Colors.grey[600])),
            ))
        : Card(
            elevation: 0.0,
            margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
            child: ListView.builder(
              // +1 是展示 _buildLoadText
              itemCount: replyList.length + 1,
              itemBuilder: (context, index) {
                if (index == replyList.length) {
                  // 渲染到了最后一个item
                  return _buildLoadText();
                } else {
                  ReplyItem reply = replyList[index];
                  return InkWell(
                    child: new Container(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              // 评论item头像
                              GestureDetector(
                                child: Hero(
                                  tag: 'avatar$index',
                                  transitionOnUserGestures: true,
                                  child: CircleAvatarWithPlaceholder(
                                    imageUrl: reply.avatar,
                                    size: 28,
                                  ),
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePage(
                                            reply.userName,
                                            'https:${Utils.avatarLarge(reply.avatar)}',
                                            heroTag: 'avatar$index',
                                          )),
                                ),
                              ),
                              Offstage(
                                offstage: reply.userName != _detailModel.createdId,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '楼主',
                                      style: TextStyle(fontSize: 9, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                                Row(
                                  children: <Widget>[
                                    // 评论用户ID
                                    new Text(
                                      reply.userName,
                                      style: new TextStyle(fontSize: 15.0, color: Colors.grey, fontWeight: FontWeight.bold),
                                    ),
                                    // 评论时间和平台
                                    new Padding(
                                      padding: const EdgeInsets.only(left: 6.0, right: 8.0),
                                      child: new Text(
                                        reply.lastReplyTime,
                                        style: new TextStyle(
                                          color: const Color(0xFFcccccc),
                                          fontSize: 13.0,
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
                                            color: Colors.red[100], // Color(0xFFcccccc)
                                            size: 14.0,
                                          ),
                                          SizedBox(width: 2.0),
                                          Text(
                                            reply.favorites,
                                            style: TextStyle(
                                              color: const Color(0xFFcccccc),
                                              fontSize: 13.0,
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
                                Container(
                                    padding: const EdgeInsets.only(bottom: 10.0, top: 5.0),
                                    // 评论内容
                                    child: Html(
                                      data: reply.contentRendered,
                                      linkStyle: TextStyle(
                                        color: Theme.of(context).accentColor,
                                      ),
                                      onLinkTap: (url) {
                                        if (UrlHelper.canLaunchInApp(context, url)) {
                                          return;
                                        } else if (url.contains("/member/")) {
                                          print(url.split("/member/")[1] + " $index");
                                          // 找出这个用户的最近一条评论，也可能没有
                                          var list = replyList.sublist(0, index);
                                          var item = list.lastWhere((item) => item.userName == url.split("/member/")[1], orElse: () => null);
                                          if (item == null) {
                                            Fluttertoast.showToast(msg: '1层至$index层间未发现该用户回复', gravity: ToastGravity.CENTER);
                                          } else {
                                            // 弹出找到的此用户之前评论
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return SimpleDialog(
                                                    contentPadding: EdgeInsets.all(10),
                                                    children: <Widget>[
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Column(
                                                            children: <Widget>[
                                                              // 评论item头像
                                                              GestureDetector(
                                                                child: CircleAvatarWithPlaceholder(
                                                                  imageUrl: item.avatar,
                                                                  size: 28,
                                                                ),
                                                                onTap: () => Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => ProfilePage(item.userName, 'https:${item.avatar}')),
                                                                ),
                                                              ),
                                                              Offstage(
                                                                offstage: item.userName != _detailModel.createdId,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(top: 6.0),
                                                                  child: Container(
                                                                    padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.redAccent[100],
                                                                      borderRadius: BorderRadius.circular(4),
                                                                    ),
                                                                    child: Text(
                                                                      '楼主',
                                                                      style: TextStyle(fontSize: 9, color: Colors.white),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            width: 10.0,
                                                          ),
                                                          Expanded(
                                                              child: new Container(
                                                            margin: const EdgeInsets.only(top: 2.0),
                                                            child: new Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                new Row(
                                                                  children: <Widget>[
                                                                    // 评论用户ID
                                                                    new Text(
                                                                      item.userName,
                                                                      style: new TextStyle(
                                                                          fontSize: 15.0, color: Colors.grey, fontWeight: FontWeight.bold),
                                                                    ),
                                                                    // 评论时间和平台
                                                                    new Padding(
                                                                      padding: const EdgeInsets.only(left: 6.0, right: 4.0),
                                                                      child: new Text(
                                                                        item.lastReplyTime,
                                                                        style: new TextStyle(
                                                                          color: const Color(0xFFcccccc),
                                                                          fontSize: 13.0,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    // 获得感谢数
                                                                    Offstage(
                                                                      offstage: item.favorites.isEmpty,
                                                                      child: Row(
                                                                        children: <Widget>[
                                                                          Icon(
                                                                            Icons.favorite,
                                                                            color: Colors.red[100], // Color(0xFFcccccc)
                                                                            size: 14.0,
                                                                          ),
                                                                          SizedBox(width: 2.0),
                                                                          Text(
                                                                            item.favorites,
                                                                            style: TextStyle(
                                                                              color: const Color(0xFFcccccc),
                                                                              fontSize: 13.0,
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
                                                                          item.number,
                                                                          style: new TextStyle(fontSize: 9.0, color: Color(0xFFa2a2a2)),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                new Container(
                                                                    padding: EdgeInsets.only(top: 5.0),
                                                                    // 评论内容
                                                                    child: Html(
                                                                      data: item.contentRendered,
                                                                      linkStyle: TextStyle(
                                                                        color: Theme.of(context).accentColor,
                                                                      ),
                                                                    )),
                                                              ],
                                                            ),
                                                          )),
                                                        ],
                                                      )
                                                    ],
                                                  );
                                                });
                                          }
                                          return;
                                        }
                                        Utils.launchURL(url);
                                      },
                                      onImageTap: (source) {
                                        print(source);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FullScreenWrapper(
                                              imageProvider: NetworkImage(source),
                                            ),
                                          ),
                                        );
                                      },
                                    )),
                                Divider(
                                  height: 0,
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                    onTap: () {
                      if (isLogin) {
                        // 点击评论列表item，弹出回复框
                        select(Action(id: 'reply_comment', title: " @" + reply.userName + " #" + reply.number + " "));
                      } else {
                        Progresshud.showInfoWithStatus('登录后有更多操作\n ¯\\_(ツ)_/¯');
                      }
                    },
                    onLongPress: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                if (isLogin)
                                  ListTile(
                                    leading: Icon(FontAwesomeIcons.kissWinkHeart),
                                    title: Text('感谢评论'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      select(Action(id: 'thank_reply', title: reply.replyId));
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
//                                    ListTile(
//                                      leading: Icon(Icons.forum),
//                                      title: Text('查看对话'),
//                                      onTap: () {
//                                        Navigator.pop(context);
//                                        Fluttertoast.showToast(msg: 'Developing...');
//                                      },
//                                    ),
                              ],
                            );
                          });
                    },
                  );
                }
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
    TopicDetailModel topicDetailModel = await DioWeb.getTopicDetailAndReplies(widget.topicId, p++);
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

class LoadingRepliesSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: Column(
              children: [0, 1, 2, 3, 4]
                  .map((_) => Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipOval(
                              child: Container(
                                width: 28.0,
                                height: 28.0,
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        width: 40.0,
                                        height: 10.0,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 6,
                                      ),
                                      Container(
                                        width: 40.0,
                                        height: 10.0,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 10.0,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Container(
                                    width: 180,
                                    height: 10.0,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Divider(
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ))
                  .toList(),
            ),
          )),
    );
  }
}
