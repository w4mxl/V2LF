import 'dart:async';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';

/// @author: wml
/// @date  : 2019/4/2 11:34
/// @email : mxl1989@gmail.com
/// @desc  : Web 页面

import 'package:flutter/material.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/network/dio_web.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:flutter_app/utils/utils.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

    // 请确保能正常访问 Google
    // 请手动点击 "Sign in with Google"
    // 输入完账号密码后请勿关闭网页, 加载成功后会自动关闭
    Fluttertoast.showToast(
        msg: '请确保能正常访问 Google\n请手动点击 "Sign in with Google"\n输入完账号密码后请勿关闭网页, 加载成功后会自动关闭',
        timeInSecForIos: 4,
        gravity: ToastGravity.CENTER);

    print(widget.webUrl);
    // Add a listener to on url changed
    _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        print('onUrlChanged: $url');
        if (url == 'https://www.v2ex.com/#' || url == 'https://www.v2ex.com/') {
          // google 登录成功
          // 保存cookie
          // 获取用户信息
          getCookies().then((m) async {
            // 只需要保存 A2 cookie
            print('!!!! logined cookies: $m');
            // {
            // A2: "2|1:0|10:1557993514|2:A2|56:M2IyZmU2Y2Q3ZWRjMzk0MjczYjk5YzdkY2FkNDZlZTRkNmJiNjgxNg==|ff78965b2154e884ef2e7d01421d25d20ba70d1b460412ea55cd5239f704e231",
            // V2EX_LANG: zhcn,
            // _ga: GA1.2.1664839063.1557910385,
            // _gat: 1,  _gid: GA1.2.955802139.1557910385
            // }
            Cookie cookie = new Cookie(m.keys.elementAt(0), m.values.elementAt(0));
            print("A2 cookie: " + cookie.toString());
            String cookiePath = await Utils.getCookiePath();
            PersistCookieJar cookieJar = new PersistCookieJar(dir: cookiePath);
            cookieJar.saveFromResponse(Uri.parse("https://www.v2ex.com/"), <Cookie>[cookie]);

            // 获取用户信息，保存
            String result = await DioWeb.getUserInfo();
            if (result == "true") {
              Fluttertoast.showToast(
                  msg: S.of(context).toastLoginSuccess(SpHelper.sp.getString(SP_USERNAME)),
                  timeInSecForIos: 2,
                  gravity: ToastGravity.CENTER);
              Navigator.of(context).pop(true);
            }
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

  /// 重写 flutter_webview_plugin 库 base.dart 218 行的 getCookies 方法
  Future<Map<String, String>> getCookies() async {
    final cookiesString = await flutterWebViewPlugin.evalJavascript('document.cookie');
    final cookies = <String, String>{};

    if (cookiesString?.isNotEmpty == true) {
      cookiesString.split(';').forEach((String cookie) {
        final split = cookie.replaceFirst('=', 'wmlwmlwmlwml').split('wmlwmlwmlwml');
        cookies[split[0]] = split[1];
      });
    }

    return cookies;
  }
}
