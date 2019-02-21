import 'dart:async';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/i10n/localization_intl.dart';
import 'package:flutter_app/model/web/item_fav_topic.dart';
import 'package:flutter_app/model/web/item_topic_reply.dart';
import 'package:flutter_app/model/web/login_form_data.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:xpath/xpath.dart';
import 'package:path_provider/path_provider.dart';

DioSingleton dioSingleton = new DioSingleton();

class DioSingleton {
  static final v2exHost = "https://www.v2ex.com";

  Dio _dio;

  static final DioSingleton _dioSingleton = DioSingleton._internal();

  factory DioSingleton() => _dioSingleton;

  DioSingleton._internal() {
    if (_dio == null) {
      Options options = new Options();
      options.baseUrl = v2exHost;
      options.receiveTimeout = 10 * 1000;
      options.connectTimeout = 5 * 1000;
      options.headers = {
        'user-agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
      };
      _dio = new Dio(options);
    }
  }

  // 获取登录信息
  Future<LoginFormData> parseLoginForm() async {
    // name password captcha once
    LoginFormData loginFormData = new LoginFormData();
    _dio.options.contentType = ContentType.json;
    _dio.options.responseType = ResponseType.JSON;
    _dio.options.headers = {
      'user-agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
    };
    var response = await _dio.get("/signin");
    var tree = ETree.fromString(response.data);
    loginFormData.username =
        tree.xpath("//*[@id='Wrapper']/div/div[1]/div[2]/form/table/tr[1]/td[2]/input[@class='sl']").first.attributes["name"];
    loginFormData.password =
        tree.xpath("//*[@id='Wrapper']/div/div[1]/div[2]/form/table/tr[2]/td[2]/input[@class='sl']").first.attributes["name"];
    loginFormData.captcha =
        tree.xpath("//*[@id='Wrapper']/div/div[1]/div[2]/form/table/tr[4]/td[2]/input[@class='sl']").first.attributes["name"];
    loginFormData.once =
        tree.xpath("//*[@id='Wrapper']/div/div[1]/div[2]/form/table/tr[2]/td[2]/input[@name='once']").first.attributes["value"];

    print(" \n" + loginFormData.username + "\n" + loginFormData.password + "\n" + loginFormData.captcha + "\n" + loginFormData.once);

    _dio.options.responseType = ResponseType.STREAM;
    response = await _dio.get("/_captcha?once=" + loginFormData.once);
    var uint8list = await consolidateHttpClientResponseBytes(response.data);
    if (uint8list.lengthInBytes == 0) throw new Exception('NetworkImage is an empty file');
    loginFormData.bytes = uint8list;

    return loginFormData;
  }

  // 登录 POST -> 获取用户信息
  Future<bool> loginPost(LoginFormData loginFormData) async {
    Directory tempDir = await getTemporaryDirectory();
    _dio.cookieJar = new PersistCookieJar(dir: tempDir.path);

    _dio.options.headers = {
      "Origin": v2exHost,
      "Referer": v2exHost + "/signin",
      'user-agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
    };
    _dio.options.contentType = ContentType.parse("application/x-www-form-urlencoded");
    _dio.options.responseType = ResponseType.JSON;
    _dio.options.validateStatus = (int status) {
      return status >= 200 && status < 300 || status == 304 || status == 302;
    };

    FormData formData = new FormData.from({
      "once": loginFormData.once,
      "next": "/",
      loginFormData.username: loginFormData.usernameInput,
      loginFormData.password: loginFormData.passwordInput,
      loginFormData.captcha: loginFormData.captchaInput
    });

    try {
      var response = await _dio.post("/signin", data: formData);
      if (response.statusCode == 302) {
        // 这里实际已经登录成功了
        _dio.options.headers = {
          'user-agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
        };
        _dio.options.contentType = ContentType.json;
        response = await _dio.get(v2exHost);
      }
      var tree = ETree.fromString(response.data);
      var elementOfAvatarImg = tree.xpath("//*[@id='Top']/div/div/table/tr/td[3]/a[1]/img[1]")?.first;
      if (elementOfAvatarImg != null) {
        // 获取用户头像
        String avatar = elementOfAvatarImg.attributes["src"];
        // 获取到的是24*24大小，改成73*73
        //cdn.v2ex.com/gravatar/3896b6baf91ec1933c38f370964647b7?s=24&d=retro%0A
        //cdn.v2ex.com/avatar/d8fe/ee94/193847_normal.png?m=1477551256
        var regExp1 = RegExp(r's=24');
        var regExp2 = RegExp(r'normal');
        if (avatar.contains(regExp1)) {
          avatar = avatar.replaceFirst(regExp1, 's=73');
        } else if (avatar.contains(regExp2)) {
          avatar = avatar.replaceFirst(regExp2, 'large');
        }

        String href = elementOfAvatarImg.parent.attributes["href"]; // "/member/w4mxl"
        var username = href.substring('/member/'.length);
        // 保存 username avatar
        SpHelper.sp.setString(SP_AVATAR, avatar);
        SpHelper.sp.setString(SP_USERNAME, username);
        // todo 判断用户是否开启了两步验证
        return true;
      } else {
        // //*[@id="Wrapper"]/div/div[1]/div[3]/ul/li
        var errorInfo = tree.xpath('//*[@id="Wrapper"]/div/div[1]/div[3]/ul/li/text()')[0].name;
        print("wml error!!!!：$errorInfo");
        Fluttertoast.showToast(msg: '登录过程中遇到一些问题：$errorInfo');
        return false;
      }
    } on DioError catch (e) {
      // todo
      Fluttertoast.showToast(msg: '登录失败');
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request);
      return false;
    }
  }

  // 获取「我的收藏」下的topics
  Future<List<FavTopicItem>> getFavTopics(int p) async {
    List<FavTopicItem> topics = new List<FavTopicItem>();
    // 调用 _dio 之前检查登录时保存的cookie是否带上了
    var response = await _dio.get(v2exHost + "/my/topics" + "?p="+ p.toString()); // todo 可能多页
    var tree = ETree.fromString(response.data);
    var aRootNode = tree.xpath("//*[@class='cell item']");
    for (var aNode in aRootNode) {

      FavTopicItem favTopicItem = new FavTopicItem();
      favTopicItem.avatar = aNode.xpath("./table/tr/td[1]/a[1]/img[@class='avatar']").first.attributes["src"];
      favTopicItem.nodeName = aNode.xpath("./table/tr/td[3]/span[2]/a[1]/text()")[0].name;
      favTopicItem.memberId = aNode.xpath("./table/tr/td[3]/span[2]/strong[1]/a/text()")[0].name;

      topics.add(favTopicItem);

    }
    return topics;
  }

  // 获取帖子下面的评论信息
  Future<List<ReplyItem>> parseTopicReplies(String topicId) async {
    List<ReplyItem> replies = new List();

    var dio = new Dio();
    dio.options.headers = {
      'user-agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
    };
    var response = await dio.get(v2exHost + "/t/" + topicId + "?p=1"); // todo 可能多页

    var tree = ETree.fromString(response.data);

    var aRootNode = tree.xpath("//*[@id='Wrapper']/div/div[3]/div[@id]");
    for (var aNode in aRootNode) {
      ReplyItem replyItem = new ReplyItem();
      replyItem.avatar = aNode.xpath("/table/tr/td[1]/img").first.attributes["src"];
      replyItem.userName = aNode.xpath('/table/tr/td[3]/strong/a/text()')[0].name;
      replyItem.lastReplyTime = aNode.xpath('/table/tr/td[3]/span/text()')[0].name;
      replyItem.content = aNode.xpath("/table/tr/td[3]/div[@class='reply_content']/text()")[0].name;
      replies.add(replyItem);
    }

    return replies;
  }
}
