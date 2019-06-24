// Tab all listview
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/model/web/item_tab_topic.dart';
import 'package:flutter_app/network/dio_web.dart';
import 'package:flutter_app/utils/sp_helper.dart';

import 'listview_tab_topic.dart';

class TabAllListView extends StatefulWidget {
  final String tabKey;

  TabAllListView(this.tabKey);

  @override
  State<StatefulWidget> createState() => new TopicListViewState();
}

class TopicListViewState extends State<TabAllListView> with AutomaticKeepAliveClientMixin {
  int p = 0; // 0 代表主页Tab all下的； > 0 则是 https://www.v2ex.com/recent 下的数据
  bool isUpLoading = false;
  bool hasError = false;
  List<TabTopicItem> items = new List();
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // 获取数据
    getTopics();
  }

  Future getTopics() async {
    if (!isUpLoading) {
      isUpLoading = true;
      List<TabTopicItem> newEntries = await DioWeb.getTopicsByTabKey(widget.tabKey, p++);
      if (newEntries.isEmpty) {
        // 应该是网络错误
        print('wml!!!!!');
        setState(() {
          hasError = true;
        });
        return;
      }

      print(p);
      setState(() {
        items.addAll(newEntries);
        isUpLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_scrollController != PrimaryScrollController.of(context)) {
      // 监听是否滑到了页面底部
      _scrollController = PrimaryScrollController.of(context)
        ..addListener(() {
          _checkScrollToButtom();
        });
    }
    if (items.length > 0) {
      return new RefreshIndicator(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index == items.length) {
                // 滑到了最后一个item
                return _buildLoadText();
              } else {
                return TopicItemView(items[index]);
              }
            },
          ),
          onRefresh: _onRefresh);
    } else if (hasError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(S.of(context).oops),
          RaisedButton.icon(
            onPressed: () {
              _onRefresh();
            },
            icon: Icon(Icons.refresh),
            label: Text(S.of(context).retry),
          )
        ],
      );
    }
    // By default, show a loading skeleton
    return LoadingList();
  }

  void _checkScrollToButtom() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      print("加载更多...");
      if (SpHelper.sp.containsKey(SP_USERNAME)) {
        print('加载recent');
        getTopics();
      } else {
        print('recent no');
      }
    }
  }

  Widget _buildLoadText() {
    return Container(
      padding: const EdgeInsets.all(18.0),
      child: Center(
        child: Text(SpHelper.sp.containsKey(SP_USERNAME) ? S.of(context).loadingPage((p + 1).toString()) : "请登录后查看更多"),
      ),
    );
  }

  //刷新数据,重新设置future就行了
  Future _onRefresh() async {
    print("刷新数据...");
    p = 0;
    List<TabTopicItem> newEntries = await DioWeb.getTopicsByTabKey(widget.tabKey, p);
    setState(() {
      print("刷新数据..........");
      items.clear();
      items.addAll(newEntries);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.removeListener(_checkScrollToButtom);
    super.dispose();
  }
}
