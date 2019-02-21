import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/model/web/node.dart';
import 'package:flutter_app/network/api_web.dart';
import 'package:flutter_app/page_favourite_topics.dart';
import 'package:flutter_app/page_node_topics.dart';

// 节点导航页面
class NodesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _NodePageState();
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
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('节点导航'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: DataSearch());
              })
        ],
      ),
      body: new Container(
          color: const Color(0xFFD8D2D1),
          child: new Center(
            child: nodeGroups.length > 0
                ? new ListView.builder(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    itemBuilder: itemBuilder,
                    itemCount: nodeGroups.length,
                  )
                : CircularProgressIndicator(),
          )),
    );
  }

  Future getAllNodes() async {
    List<NodeGroup> tmpGroups = await v2exApi.getNodes();
    if (mounted) {
      this.setState(() {
        nodeGroups.clear();
        nodeGroups.addAll(tmpGroups);

        if (nodeGroups.length > 0) {
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
    return new NodeGroupWidget(nodeGroups[index], context);
  }
}

class NodeGroupWidget extends StatelessWidget {
  final NodeGroup nodeGroup;
  final BuildContext context;

  NodeGroupWidget(this.nodeGroup, this.context);

  @override
  Widget build(BuildContext context) {
    Container _container = new Container(
      padding: const EdgeInsets.all(10.0),
      child: new Column(
        children: <Widget>[
          new Text(
            nodeGroup.nodeGroupName,
            style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          new Padding(padding: const EdgeInsets.only(bottom: 10.0)),
          new Wrap(
            children: nodeGroup.nodes.map((node) => renderNode(node)).toList(),
            runAlignment: WrapAlignment.center,
            alignment: WrapAlignment.center,
            direction: Axis.horizontal,
            spacing: 6.0,
            runSpacing: 5.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            textDirection: TextDirection.ltr,
          ),
          new Padding(padding: const EdgeInsets.only(bottom: 5.0)),
        ],
      ),
    );

    return new Card(child: _container, margin: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0), color: Colors.white);
  }

  Widget renderNode(NodeItem node) {
    return new InkWell(
      child: new Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        child: new Text(
          node.nodeName,
          style: new TextStyle(color: Theme.of(context).primaryColor, fontSize: 13.0),
        ),
        decoration: new BoxDecoration(borderRadius: new BorderRadius.circular(5.0), color: Colors.white),
      ),
      onTap: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => new NodeTopics(node))),
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
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionNodes = query.isEmpty ? meLikeNodes : allNodes.where((p) => p.nodeName.startsWith(query)).toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
            leading: Icon(Icons.filter_list),
            title: RichText(
                text: TextSpan(
                    text: suggestionNodes[index].nodeName.substring(0, query.length),
                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                    children: [
                  TextSpan(
                      text: suggestionNodes[index].nodeName.substring(query.length),
                      style: DefaultTextStyle.of(context).style)
                ])),
            onTap: () =>
                Navigator.push(context, MaterialPageRoute(builder: (context) => new NodeTopics(suggestionNodes[index]))),
          ),
      itemCount: suggestionNodes.length,
    );
  }
}
