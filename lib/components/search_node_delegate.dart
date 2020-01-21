import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/web/node.dart';
import 'package:flutter_app/network/api_network.dart';

/// @author: wml
/// @date  : 2019/4/14 10:57 PM
/// @email : mxl1989@gmail.com
/// @desc  : 搜索节点

class SearchNodeDelegate extends SearchDelegate<NodeItem> {
  final List<NodeItem> hotNodes = <NodeItem>[
    NodeItem('qna', '问与答'),
    NodeItem('jobs', '酷工作'),
    NodeItem('share', '分享发现'),
    NodeItem('programmer', '程序员'),
    NodeItem('macos', 'macOS'),
    NodeItem('create', '分享创造'),
    NodeItem('python', 'Python'),
    NodeItem('apple', 'Apple'),
    NodeItem('android', 'Android'),
    NodeItem('iphone', 'iPhone'),
    NodeItem('career', '职场话题'),
    NodeItem('bb', '宽带症候群'),
    NodeItem('gts', '全球工单系统'),
    NodeItem('cv', '求职'),
    NodeItem('linux', 'Linux'),
  ];

  Future<List<NodeItem>> _future;

  @override
  ThemeData appBarTheme(BuildContext context) {
    // todo 还需理解，找出更好的解决方式
    if (Theme.of(context).brightness == Brightness.dark) {
      final ThemeData theme = Theme.of(context);
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
          query = "";
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
    if (query.isEmpty) {
      return Center(child: Text('┐(´-｀)┌'));
    }

    _future = NetworkApi.getAllNodes();
    return buildSearchFutureBuilder(query.trim());
  }

  FutureBuilder<List<NodeItem>> buildSearchFutureBuilder(String q) {
    return new FutureBuilder<List<NodeItem>>(
      future: _future,
      builder: (context, AsyncSnapshot<List<NodeItem>> async) {
        if (async.connectionState == ConnectionState.active || async.connectionState == ConnectionState.waiting) {
          return new Center(
            child: Platform.isIOS ? CupertinoActivityIndicator() : CircularProgressIndicator(),
          );
        }

        if (async.connectionState == ConnectionState.done) {
          if (async.hasError) {
            return new Center(
              child: new Text('${async.error}'),
            );
          } else if (async.hasData) {
            List<NodeItem> allNodes = async.data;
            var resultNodes = allNodes.where((p) => p.nodeName.toLowerCase().contains(query.toLowerCase())).toList();

            return ListView.builder(
              itemBuilder: (context, index) => ListTile(
                title: Text(resultNodes[index].nodeName),
                trailing: Icon(Icons.navigate_next),
                onTap: () => close(context, resultNodes[index]),
              ),
              itemCount: resultNodes.length,
            );
          }
        }
        return Container();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionNodes =
        query.isEmpty ? hotNodes : hotNodes.where((p) => p.nodeName.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.separated(
      itemBuilder: (context, index) => ListTile(
        title: Text(suggestionNodes[index].nodeName),
        trailing: Icon(Icons.whatshot),
        onTap: () => close(context, suggestionNodes[index]),
      ),
      itemCount: suggestionNodes.length,
      separatorBuilder: (context, index) => Divider(height: 0),
    );
  }
}
