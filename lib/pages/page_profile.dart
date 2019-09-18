import 'package:cached_network_image/cached_network_image.dart';

/// @author: wml
/// @date  : 2019-09-05 18:01
/// @email : mxl1989@gmail.com
/// @desc  : 用户个人信息页面

// 没登录：他人
// 登录: 本人、他人

import 'package:flutter/material.dart';
import 'package:flutter_app/components/listview_favourite_topics.dart';
import 'package:flutter_app/network/dio_web.dart';
import 'package:flutter_app/theme/theme_data.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DioWeb.getMemberProfile("d5");

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [MyTheme.appMainColor.shade300, MyTheme.appMainColor.shade500]),
            ),
          ),
          ListView.builder(
            itemBuilder: _mainListBuilder,
            itemCount: 4,
          ),
          // 左上角返回按钮
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0.0,
            child: IconTheme(
              data: IconThemeData(color: Colors.white),
              child: SafeArea(
                top: false,
                bottom: false,
                child: IconButton(
                  icon: BackButtonIcon(),
                  tooltip: 'Back',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainListBuilder(BuildContext context, int index) {
    if (index == 0) return _buildHeader(context);
    if (index == 1) return _buildRecentTopicsHeader(context);
    if (index == 2) return FavTopicListView();
    if (index == 3) return _buildRecentRepliesHeader(context);
  }

  // 头像区域
  Container _buildHeader(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 50.0),
      //height: 260.0,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 40.0, left: 40.0, right: 40.0, bottom: 10.0),
            child: Material(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              elevation: 5.0,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 50.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "w4mxl",
                          style: Theme.of(context).textTheme.title,
                        ),
                        // todo 判断用户是否在线
                        Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: ClipOval(
                            child: Container(
                              color: Colors.green,
                              width: 8,
                              height: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Text(
                        "这里是签名",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 14),
                        children: [
                          TextSpan(
                            text: '上海市众安xxxxxxxxxxxxxxx科技股份有限公司',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: ' / 工程师',
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      "V2EX xxxxxxxxx第 62179 号会员，加入于 2014-05-08 13:33:07",
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                      textAlign: TextAlign.center,
                    ),
                    Divider(),
                    Wrap(
                      spacing: 8,
                      runSpacing: -5,
                      children: <Widget>[
                        Chip(
                          avatar: CachedNetworkImage(imageUrl: 'https://www.v2ex.com/static/img/social_home.png'),
                          label: Text(
                            'https://w4mxl.github.io',
                          ),
                          backgroundColor: Colors.grey[200],
                        ),
                        Chip(
                          avatar: CachedNetworkImage(imageUrl: 'https://www.v2ex.com/static/img/social_geo.png'),
                          label: Text('上海'),
                          backgroundColor: Colors.grey[200],
                        ),
                        Chip(
                          avatar: CachedNetworkImage(imageUrl: 'https://www.v2ex.com/static/img/social_instagram.png'),
                          label: Text('w4mxl'),
                          backgroundColor: Colors.grey[200],
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        '这是用户的个人简介内容',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Material(
                elevation: 5.0,
                shape: CircleBorder(),
                child: CircleAvatar(
                  radius: 40.0,
                  backgroundImage: CachedNetworkImageProvider(
                      'https://cdn.v2ex.com/gravatar/bf07a96ee6f886e82c49f081f87b2c25?s=73&d=retro'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container _buildRecentTopicsHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'w4mxl 最近主题',
            style: Theme.of(context).textTheme.title,
          ),
          FlatButton(
              onPressed: () {},
              child: Text(
                'SEE ALL',
                style: TextStyle(color: Colors.blue),
              ))
        ],
      ),
    );
  }

  Container _buildRecentRepliesHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'w4mxl 最近回复',
            style: Theme.of(context).textTheme.title,
          ),
          FlatButton(
              onPressed: () {},
              child: Text(
                'SEE ALL',
                style: TextStyle(color: Colors.blue),
              ))
        ],
      ),
    );
  }
}
