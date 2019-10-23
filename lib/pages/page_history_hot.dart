import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/components/bubble_tab_indicator.dart';
import 'package:flutter_app/pages/page_topic_detail.dart';
import 'package:http/http.dart';
import 'package:webfeed/webfeed.dart';

/// @author: wml
/// @date  : 2019/3/24 2:47 PM
/// @email : mxl1989@gmail.com
/// @desc  : 历史热门主题
///
/// 2019-05-21 18:21：被 page_history_hot_category 取代

class HistoryHotTopics extends StatefulWidget {
  @override
  _HistoryHotTopicsState createState() => _HistoryHotTopicsState();
}

class _HistoryHotTopicsState extends State<HistoryHotTopics> with AutomaticKeepAliveClientMixin {
  final List<Tab> tabs = <Tab>[
    new Tab(text: "昨天最热"),
    new Tab(text: "前天最热"),
  ];

  Future<AtomFeed> _future;

  @override
  void initState() {
    super.initState();

    _future = getFeed();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: TabBar(
                isScrollable: true,
                indicator: new BubbleTabIndicator(
                  indicatorColor: Theme.of(context).primaryColorBrightness == Brightness.dark
                      ? Theme.of(context).focusColor
                      : Colors.white,
                ),
                tabs: tabs),
          ),
          body: buildFutureBuilder(),
        ));
  }

  FutureBuilder<AtomFeed> buildFutureBuilder() {
    return FutureBuilder<AtomFeed>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var splitDate = snapshot.data.updated.split('T')[0];

            print(snapshot.data.items.lastIndexWhere((item) => item.updated.startsWith(splitDate)));
            var lastIndexWhere = snapshot.data.items.lastIndexWhere((item) => item.updated.startsWith(splitDate));

            List<AtomItem> yesterdayList = snapshot.data.items.sublist(0, lastIndexWhere + 1);
            List<AtomItem> beforeYesterdayList = snapshot.data.items.sublist(lastIndexWhere + 1);

            return TabBarView(
              children: <Widget>[
                new TabBarViewChild(dayTopicList: yesterdayList),
                new TabBarViewChild(dayTopicList: beforeYesterdayList)
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("${snapshot.error}"),
            );
          }
          return Center(
            child: Platform.isIOS ? CupertinoActivityIndicator() : CircularProgressIndicator(),
          );
        });
  }

  Future<AtomFeed> getFeed() async {
    // Atom feed
    Utf8Decoder utf8decoder = Utf8Decoder(); // 需要转码一下，不然中文出现乱码
    return get(
      "https://v2exday.com/all.xml",
    ).then((response) {
      return utf8decoder.convert(response.bodyBytes);
    }).then((bodyString) {
      AtomFeed feed = new AtomFeed.parse(bodyString);
      print(feed.items[0].authors[0].name);
      return feed;
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class TabBarViewChild extends StatelessWidget {
  const TabBarViewChild({
    Key key,
    @required this.dayTopicList,
  }) : super(key: key);

  final List<AtomItem> dayTopicList;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView(
        children: ListTile.divideTiles(
                context: context,
                tiles: dayTopicList.map((AtomItem item) {
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    // <title>[Apple] 有带 Apple Watch 过敏的小伙伴吗？</title>
                    title: Text(item.title.replaceFirst(']', '4444').split('4444')[1]), // 这样处理能保证通过 ']' 分割的准确性
                    subtitle: Text('${item.title.split(']')[0].replaceFirst('[', '')} · ${item.authors[0].name}'),
                    onTap: () => Navigator.push(
                      context,
                      new MaterialPageRoute(builder: (context) => new TopicDetails(item.links[0].href.split('/t/')[1])),
                    ),
                  );
                }).toList())
            .toList(),
      ),
    );
  }
}
