import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';
import 'package:notus/convert.dart';

import 'components/search_delegate.dart';
import 'components/search_node_delegate.dart';
import 'model/web/node.dart';
import 'utils/sp_helper.dart';

/// @author: wml
/// @date  : 2019/4/14 2:27 PM
/// @email : mxl1989@gmail.com
/// @desc  : 发布新主题

class NewTopicPage extends StatefulWidget {
  @override
  _NewTopicPageState createState() => _NewTopicPageState();
}

class _NewTopicPageState extends State<NewTopicPage> {
  // 是否第一次进入该页面
  bool isFirst = SpHelper.sp.containsKey(SP_FIRST_TIME_NEW_TOPCI);

  final ZefyrController _controller = ZefyrController(NotusDocument());
  final FocusNode _focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    if (!isFirst) {
      Future.delayed(
          Duration(seconds: 1),
          () => showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: Text('社区指导原则'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text(
                            '尊重原创',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            '请不要在 V2EX 发布任何盗版下载链接，包括软件、音乐、电影等等。V2EX 是创意工作者的社区，我们尊重原创。',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                            '友好互助',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            '保持对陌生人的友善。用知识去帮助别人。',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('知道了'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ListView(
      children: <Widget>[
        SizedBox(
          height: 4,
        ),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: '主题标题',
            helperText: '如果标题能够表达完整内容，则正文可以为空',
//            errorText: '主题标题不能为空',
          ),
          maxLength: 120,
        ),
        SizedBox(
          height: 20,
        ),
        buildEditor(),
        Row(
          children: <Widget>[
            FlatButton(
                onPressed: () {
                  Future<NodeItem> future = showSearch(context: context, delegate: SearchNodeDelegate());
                  future.then((nodeItem) {
                    if (nodeItem != null) {
                      setState(() {
                        print("wml：" + nodeItem.nodeName);
                      });
                    }
                  });
                },
                child: Text('请选择一个节点')),
          ],
        ),
      ],
    );

    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text('创建新主题'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.send),
              tooltip: 'Publish new topic',
              onPressed: () {
                print(notusMarkdown.encode(_controller.document.toDelta()));
              })
        ],
      ),
      body: ZefyrScaffold(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: form,
        ),
      ),
    );
  }

  Widget buildEditor() {
    final theme = new ZefyrThemeData(
      toolbarTheme: ZefyrToolbarTheme.fallback(context).copyWith(
        color: Colors.grey.shade800,
        toggleColor: Colors.grey.shade900,
        iconColor: Colors.white,
        disabledIconColor: Colors.grey.shade500,
      ),
    );

    return ZefyrTheme(
      data: theme,
      child: ZefyrField(
        height: 200.0,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: '正文',
          alignLabelWithHint: true,
        ),
        controller: _controller,
        focusNode: _focusNode,
//        imageDelegate: new CustomImageDelegate(),
        physics: ClampingScrollPhysics(),
      ),
    );
  }
}
