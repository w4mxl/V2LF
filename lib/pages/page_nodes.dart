import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/models/web/node.dart';
import 'package:flutter_app/network/dio_web.dart';
import 'package:flutter_app/pages/page_node_topics.dart';

// 节点导航页面
class NodesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NodePageState();
  }
}

List<NodeGroup> nodeGroups = <NodeGroup>[];
List<NodeItem> allNodes = <NodeItem>[];

class _NodePageState extends State<NodesPage> {
  @override
  void initState() {
    super.initState();
    getAllNodes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).nodes),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: DataSearch());
              })
        ],
      ),
      body: Container(
//          color: MyTheme.isDark ? Colors.black : CupertinoColors.lightBackgroundGray,
          child: Center(
        child: nodeGroups.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.only(bottom: 15.0),
                itemBuilder: itemBuilder,
                itemCount: nodeGroups.length,
              )
            : Platform.isIOS
                ? CupertinoActivityIndicator()
                : CircularProgressIndicator(),
      )),
    );
  }

  Future getAllNodes() async {
    var tmpGroups = await DioWeb.getNodes();
    if (mounted) {
      setState(() {
        nodeGroups.clear();
        nodeGroups.addAll(tmpGroups);

        if (nodeGroups.isNotEmpty) {
          for (var nodeGroup in nodeGroups) {
            for (var nodeItem in nodeGroup.nodes) {
              allNodes.add(nodeItem);
            }
          }
        }
      });
    }
  }

  Widget itemBuilder(BuildContext context, int index) {
    return NodeGroupWidget(nodeGroups[index], context);
  }
}

class NodeGroupWidget extends StatelessWidget {
  final NodeGroup nodeGroup;
  final BuildContext context;

  const NodeGroupWidget(this.nodeGroup, this.context);

  @override
  Widget build(BuildContext context) {
    var _container = Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Text(
            nodeGroup.nodeGroupName,
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
          ),
          Padding(padding: const EdgeInsets.only(bottom: 10.0)),
          Wrap(
            runAlignment: WrapAlignment.center,
            alignment: WrapAlignment.center,
            direction: Axis.horizontal,
            spacing: 6.0,
            runSpacing: 5.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            textDirection: TextDirection.ltr,
            children: nodeGroup.nodes.map((node) => renderNode(node)).toList(),
          ),
          Padding(padding: const EdgeInsets.only(bottom: 5.0)),
        ],
      ),
    );

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      child: _container,
    );
  }

  Widget renderNode(NodeItem node) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => NodeTopics(
                    node.nodeId,
                    nodeName: node.nodeName,
                  ))),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        child: Text(
          node.nodeName,
          style:
              TextStyle(color: Theme.of(context).accentColor, fontSize: 14.0),
        ),
      ),
    );
  }
}

// 论坛节点搜索
class DataSearch extends SearchDelegate<String> {
  final List<NodeItem> meLikeNodes = <NodeItem>[
    NodeItem('share', '分享发现'),
    NodeItem('programmer', '程序员'),
    NodeItem('kindle', 'Kindle'),
    NodeItem('iphone', 'iPhone'),
    NodeItem('ipad', 'iPad'),
    NodeItem('invest', '投资'),
    NodeItem('jobs', '酷工作'),
    NodeItem('shanghai', '上海'),
  ];

  @override
  ThemeData appBarTheme(BuildContext context) {
    // todo 还需理解，找出更好的解决方式
    if (Theme.of(context).brightness == Brightness.dark) {
      final theme = Theme.of(context);
      return theme.copyWith(
        primaryColor: theme.primaryColor,
        primaryIconTheme: theme.primaryIconTheme,
        primaryColorBrightness: theme.primaryColorBrightness,
        primaryTextTheme: theme.primaryTextTheme,
      );
    } else {
      return super.appBarTheme(context);
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(CupertinoIcons.clear_circled_solid),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text('┐(´-｀)┌'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionNodes = query.isEmpty
        ? meLikeNodes
        : allNodes.where((p) => p.nodeName.startsWith(query)).toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        title: RichText(
            text: TextSpan(
                text:
                    suggestionNodes[index].nodeName.substring(0, query.length),
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold),
                children: [
              TextSpan(
                  text: suggestionNodes[index].nodeName.substring(query.length),
                  style: DefaultTextStyle.of(context).style)
            ])),
        trailing: Icon(Icons.navigate_next),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NodeTopics(
                      suggestionNodes[index].nodeId,
                      nodeName: suggestionNodes[index].nodeName,
                    ))),
      ),
      itemCount: suggestionNodes.length,
    );
  }
}
