import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/page_topic_detail.dart';
import 'package:flutter_app/utils/bubble_tab_indicator.dart';
import 'package:http/http.dart';
import 'package:webfeed/webfeed.dart';

/// @author: wml
/// @date  : 2019/3/24 2:47 PM
/// @email : mxl1989@gmail.com
/// @desc  : 历史热门主题

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
            title: TabBar(
                isScrollable: true,
//                unselectedLabelColor: Colors.grey,
                labelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: new BubbleTabIndicator(
                  indicatorHeight: 30.0,
                  indicatorColor: Colors.blueAccent,
                  tabBarIndicatorSize: TabBarIndicatorSize.tab,
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
            child: CircularProgressIndicator(),
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
                    title: Text(item.title.split(']')[1]),
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
