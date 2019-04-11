import 'dart:async';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/model/web/item_fav_node.dart';
import 'package:flutter_app/model/web/item_fav_topic.dart';
import 'package:flutter_app/model/web/item_node_topic.dart';
import 'package:flutter_app/model/web/item_notification.dart';
import 'package:flutter_app/model/web/item_topic_reply.dart';
import 'package:flutter_app/model/web/item_topic_subtle.dart';
import 'package:flutter_app/model/web/login_form_data.dart';
import 'package:flutter_app/model/web/model_topic_detail.dart';
import 'package:flutter_app/utils/events.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:flutter_app/utils/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/dom.dart' as dom; // Contains DOM related classes for extracting data from elements
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:xpath/xpath.dart';

DioSingleton dioSingleton = new DioSingleton();

class DioSingleton {
  static final v2exHost = "https://www.v2ex.com";

  Dio _dio;

  static final DioSingleton _dioSingleton = DioSingleton._internal();

  factory DioSingleton() => _dioSingleton;

  DioSingleton._internal() {
    setDio();
  }

  void setDio() async {
    if (_dio == null) {
      Options options = new Options();
      options.baseUrl = v2exHost;
      options.receiveTimeout = 5 * 1000;
      options.connectTimeout = 5 * 1000;
      options.headers = {
        'user-agent': Platform.isIOS
            ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
            : 'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.75 Mobile Safari/537.36'
      };
      options.validateStatus = (int status) {
        return status >= 200 && status < 300 || status == 304 || status == 302;
      };
      _dio = new Dio(options);
      String cookiePath = await Utils.getCookiePath();
      PersistCookieJar cookieJar = new PersistCookieJar(dir: cookiePath);
      _dio.cookieJar = cookieJar;
    }
  }

  // 检查每日登录奖励是否已领取
  Future<bool> checkDailyAward() async {
    var response = await _dio.get(v2exHost + "/mission/daily");
    // Use html parser and query selector
    if ((response.data as String).contains('每日登录奖励已领取')) {
      return true;
    }
    return false;
  }

  // 领取每日奖励
  Future dailyMission() async {
    try {
      var response = await _dio.get("/signin");
      var tree = ETree.fromString(response.data);
      String once = tree
          .xpath("//*[@id='Wrapper']/div/div[1]/div[2]/form/table/tr[2]/td[2]/input[@name='once']")
          .first
          .attributes["value"];
      print('领取每日奖励:$once');

      var missionResponse = await _dio.get(v2exHost + "/mission/daily/redeem?once=" + once);
      print('领取每日奖励:' + v2exHost + "/mission/daily/redeem?once=" + once);
      // Use html parser and query selector
      print('领取每日奖励:${missionResponse.statusCode}');
      if (missionResponse.statusCode == 200) {
        print('每日奖励已自动领取');
        Fluttertoast.showToast(msg: '每日奖励已自动领取', timeInSecForIos: 2, gravity: ToastGravity.TOP);
      }
    } on DioError catch (e) {
      Fluttertoast.showToast(msg: '领取每日奖励失败', timeInSecForIos: 2);
    }
  }

  // 节点导航页 -> 获取特定节点下的topics
  Future<List<NodeTopicItem>> getNodeTopicsByTabKey(String tabKey, int p) async {
    String content = '';

    List<NodeTopicItem> topics = new List<NodeTopicItem>();

    // todo 这里">"花了几乎一个下午摸索出解析到数据，但是还是不完全明白原因
    final String reg4tag = "<div class=\"cell\"> (.*?)</table></div>";
//    final String reg4tag = "<div class=\"cell\" (.*?)</table></div>";

    final String reg4MidAvatar = "<a href=\"/member/(.*?)\"><img src=\"(.*?)\" class=\"avatar\" ";

    final String reg4TRC = "<a href=\"/t/(.*?)#reply(.*?)\">(.*?)</a></span>";

    final String reg4CharactersClickTimes = "</strong> &nbsp;•&nbsp; (.*?) &nbsp;•&nbsp; (.*?)</span>";

    final String reg4inner = "<div class=\"inner\"> (.*?)</table></div>";
    final String reg4pages = "<strong class=\"fade\">(.*?)</strong>";

    var response = await _dio.get(v2exHost + '/go/' + tabKey + "?p=" + p.toString());
    var document = parse(response.data);
    if (document.querySelector('#Main > div.box > div.cell > form') != null) {
      Fluttertoast.showToast(msg: '查看本节点需要先登录 😞', gravity: ToastGravity.CENTER, timeInSecForIos: 2);
      return topics;
    }

    // <a href="/favorite/node/17?once=68177">加入收藏</a>
    // <a href="/unfavorite/node/39?once=68177">取消收藏</a>
    // #Wrapper > div > div:nth-child(1) > div.header > div.fr.f12 > a
    var element = document.querySelector('#Wrapper > div > div:nth-child(1) > div.header > div.fr.f12 > a');
    if (element != null) {
      String isFavWithOnce = element.attributes["href"];
      eventBus.fire(new MyEventNodeIsFav(isFavWithOnce));
    }

    content = response.data.replaceAll(new RegExp(r"[\r\n]|(?=\s+</?d)\s+"), '');

    RegExp expInner = new RegExp(reg4inner);
    Iterable<Match> matchesInner = expInner.allMatches(content);
    Match match = matchesInner.first;
    print("当前页/总页数： " + new RegExp(reg4pages).firstMatch(match.group(0)).group(1));

    RegExp exp = new RegExp(reg4tag);
    Iterable<Match> matches = exp.allMatches(content);
    for (Match match in matches) {
      String regString = match.group(0);
      NodeTopicItem item = new NodeTopicItem();
      Match match4MidAvatar = new RegExp(reg4MidAvatar).firstMatch(regString);
      item.memberId = match4MidAvatar.group(1);
      item.avatar = "https:${match4MidAvatar.group(2)}";
      Match match4TRC = new RegExp(reg4TRC).firstMatch(regString);
      item.topicId = match4TRC.group(1);
      item.replyCount = match4TRC.group(2);
      item.title = match4TRC.group(3);
      if (regString.contains("个字符")) {
        Match match4CharactersClickTimes = new RegExp(reg4CharactersClickTimes).firstMatch(regString);
        item.characters = match4CharactersClickTimes.group(1);
        item.clickTimes = match4CharactersClickTimes.group(2);
      }
      /*item.content = (await NetworkApi.getTopicDetails(int.parse(item.topicId)))
          .list[0]
          .content;*/
      topics.add(item);
    }
    return topics;
  }

  // 回复帖子
  Future<bool> replyTopic(String topicId, String content) async {
    try {
      var response = await _dio.get("/signin");
      var tree = ETree.fromString(response.data);
      String once = tree
          .xpath("//*[@id='Wrapper']/div/div[1]/div[2]/form/table/tr[2]/td[2]/input[@name='once']")
          .first
          .attributes["value"];
      print(once);

      if (once == null || once.isEmpty) {
        return false;
      }

      _dio.options.contentType = ContentType.parse("application/x-www-form-urlencoded");

      FormData formData = new FormData.from({
        "once": once,
        "content": content,
      });

      var responseReply = await _dio.post("/t/" + topicId, data: formData);
      _dio.options.contentType = ContentType.json; // 还原
      var document = parse(responseReply.data);
      if (document.querySelector('#Wrapper > div > div > div.problem') != null) {
        // 回复失败
        String problem = document.querySelector('#Wrapper > div > div > div.problem').text;

        Fluttertoast.showToast(msg: '$problem', timeInSecForIos: 2);
        return false;
      }

      // 回复成功
      return true;
    } on DioError catch (e) {
      Fluttertoast.showToast(msg: '回复失败', timeInSecForIos: 2);
      //cookieJar.deleteAll();
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request);
      return false;
    }
  }

  // 获取登录信息
  Future<LoginFormData> parseLoginForm() async {
    // name password captcha once
    LoginFormData loginFormData = new LoginFormData();
    //_dio.options.contentType = ContentType.json;
    //_dio.options.responseType = ResponseType.JSON;
    _dio.options.headers = {
      'user-agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
    };
    var response = await _dio.get("/signin");
    var tree = ETree.fromString(response.data);
    loginFormData.username = tree
        .xpath("//*[@id='Wrapper']/div/div[1]/div[2]/form/table/tr[1]/td[2]/input[@class='sl']")
        .first
        .attributes["name"];
    loginFormData.password = tree
        .xpath("//*[@id='Wrapper']/div/div[1]/div[2]/form/table/tr[2]/td[2]/input[@class='sl']")
        .first
        .attributes["name"];
    loginFormData.captcha = tree
        .xpath("//*[@id='Wrapper']/div/div[1]/div[2]/form/table/tr[4]/td[2]/input[@class='sl']")
        .first
        .attributes["name"];
    loginFormData.once = tree
        .xpath("//*[@id='Wrapper']/div/div[1]/div[2]/form/table/tr[2]/td[2]/input[@name='once']")
        .first
        .attributes["value"];

    print(" \n" +
        loginFormData.username +
        "\n" +
        loginFormData.password +
        "\n" +
        loginFormData.captcha +
        "\n" +
        loginFormData.once);

    _dio.options.responseType = ResponseType.STREAM;
    response = await _dio.get("/_captcha?once=" + loginFormData.once);
    _dio.options.responseType = ResponseType.JSON; // 还原
    var uint8list = await consolidateHttpClientResponseBytes(response.data);
    if (uint8list.lengthInBytes == 0) throw new Exception('NetworkImage is an empty file');
    loginFormData.bytes = uint8list;

    return loginFormData;
  }

  // 登录 POST -> 获取用户信息
  Future<bool> loginPost(LoginFormData loginFormData) async {
    _dio.options.headers = {
      "Origin": v2exHost,
      "Referer": v2exHost + "/signin",
      'user-agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
    };
    _dio.options.contentType = ContentType.parse("application/x-www-form-urlencoded");
    //_dio.options.responseType = ResponseType.JSON;

    FormData formData = new FormData.from({
      "once": loginFormData.once,
      "next": "/",
      loginFormData.username: loginFormData.usernameInput,
      loginFormData.password: loginFormData.passwordInput,
      loginFormData.captcha: loginFormData.captchaInput
    });

    try {
      var response = await _dio.post("/signin", data: formData);
      _dio.options.contentType = ContentType.json; // 还原
      if (response.statusCode == 302) {
        // 这里实际已经登录成功了
        _dio.options.headers = {
          'user-agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
        };
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
        Fluttertoast.showToast(msg: errorInfo, timeInSecForIos: 2, gravity: ToastGravity.TOP);
        return false;
      }
    } on DioError catch (e) {
      // todo
      Fluttertoast.showToast(msg: '登录失败');
      //cookieJar.deleteAll();
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request);
      return false;
    }
  }

  // 获取「主题收藏」下的topics [xpath 解析的]
  Future<List<FavTopicItem>> getFavTopics(int p) async {
    List<FavTopicItem> topics = new List<FavTopicItem>();
    // 调用 _dio 之前检查登录时保存的cookie是否带上了
    var response = await _dio.get(v2exHost + "/my/topics" + "?p=" + p.toString()); // todo 可能多页
    var tree = ETree.fromString(response.data);

    //*[@id="Wrapper"]/div/div/div[1]/div/strong
    if (tree.xpath("//*[@class='gray']") != null) {
      var count = tree.xpath("//*[@class='gray']").first.xpath("/text()")[0].name;
      eventBus.fire(new MyEventFavCounts(count));
    }
    var page = tree.xpath("//*[@class='page_normal']") != null
        ? tree.xpath("//*[@class='page_normal']").last.xpath("/text()")[0].name
        : '1';

    // Fluttertoast.showToast(msg: '收藏总数：$count，页数：$page');

    var aRootNode = tree.xpath("//*[@class='cell item']");
    if (aRootNode != null) {
      for (var aNode in aRootNode) {
        FavTopicItem favTopicItem = new FavTopicItem();

        favTopicItem.maxPage = int.parse(page);

        favTopicItem.topicTitle = aNode
            .xpath("/table/tr/td[3]/span[1]/a/text()")[0]
            .name
            .replaceAll('&quot;', '"')
            .replaceAll('&amp;', '&')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>'); //*[@id="Wrapper"]/div/div/div[3]/table/tbody/tr/td[3]/span[1]/a

        String topicUrl = aNode.xpath("/table/tr/td[3]/span[1]/a").first.attributes["href"]; // 得到是 /t/522540#reply17
        favTopicItem.topicId = topicUrl.replaceAll("/t/", "").split("#")[0];

        favTopicItem.nodeName = aNode.xpath("/table/tr/td[3]/span[2]/a[1]/text()")[0].name;
        favTopicItem.avatar = aNode.xpath("/table/tr/td[1]/a[1]/img[@class='avatar']").first.attributes["src"];
        favTopicItem.memberId = aNode.xpath("/table/tr/td[3]/span[2]/strong[1]/a/text()")[0].name;

        if (aNode.xpath("/table/tr/td[4]/a/text()") != null) {
          // 有评论数
          //*[@id="Wrapper"]/div/div/div[3]/table/tbody/tr/td[4]/a
          favTopicItem.replyCount = aNode.xpath("/table/tr/td[4]/a/text()")[0].name;

          //*[@id="Wrapper"]/div/div/div[3]/table/tbody/tr/td[3]/span[2]/text()[2]
          favTopicItem.lastReplyTime = aNode.xpath("/table/tr/td[3]/span[2]/text()[2]")[0].name.replaceAll('&nbsp;', "");

          //*[@id="Wrapper"]/div/div/div[3]/table/tbody/tr/td[3]/span[2]/strong[2]/a
          favTopicItem.lastReplyMId = aNode.xpath("/table/tr/td[3]/span[2]/strong[2]/a/text()")[0].name;
        }

        topics.add(favTopicItem);
      }
    } else {
      // todo 可能未登录或者没有
      // Fluttertoast.showToast(msg: '获取收藏失败');
    }

    return topics;
  }

  // 获取「节点收藏」 [xpath 解析的]
  Future<List<FavNode>> getFavNodes() async {
    List<FavNode> nodes = new List<FavNode>();
    var response = await _dio.get(v2exHost + "/my/nodes");
    var tree = ETree.fromString(response.data);

    var aRootNode = tree.xpath("//*[@class='grid_item']");
    if (aRootNode != null) {
      for (var aNode in aRootNode) {
        FavNode favNode = new FavNode();
        // //*[@id="n_195868"]/div/img
        // 这里需要注意，如果解析出来的是 '/static/img/node_large.png' 则拼上前缀 'https://www.v2ex.com'；其它则拼上 https:
        String imgUrl = aNode.xpath("/div/img").first.attributes["src"];
        if (imgUrl == '/static/img/node_large.png') {
          favNode.img = "https://www.v2ex.com" + imgUrl;
        } else {
          favNode.img = "https:" + imgUrl;
        }
        favNode.nodeId = aNode.attributes['href'].toString().replaceAll('/go/', '');
        favNode.nodeName = aNode.xpath("/div/text()")[0].name;
        //*[@id="n_195868"]/div/span
        favNode.replyCount = aNode.xpath("/div/span/text()")[0].name;
        // print(favNode.img + "  " + favNode.nodeId + "  " + favNode.nodeName + "  " + favNode.replyCount);
        nodes.add(favNode);
      }
    } else {
      // todo 可能未登录或者没有
      // Fluttertoast.showToast(msg: '获取收藏失败');
    }

    return nodes;
  }

  // 获取「通知」下的列表信息 [html 解析的]
  Future<List<NotificationItem>> getNotifications(int p) async {
    List<NotificationItem> notifications = new List<NotificationItem>();
    // 调用 _dio 之前检查登录时保存的cookie是否带上了
    var response = await _dio.get(v2exHost + "/notifications" + "?p=" + p.toString()); // todo 可能多页
    var tree = ETree.fromString(response.data);

    //*[@id="Wrapper"]/div/div/div[12]/table/tbody/tr/td[2]/strong
    var page = tree.xpath("//*[@id='Wrapper']/div/div/div[12]/table/tr/td[2]/strong/text()") != null
        ? tree.xpath("//*[@id='Wrapper']/div/div/div[12]/table/tr/td[2]/strong/text()")[0].name
        : null;
    // Fluttertoast.showToast(msg: '页数：$page');

    // Use html parser and query selector
    var document = parse(response.data);
    List<dom.Element> aRootNode = document.querySelectorAll('div.cell');
    if (aRootNode != null) {
      for (var aNode in aRootNode) {
        NotificationItem item = new NotificationItem();

        if (page != null) {
          item.maxPage = int.parse(page.split('/')[1]);
        }

        //#n_9690800 > table > tbody > tr > td:nth-child(1) > a > img
        item.avatar = aNode.querySelector('table > tbody > tr > td:nth-child(1) > a > img').attributes["src"];
        // #n_9690800 > table > tbody > tr > td:nth-child(2) > span.snow
        // 可能得到 '44 天前' 或者 '2017-06-14 16:33:13 +08:00  '
        String date = aNode.querySelector('table > tbody > tr > td:nth-child(3) > span.snow').text;
        if (!date.contains('天')) {
          date = date.split(' ')[0];
        }
        item.date = date;

        // document.querySelector('#n_9690800 > table > tbody > tr > td:nth-child(2) > span.fade')
        // 明明是 td:nth-child(2) ，可是取出来是 null，而 td:nth-child(3) 才对
        item.title = aNode.querySelector('table > tbody > tr > td:nth-child(3) > span.fade').innerHtml;

        // document.querySelector('#n_9472572 > table > tbody > tr > td:nth-child(2) > div.payload')
        if (aNode.querySelector('table > tbody > tr > td:nth-child(3) > div.payload') != null) {
          item.reply = aNode.querySelector('table > tbody > tr > td:nth-child(3) > div.payload').innerHtml;
        }
        // document.querySelector('#n_6036816 > table > tbody > tr > td:nth-child(2) > span.fade > a:nth-child(2)')

        String topicUrl = aNode
            .querySelector('table > tbody > tr > td:nth-child(3) > span.fade > a:nth-child(2)')
            .attributes["href"]; // 得到是 /t/522540#reply17
        item.topicId = topicUrl.replaceAll("/t/", "").split("#")[0];
        print(item.topicId);

        notifications.add(item);
      }
    }
//    这种方式有点问题，就是，解析 title reply 等时解析不全。是xpath: ^0.1.0 # https://pub.flutter-io.cn/packages/xpath 还不完善
//    var aRootNode = tree.xpath("//*[@class='cell']");
//    if (aRootNode != null) {
//      for (var aNode in aRootNode) {
//        NotificationItem item = new NotificationItem();
//
//        item.maxPage = int.parse(page.split('/')[1]);
//
//        //*[@id="n_9690800"]/table/tbody/tr/td[1]/a/img
//        item.avatar = aNode
//            .xpath("/table/tr/td[1]/a/img[@class='avatar']")
//            .first
//            .attributes["src"];
//        item.date = aNode.xpath("/table/tr/td[2]/span[2]/text()")[0].name.replaceAll('&nbsp;', "");
//
//        //*[@id="n_9690800"]/table/tbody/tr/td[2]/span[1]
//        item.title = aNode
//            .xpath("/table/tr/td[2]/span[1]/text()")[0]
//            .name;
//
//        if(aNode.xpath("/table/tr/td[2]/div[@class='payload']")!=null){
//          item.reply = aNode.xpath("/table/tr/td[2]/div[@class='payload']").first.xpath("/text()")[0].name;
//        }
//
//        String topicUrl = aNode.xpath("/table/tr/td[2]/span[1]/a[2]").first.attributes["href"]; // 得到是 /t/522540#reply17
//        item.topicId = topicUrl.replaceAll("/t/", "").split("#")[0];
//
//        notifications.add(item);
//      }
//    } else {
//      // todo 可能未登录
//      Fluttertoast.showToast(msg: '登录过程中遇到一些问题：获取收藏失败');
//    }

    return notifications;
  }

  // 获取帖子详情及下面的评论信息 [html 解析的] todo 关注 html 库 nth-child
  Future<TopicDetailModel> getTopicDetailAndReplies(String topicId, int p) async {
    print('在请求第$p页面数据');
    TopicDetailModel detailModel = TopicDetailModel();
    List<TopicSubtleItem> subtleList = List(); // 附言
    List<ReplyItem> replies = List();

    var response = await _dio.get(v2exHost + "/t/" + topicId + "?p=" + p.toString()); // todo 可能多页
    // Use html parser and query selector
    var document = parse(response.data);

    if (document.querySelector('#Main > div.box > div.message') != null) {
      Fluttertoast.showToast(msg: '查看本主题需要先登录 😞', gravity: ToastGravity.CENTER, timeInSecForIos: 2);
      return detailModel;
    }

    detailModel.avatar =
        document.querySelector('#Wrapper > div > div:nth-child(1) > div.header > div.fr > a > img').attributes["src"];
    detailModel.createdId = document.querySelector('#Wrapper > div > div:nth-child(1) > div.header > small > a').text;
    detailModel.nodeId = document.querySelector('#Wrapper > div > div:nth-child(1) > div.header > a:nth-child(6)').attributes["href"].replaceAll('/go/', '');
    detailModel.nodeName = document.querySelector('#Wrapper > div > div:nth-child(1) > div.header > a:nth-child(6)').text;
    //  at 9 小时 26 分钟前，1608 次点击
    detailModel.smallGray =
        document.querySelector('#Wrapper > div > div:nth-child(1) > div.header > small').text.split('at')[1];

    detailModel.topicTitle = document.querySelector('#Wrapper > div > div:nth-child(1) > div.header > h1').text;

    // 判断是否有正文
    if (document.querySelector('#Wrapper > div > div:nth-child(1) > div.cell > div') != null) {
      detailModel.content = document.querySelector('#Wrapper > div > div:nth-child(1) > div.cell > div').text;
      detailModel.contentRendered = document.querySelector('#Wrapper > div > div:nth-child(1) > div.cell > div').innerHtml;
    }
    // 附言
    List<dom.Element> appendNodes = document.querySelectorAll("#Wrapper > div > div:nth-child(1) > div[class='subtle']");
    if (appendNodes != null && appendNodes.length > 0) {
      for (var node in appendNodes) {
        TopicSubtleItem subtleItem = TopicSubtleItem();
        subtleItem.fade = node.querySelector('span.fade').text;
        subtleItem.content = node.querySelector('div.topic_content').innerHtml;
        subtleList.add(subtleItem);
      }
    }
    detailModel.subtleList = subtleList;

    // token 是否收藏
    // <a href="/unfavorite/topic/541492?t=lqstjafahqohhptitvcrplmjbllwqsxc" class="op">取消收藏</a>
    if (document.querySelector("#Wrapper > div > div:nth-child(1) > div.inner > div > a[class='op']") != null) {
      String collect =
          document.querySelector("#Wrapper > div > div:nth-child(1) > div.inner > div > a[class='op']").attributes["href"];
      detailModel.token = collect.split('?t=')[1];
      detailModel.isFavorite = collect.startsWith('/unfavorite');
    }
    // 是否感谢 document.querySelector('#topic_thank > span')
    detailModel.isThank = document.querySelector('#topic_thank > span') != null;
    print(detailModel.isFavorite == true ? 'yes' : 'no');
    print(detailModel.isThank == true ? 'yes' : 'no');

    // 判断是否有评论
    if (document.querySelector('#Wrapper > div > div.box.transparent') == null) {
      // 表示有评论
      detailModel.replyCount =
          document.querySelector('#Wrapper > div > div:nth-child(5) > div:nth-child(1)').text.trim().split('回复')[0];

      if (p == 1) {
        // 只有第一页这样的解析才对
        if (document.querySelector('#Wrapper > div > div:nth-child(5) > div:last-child > a:last-child') != null) {
          detailModel.maxPage =
              int.parse(document.querySelector('#Wrapper > div > div:nth-child(5) > div:last-child > a:last-child').text);
        }
      }
      List<dom.Element> rootNode = document.querySelectorAll("#Wrapper > div > div[class='box'] > div[id]");
      if (rootNode != null) {
        for (var aNode in rootNode) {
          ReplyItem replyItem = new ReplyItem();
          replyItem.avatar = aNode.querySelector('table > tbody > tr > td:nth-child(1) > img').attributes["src"];
          replyItem.userName = aNode.querySelector('table > tbody > tr > td:nth-child(5) > strong > a').text;
          replyItem.lastReplyTime = aNode
              .querySelector('table > tbody > tr > td:nth-child(5) > span')
              .text
              .replaceFirst(' +08:00', ''); // 时间（去除+ 08:00）和平台（Android/iPhone）
          if (aNode.querySelector("table > tbody > tr > td:nth-child(5) > span[class='small fade']") != null) {
            replyItem.favorites =
                aNode.querySelector("table > tbody > tr > td:nth-child(5) > span[class='small fade']").text.split(" ")[1];
          }
          replyItem.number = aNode.querySelector('table > tbody > tr > td:nth-child(5) > div.fr > span').text;
          replyItem.contentRendered =
              aNode.querySelector('table > tbody > tr > td:nth-child(5) > div.reply_content').innerHtml;
          replyItem.content = aNode.querySelector('table > tbody > tr > td:nth-child(5) > div.reply_content').text;
          replyItem.replyId = aNode.attributes["id"].substring(2);
          //print(replyItem.replyId);
          replies.add(replyItem);
        }
      }
    }
    detailModel.replyList = replies;

//    var tree = ETree.fromString(response.data);
//
//    var aRootNode = tree.xpath("//*[@id='Wrapper']/div/div[3]/div[@id]");
//    for (var aNode in aRootNode) {
//      ReplyItem replyItem = new ReplyItem();
//      replyItem.avatar = aNode.xpath("/table/tr/td[1]/img").first.attributes["src"];
//      replyItem.userName = aNode.xpath('/table/tr/td[3]/strong/a/text()')[0].name;
//      replyItem.lastReplyTime = aNode.xpath('/table/tr/td[3]/span/text()')[0].name;
//      //replyItem.content = aNode.xpath("/table/tr/td[3]/div[@class='reply_content']/text()")[0].name;
//      replies.add(replyItem);
//    }

    return detailModel;
  }

  // 感谢主题
  Future<bool> thankTopic(String topicId, String token) async {
    var response = await _dio.post("/thank/topic/" + topicId + "?t=" + token);
    if (response.statusCode == 200 && response.data.toString().isEmpty) {
      return true;
    }
    return false;
  }

  // 收藏/取消收藏 主题 todo 发现操作过其中一次后，再次请求虽然也返回200，但是并没有实际成功！！
  Future<bool> favoriteTopic(bool isFavorite, String topicId, String token) async {
    String url =
        isFavorite ? ("/unfavorite/topic/" + topicId + "?t=" + token) : ("/favorite/topic/" + topicId + "?t=" + token);
    var response = await _dio.get(url);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // 收藏/取消收藏 节点 https://www.v2ex.com/favorite/node/39?once=87770
  Future<bool> favoriteNode(bool isFavorite, String nodeIdWithOnce) async {
    String url = isFavorite ? ("/unfavorite/node/" + nodeIdWithOnce) : ("/favorite/node/" + nodeIdWithOnce);
    var response = await _dio.get(url);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // 感谢某条评论
  Future<bool> thankTopicReply(String replyID, String token) async {
    var response = await _dio.post("/thank/reply/" + replyID + "?t=" + token);
    if (response.statusCode == 200 && response.data.toString().isEmpty) {
      return true;
    }
    return false;
  }
}
