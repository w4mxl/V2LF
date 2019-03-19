import 'package:flutter/material.dart';
import 'package:flutter_app/model/web/node.dart';

/**
 * @author: wml
 * @date  : 2019/3/19 10:10 PM
 * @email : mxl1989@gmail.com
 * @desc  : SearchDelegate
 */


List<NodeItem> allNodes = <NodeItem>[];

class MySearchDelegate extends SearchDelegate<String> {
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
      icon: AnimatedIcon(icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
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
    final suggestionNodes = query.isEmpty ? meLikeNodes : allNodes.where((p) => p.nodeName.startsWith(query)).toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        leading: Icon(Icons.navigate_next),
        title: RichText(
            text: TextSpan(
                text: suggestionNodes[index].nodeName.substring(0, query.length),
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text: suggestionNodes[index].nodeName.substring(query.length),
                      style: DefaultTextStyle.of(context).style)
                ])),
        onTap: null
//            Navigator.push(context, MaterialPageRoute(builder: (context) => new NodeTopics(suggestionNodes[index]))),
      ),
      itemCount: suggestionNodes.length,
    );
  }
}