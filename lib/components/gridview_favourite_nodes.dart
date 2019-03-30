import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
/**
 * @author: wml
 * @date  : 2019/3/30 6:20 PM
 * @email : mxl1989@gmail.com
 * @desc  : 收藏的节点
 */

import 'package:flutter/material.dart';
import 'package:flutter_app/model/web/item_fav_node.dart';
import 'package:flutter_app/network/dio_singleton.dart';

class FavouriteNodesGrid extends StatefulWidget {
  @override
  _FavouriteNodesGridState createState() => _FavouriteNodesGridState();
}

class _FavouriteNodesGridState extends State<FavouriteNodesGrid> {
  Future<List<FavNode>> _future;

  Future<List<FavNode>> getFavNodes() async {
    return await dioSingleton.getFavNodes();
  }

  @override
  void initState() {
    super.initState();

    _future = getFavNodes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FavNode>>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<List<FavNode>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return new Center(
              child: new CircularProgressIndicator(),
            );
          case ConnectionState.done:
            if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
            return GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 0.6,
              mainAxisSpacing: 6,
              crossAxisSpacing: 4,
              padding: EdgeInsets.all(8.0),
              children: snapshot.data.map((FavNode node) {
                return _gridItem(node);
              }).toList(),
            );
        }
        return null; // unreachable
      },
    );
  }

  Widget _gridItem(FavNode node) {
    return InkWell(
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: node.img,
              fit: BoxFit.fill,
              width: 73,
              height: 73,
              placeholder: (context, url) => Icon(Icons.photo, size: 32.0, color: Color(0xFFcccccc)),
            ),
            Column(
              children: <Widget>[
                Text(node.nodeName),
                SizedBox(
                  height: 6,
                ),
                Icon(
                  Icons.forum,
                  size: 14,
                  color: Colors.grey,
                ),
                Text(
                  node.replyCount,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
