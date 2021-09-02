// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_app/components/search_node_delegate.dart';
// import 'package:flutter_app/generated/i18n.dart';
// import 'package:flutter_app/models/web/node.dart';
// import 'package:flutter_app/network/dio_web.dart';
// import 'package:flutter_app/utils/sp_helper.dart';
// import 'package:notus/convert.dart';
// import 'package:ovprogresshud/progresshud.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:zefyr/zefyr.dart';

// /// @author: wml
// /// @date  : 2019/4/14 2:27 PM
// /// @email : mxl1989@gmail.com
// /// @desc  : 发布新主题

// class NewTopicPage extends StatefulWidget {
//   @override
//   _NewTopicPageState createState() => _NewTopicPageState();
// }

// class _NewTopicPageState extends State<NewTopicPage> {
//   // 是否第一次进入该页面
//   bool isFirst = SpHelper.sp.containsKey(SP_FIRST_TIME_NEW_TOPCI);

//   final TextEditingController _titleEditingController = TextEditingController();
//   String _titleError;
//   final ZefyrController _controller = ZefyrController(NotusDocument());
//   final FocusNode _focusNode = new FocusNode();

//   NodeItem selectedNode;

//   Future _createTopic(String nodeId, String title, String content) async {
//     String result = await DioWeb.createTopic(nodeId, title, content);
//     if (result.contains('成功')) {
//       Progresshud.showSuccessWithStatus(result);
//       Navigator.of(context).pop();
//     } else {
//       print('创建主题页面：$result');
//       Progresshud.showErrorWithStatus(result);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();

//     // 设置默认操作进度加载背景
//     Progresshud.setDefaultMaskTypeBlack();

//     if (!isFirst) {
//       Future.delayed(
//           Duration(seconds: 1),
//           () => showDialog(
//               context: context,
//               builder: (BuildContext context) => AlertDialog(
//                     title: Text('社区指导原则'),
//                     content: SingleChildScrollView(
//                       child: ListBody(
//                         children: <Widget>[
//                           Text(
//                             '尊重原创',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           SizedBox(
//                             height: 6,
//                           ),
//                           Text(
//                             '请不要在 V2EX 发布任何盗版下载链接，包括软件、音乐、电影等等。V2EX 是创意工作者的社区，我们尊重原创。',
//                             style: TextStyle(fontSize: 14),
//                           ),
//                           SizedBox(
//                             height: 12,
//                           ),
//                           Text(
//                             '友好互助',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           SizedBox(
//                             height: 6,
//                           ),
//                           Text(
//                             '保持对陌生人的友善。用知识去帮助别人。',
//                             style: TextStyle(fontSize: 14),
//                           ),
//                         ],
//                       ),
//                     ),
//                     actions: <Widget>[
//                       FlatButton(
//                         child: Text('知道了'),
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     ],
//                   )));
//       SpHelper.sp.setBool(SP_FIRST_TIME_NEW_TOPCI, false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final form = ListView(
//       children: <Widget>[
//         SizedBox(
//           height: 20,
//         ),
//         TextField(
//           controller: _titleEditingController,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(),
//             labelText: '主题标题',
//             helperText: '如果标题能够表达完整内容，则正文可以为空',
//             errorText: _titleError,
//           ),
//           autocorrect: true,
//           maxLength: 120,
//         ),
//         SizedBox(
//           height: 20,
//         ),
//         buildEditor(),
//         SizedBox(
//           height: 24,
//         ),
//         GestureDetector(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: <Widget>[
//               Icon(Icons.image),
//               SizedBox(
//                 width: 4,
//               ),
//               Text('上传图片获得链接'),
//             ],
//           ),
//           onTap: () => launch('https://sm.ms/', statusBarBrightness: Platform.isIOS ? Brightness.light : null),
//         )
//       ],
//     );

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         title: Text(S.of(context).createTitle),
//         actions: <Widget>[
//           IconButton(
//               icon: Icon(Icons.send),
//               tooltip: 'Publish new topic',
//               onPressed: () {
//                 if (_titleEditingController.text.trim().isEmpty) {
//                   setState(() {
//                     _titleError = '标题不能为空';
//                   });
//                 } else if (selectedNode == null) {
//                   Progresshud.showErrorWithStatus('请选择节点');
//                   setState(() {
//                     _titleError = null;
//                   });
//                 } else {
//                   print(selectedNode.nodeId);
//                   print(_titleEditingController.text.trim());
//                   print(notusMarkdown.encode(_controller.document.toDelta()));
//                   _createTopic(selectedNode.nodeId, _titleEditingController.text.trim(),
//                       notusMarkdown.encode(_controller.document.toDelta()));
//                 }
//               })
//         ],
//       ),
//       body: ZefyrScaffold(
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: form,
//         ),
//       ),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 30.0),
//         child: FloatingActionButton.extended(
//           onPressed: () {
//             Future<NodeItem> future = showSearch(context: context, delegate: SearchNodeDelegate());
//             future.then((nodeItem) {
//               if (nodeItem != null) {
//                 setState(() {
//                   selectedNode = nodeItem;
//                   print("wml：" + nodeItem.nodeName);
//                 });
//               }
//             });
//           },
//           icon: Icon(Icons.bubble_chart),
//           label: Text(selectedNode != null ? selectedNode.nodeName : '节点'),
//         ),
//       ),
//     );
//   }

//   Widget buildEditor() {
//     final theme = new ZefyrThemeData(
//       toolbarTheme: ToolbarTheme.fallback(context).copyWith(
//         color: Colors.grey.shade800,
//         toggleColor: Colors.grey.shade900,
//         iconColor: Colors.white,
//         disabledIconColor: Colors.grey.shade500,
//       ),
//     );

//     return ZefyrTheme(
//       data: theme,
//       child: ZefyrField(
//         height: 300,
//         decoration: InputDecoration(
//           border: OutlineInputBorder(),
//           helperText: '可以在正文中为你要发布的主题添加更多细节',
//           alignLabelWithHint: true,
//         ),
//         controller: _controller,
//         focusNode: _focusNode,
// //        imageDelegate: new CustomImageDelegate(),
//         physics: ClampingScrollPhysics(),
//       ),
//     );
//   }
// }
