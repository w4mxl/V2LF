// 特定节点话题列表页面

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/components/listview_node_topic.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/model/node.dart';
import 'package:flutter_app/model/web/item_node_topic.dart';
import 'package:flutter_app/network/api_network.dart';
import 'package:flutter_app/network/dio_web.dart';
import 'package:flutter_app/utils/event_bus.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:flutter_app/utils/strings.dart';
import 'package:ovprogresshud/progresshud.dart';

class NodeTopics extends StatefulWidget {
  final String nodeId;

  NodeTopics(this.nodeId);

  @override
  _NodeTopicsState createState() => _NodeTopicsState();
}

class _NodeTopicsState extends State<NodeTopics> {
  Node _node;

  bool isFavorite = false;
  String nodeIdWithOnce = '';

  int p = 1;
  bool isUpLoading = false;
  List<NodeTopicItem> items = new List();

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();

    // 设置默认操作进度加载背景
    Progresshud.setDefaultMaskTypeBlack();

    // 获取数据
    getNodeInfo();
    getTopics();
    // 监听是否滑到了页面底部
    _scrollController.addListener(() {
      if (p != 1 && _scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        print("加载更多...");
        getTopics();
      }
    });
  }

  Future getNodeInfo() async {
    var node = await NetworkApi.getNodeInfo(widget.nodeId);
    if (node != null) {
      setState(() {
        _node = node;
      });
    }
  }

  Future getTopics() async {
    if (!isUpLoading) {
      isUpLoading = true;

      List<NodeTopicItem> newEntries = await DioWeb.getNodeTopicsByTabKey(widget.nodeId, p++);
      // 用来判断节点是否需要登录后查看
      if (newEntries.isEmpty) {
        Navigator.pop(context);
        return;
      }

      setState(() {
        items.addAll(newEntries);
        isUpLoading = false;
      });
    }
  }

  Future _favouriteNode() async {
    if (nodeIdWithOnce.isNotEmpty) {
      bool isSuccess = await DioWeb.favoriteNode(isFavorite, nodeIdWithOnce);
      if (isSuccess) {
        HapticFeedback.heavyImpact(); // 震动反馈
        Progresshud.showSuccessWithStatus(isFavorite ? '已取消收藏' : '收藏成功');
        setState(() {
          isFavorite = !isFavorite;
        });
      } else {
        Progresshud.showErrorWithStatus('操作失败');
      }
    } else {
      Progresshud.showInfoWithStatus('未获取到 once');
    }
  }

  @override
  Widget build(BuildContext context) {
    //监听事件
    eventBus.on(MyEventNodeIsFav, (isFavWithOnce) {
      if (!mounted) return;
      setState(() {
        //   /favorite/node/39?once=87770
        isFavorite = isFavWithOnce.startsWith('/unfavorite');
        nodeIdWithOnce = isFavWithOnce.split('/node/')[1];
        print('wml：$nodeIdWithOnce');
      });
    });

    return new Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_node == null ? '' : _node.title),
              centerTitle: true,
              background: _node == null
                  ? Container()
                  : SafeArea(
                      child: CachedNetworkImage(
                        imageUrl: (_node.avatarLarge == '/static/img/node_large.png')
                            ? Strings.nodeDefaultImag
                            : "https:" + _node.avatarLarge.replaceFirst('large', 'xxlarge'),
                        fit: BoxFit.contain,
                        placeholder: (context, url) => new CircularProgressIndicator(),
                        errorWidget: (context, url, error) => CachedNetworkImage(
                          imageUrl: "https:" + _node.avatarLarge,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
            ),
            actions: <Widget>[
              // 收藏/取消收藏 按钮
              Offstage(
                offstage: !SpHelper.sp.containsKey(SP_USERNAME),
                child: IconButton(
                    icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                    onPressed: () {
                      _favouriteNode();
                    }),
              )
            ],
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == items.length + 1) {
                if (index != 1) {
                  // 滑到了最后一个item
                  return _buildLoadText();
                } else {
                  return new Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: new CircularProgressIndicator(),
                    ),
                  );
                }
              } else {
                if (index == 0) {
                  return _buildHeader();
                }
                return new TopicItemView(items[index - 1]);
              }
            }, childCount: items.length + 2),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    eventBus.off(MyEventNodeIsFav);
    super.dispose();
  }

  Widget _buildHeader() {
    return _node == null
        ? null
        : Column(
            children: <Widget>[
              SizedBox(
                height: 4,
              ),
              Offstage(
                // 自言自语的是："header": "&nbsp;",
                offstage: (_node.header == null || _node.header.isEmpty || _node.header == '&nbsp;'),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 10, right: 10),
//                  child: Html( // todo Html not ready for this !
//                    data: _node.header == null ? '' : _node.header,
//                    defaultTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                  ),
                  child: Text(
                    // Android
                    // "header": 来自 <a href=\"/go/google\">Google</a> 的开放源代码智能手机平台。
                    _node.header == null ? '' : _node.header,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.forum,
                    size: 16,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    _node.topics.toString(),
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Icon(
                    Icons.star,
                    size: 16,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    _node.stars.toString(),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Divider(
                height: 0,
              ),
            ],
          );
  }

  Widget _buildLoadText() {
    return Container(
      padding: const EdgeInsets.all(18.0),
      child: Center(
        child: Text(S.of(context).loadingPage(p.toString())),
      ),
    );
  }
}
