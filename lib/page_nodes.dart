import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/model/web/node.dart';
import 'package:flutter_app/network/api_web.dart';
import 'package:flutter_app/page_node_topics.dart';

// 节点导航页面
class NodesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _NodePageState();
  }
}

class _NodePageState extends State<NodesPage> {
  List<NodeGroup> nodeGroups = <NodeGroup>[];

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
        actions: <Widget>[IconButton(icon: Icon(Icons.search), onPressed: () {})],
      ),
      body: new Container(
          color: const Color(0xFFD8D2D1),
          child: new Center(
            child: new ListView.builder(
              padding: const EdgeInsets.only(bottom: 15.0),
              itemBuilder: itemBuilder,
              itemCount: nodeGroups.length,
            ),
          )),
    );
  }

  Future getAllNodes() async {
    List<NodeGroup> tmpGroups = await v2exApi.getNodes();
    if (mounted) {
      this.setState(() {
        nodeGroups.clear();
        nodeGroups.addAll(tmpGroups);
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

    return new Card(
        child: _container, margin: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0), color: Colors.white);
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

class DataSearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return null;
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return null;
  }
}
