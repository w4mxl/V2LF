import 'dart:async';
import 'dart:io';

/// @author: wml
/// @date  : 2019/4/2 11:34
/// @email : mxl1989@gmail.com
/// @desc  : Web 页面

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

const UserAgent =
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36";

class WebviewPage extends StatefulWidget {
  final String webUrl;

  WebviewPage(this.webUrl);

  @override
  _WebviewPageState createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  // On urlChanged stream
  StreamSubscription<String> _onUrlChanged;

  @override
  void initState() {
    super.initState();

    print(widget.webUrl);
    // Add a listener to on url changed
    _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        print('onUrlChanged: $url');
        if (url == 'https://www.v2ex.com/#' || url == 'https://www.v2ex.com/') {
          // google 登录成功
          // 保存cookie
          // 获取用户信息
          flutterWebViewPlugin.getCookies().then((m) async {
            print('!!!! login cookies: $m');
            List<Cookie> cookies = <Cookie>[];
            for (int i = 0; i < m.length; i++) {
              cookies.add(new Cookie(m.keys.elementAt(i), m.values.elementAt(i)));
            }
            print(cookies);
//            String cookiePath = await Utils.getCookiePath();
//            PersistCookieJar cookieJar = new PersistCookieJar(dir: cookiePath);
//            cookieJar.saveFromResponse(Uri.parse("https://www.v2ex.com/"), cookies);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: widget.webUrl,
      userAgent: UserAgent,
      appBar: AppBar(
        title: const Text('Sign in with Google'),
      ),
      withZoom: true,
      withLocalStorage: true,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                flutterWebViewPlugin.goBack();
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                flutterWebViewPlugin.goForward();
              },
            ),
            IconButton(
              icon: const Icon(Icons.autorenew),
              onPressed: () {
                flutterWebViewPlugin.reload();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _onUrlChanged.cancel();
    flutterWebViewPlugin.dispose();
    super.dispose();
  }
}
