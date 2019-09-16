import 'package:cached_network_image/cached_network_image.dart';

/// @author: wml
/// @date  : 2019-09-05 18:01
/// @email : mxl1989@gmail.com
/// @desc  : 用户个人信息页面

// 没登录：他人
// 登录: 本人、他人

import 'package:flutter/material.dart';
import 'package:flutter_app/theme/theme_data.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            itemCount: 1,
          ),
          // 左上角返回按钮
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0.0,
            child: IconTheme(
              data: const IconThemeData(color: Colors.white),
              child: SafeArea(
                top: false,
                bottom: false,
                child: IconButton(
                  icon: const BackButtonIcon(),
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
                    Column(
                      children: <Widget>[
                        Text(
                          "这里是签名",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                      ],
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
                    SizedBox(
                      height: 16.0,
                    ),
                    Container(
                      height: 80.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: ListTile(
                              title: Text(
                                "302",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text("Posts".toUpperCase(),
                                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12.0)),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: Text(
                                "10.3K",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text("Followers".toUpperCase(),
                                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12.0)),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: Text(
                                "120",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text("Followi".toUpperCase(),
                                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12.0)),
                            ),
                          ),
                        ],
                      ),
                    )
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
}
