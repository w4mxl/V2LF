import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';

/// @author: wml
/// @date  : 2019/4/14 2:27 PM
/// @email : mxl1989@gmail.com
/// @desc  : 发布新主题

class NewTopicPage extends StatefulWidget {
  @override
  _NewTopicPageState createState() => _NewTopicPageState();
}

class _NewTopicPageState extends State<NewTopicPage> {

  final ZefyrController _controller = ZefyrController(NotusDocument());
  final FocusNode _focusNode = new FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {

    final form = ListView(
      children: <Widget>[
        TextField(decoration: InputDecoration(labelText: 'Name')),
        buildEditor(),
        TextField(decoration: InputDecoration(labelText: 'Email')),
      ],
    );

    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        elevation: 1.0,
        backgroundColor: Colors.grey.shade200,
        brightness: Brightness.light,
        title: Text('创建新主题'),
      ),
      body: ZefyrScaffold(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
        decoration: InputDecoration(labelText: 'Description'),
        controller: _controller,
        focusNode: _focusNode,
        autofocus: true,
//        imageDelegate: new CustomImageDelegate(),
        physics: ClampingScrollPhysics(),
      ),
    );
  }

}
