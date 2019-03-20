import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/sov2ex.dart';
import 'package:flutter_app/model/web/node.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// @author: wml
/// @date  : 2019/3/19 10:10 PM
/// @email : mxl1989@gmail.com
/// @desc  : SearchDelegate

List<NodeItem> allNodes = <NodeItem>[];

class MySearchDelegate extends SearchDelegate<String> {
  final List<String> _history = ['v2er', 'AirPods'];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          query = "";
          showSuggestions(context);
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
//    return Center(child: Text('┐(´-｀)┌'));
    return buildSearchFutureBuilder(query.trim());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
//    final suggestionNodes = query.isEmpty ? meLikeNodes : allNodes.where((p) => p.nodeName.startsWith(query)).toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
            leading: Icon(Icons.history),
            title: Text(_history[index]),
            onTap: () {},
//            Navigator.push(context, MaterialPageRoute(builder: (context) => new NodeTopics(suggestionNodes[index]))),
          ),
      itemCount: _history.length,
    );
  }

  FutureBuilder<Sov2ex> buildSearchFutureBuilder(String q) {
    return new FutureBuilder<Sov2ex>(
      future: getSov2exData(q),
      builder: (context, AsyncSnapshot<Sov2ex> async) {
        if (async.connectionState == ConnectionState.active || async.connectionState == ConnectionState.waiting) {
          return new Center(
            child: new CircularProgressIndicator(),
          );
        }

        if (async.connectionState == ConnectionState.done) {
          if (async.hasError) {
            return new Center(
              child: new Text('${async.error}'),
            );
          } else if (async.hasData) {
            Sov2ex sov2ex = async.data;
            return Sov2exResultListView(sov2ex.hits);
          }
        }
      },
    );
  }

  Future<Sov2ex> getSov2exData(String q) async {
    var dio = Dio();
    try {
      var response = await dio.get('https://www.sov2ex.com/api/search?size=50&q=' + q);
      print(response.data);
      return Sov2ex.fromMap(response.data);
    } on DioError catch (e) {
      Fluttertoast.showToast(msg: '搜索失败');
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request);
      return null;
    }
  }
}

class Sov2exResultListView extends StatelessWidget {
  final List<HitsListBean> hits;

  Sov2exResultListView(this.hits);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: hits.length,
        itemBuilder: (context, index) {
          return Sov2exResultItem(hits[index]);
        });
  }
}

class Sov2exResultItem extends StatelessWidget {
  final HitsListBean hitsListBean;

  Sov2exResultItem(this.hitsListBean);

  @override
  Widget build(BuildContext context) {
    String content = hitsListBean.highlight.content != null
        ? hitsListBean.highlight.content[0].replaceAll('<em>', '<mark>').replaceAll('<\/em>', '<\/mark>')
        : (hitsListBean.highlight.postscript_list != null
            ? hitsListBean.highlight.postscript_list[0].replaceAll('<em>', '<mark>').replaceAll('<\/em>', '<\/mark>')
            : (hitsListBean.highlight.reply_list != null
                ? hitsListBean.highlight.reply_list[0].replaceAll('<em>', '<mark>').replaceAll('<\/em>', '<\/mark>')
                : hitsListBean.source.content));

    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Html(
            data: hitsListBean.highlight.title != null
                ? hitsListBean.highlight.title[0].replaceAll('<em>', '<mark>').replaceAll('<\/em>', '<\/mark>')
                : hitsListBean.source.title,
            defaultTextStyle: TextStyle(color: Colors.black87, fontSize: 18.0),
          ),
          SizedBox(
            height: 10.0,
          ),
          Html(
            data: content,
            defaultTextStyle: TextStyle(color: Colors.black54, fontSize: 15.0),
          ),
          Divider(
            height: 6.0,
          )
        ],
      ),
    );
  }
}
