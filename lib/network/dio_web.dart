import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_app/common/database_helper.dart';
import 'package:flutter_app/common/v2ex_client.dart';
import 'package:flutter_app/model/web/item_fav_node.dart';
import 'package:flutter_app/model/web/item_fav_topic.dart';
import 'package:flutter_app/model/web/item_node_topic.dart';
import 'package:flutter_app/model/web/item_notification.dart';
import 'package:flutter_app/model/web/item_profile_recent_reply.dart';
import 'package:flutter_app/model/web/item_profile_recent_topic.dart';
import 'package:flutter_app/model/web/item_tab_topic.dart';
import 'package:flutter_app/model/web/item_topic_reply.dart';
import 'package:flutter_app/model/web/item_topic_subtle.dart';
import 'package:flutter_app/model/web/login_form_data.dart';
import 'package:flutter_app/model/web/model_member_profile.dart';
import 'package:flutter_app/model/web/model_topic_detail.dart';
import 'package:flutter_app/model/web/node.dart';
import 'package:flutter_app/network/http.dart';
import 'package:flutter_app/utils/event_bus.dart';
import 'package:flutter_app/utils/sp_helper.dart';
import 'package:flutter_app/utils/strings.dart';
import 'package:flutter_app/utils/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/dom.dart' as dom; // Contains DOM related classes for extracting data from elements
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:xpath/xpath.dart';

///
///  经过对网址仔细测试发现：
///     对话题进行「收藏/取消收藏」、「感谢」操作过一次后，token 就会失效，再次进行操作（包括对下面的评论发送感谢）需要刷新获取新token
///     而，如果是先对下面的评论发送感谢，token 是不会失效的
///

class DioWeb {
  // App 启动时，检查登录状态，若登录的则帮领取签到奖励
  static Future verifyLoginStatus() async {
    if (SpHelper.sp.containsKey(SP_USERNAME)) {
      // 验证登录状态：尝试请求发帖，根据是否跳转到登录页判断
      var response = await dio.get("/new");
      if (response.isRedirect) {
        // 登录已经失效，注销数据
        print('登录已经失效，注销数据');
        // 需要再次两步验证了
        if (response.redirects[0].location.path == "/2fa") {
          Fluttertoast.showToast(msg: '两步验证到期了，请重新登录 😞', gravity: ToastGravity.CENTER, timeInSecForIos: 2);
        }
        await V2exClient.logout();
      } else {
        // 登录状态正常，尝试领取每日奖励
        bool _spAutoAward = SpHelper.sp.getBool(SP_AUTO_AWARD);
        if (_spAutoAward == null || _spAutoAward) {
          checkDailyAward().then((onValue) {
            if (!onValue) {
              dailyMission();
              print('准备去领取奖励...');
            }
          });
        }
      }
    }
  }

  // 检查每日登录奖励是否已领取
  static Future<bool> checkDailyAward() async {
    var response = await dio.get("/mission/daily");
    String resp = response.data as String;
    if (resp.contains('每日登录奖励已领取')) {
      print('wml：每日登录奖励已领取过了');
      return true;
    }
    print('wml：每日登录奖励还没有领取');
    return false;
  }

  // 领取每日奖励
  static Future dailyMission() async {
    try {
      var response = await dio.get("/signin");
      var tree = ETree.fromString(response.data);
      String once = tree
          .xpath("//*[@id='Wrapper']/div/div[1]/div[2]/form/table/tr[2]/td[2]/input[@name='once']")
          .first
          .attributes["value"];
      print('领取每日奖励:$once');

      var missionResponse = await dio.get("/mission/daily/redeem?once=" + once);
      print('领取每日奖励:' + "/mission/daily/redeem?once=" + once);
      if (missionResponse.data.contains('每日登录奖励已领取')) {
        print('每日奖励已自动领取');
        Fluttertoast.showToast(msg: '已帮您领取每日奖励 😉', timeInSecForIos: 2, gravity: ToastGravity.CENTER);
      } else {
        print(missionResponse.data);
      }
    } on DioError catch (e) {
      Fluttertoast.showToast(msg: '领取每日奖励失败：${e.message}', timeInSecForIos: 2, gravity: ToastGravity.CENTER);
    }
  }

  // 主页获取特定节点下的topics  [ 最近的主题 https://www.v2ex.com/recent?p=1 ]，p > 0 则通过 recent 获取数据
  static Future<List<TabTopicItem>> getTopicsByTabKey(String tabKey, int p) async {
    List<TabTopicItem> topics = new List<TabTopicItem>();

    var response;
    if (tabKey == 'all') {
      try {
        if (p == 0) {
          response = await dio.get('/?tab=' + tabKey);
        } else {
          response = await dio.get('/recent?p=' + p.toString());
        }
      } on DioError catch (e) {
        if (e != null) {
          switch (e.type) {
            case DioErrorType.CANCEL:
              break;
            case DioErrorType.CONNECT_TIMEOUT:
              Fluttertoast.showToast(msg: '连接超时...', gravity: ToastGravity.CENTER);
              break;
            case DioErrorType.SEND_TIMEOUT:
              Fluttertoast.showToast(msg: '发送数据超时...', gravity: ToastGravity.CENTER);
              break;
            case DioErrorType.RECEIVE_TIMEOUT:
              Fluttertoast.showToast(msg: '接收数据超时...', gravity: ToastGravity.CENTER);
              break;
            case DioErrorType.RESPONSE:
              Fluttertoast.showToast(msg: '响应超时...', gravity: ToastGravity.CENTER);
              break;
            case DioErrorType.DEFAULT:
              // Fluttertoast.showToast(msg: '未知错误...', gravity: ToastGravity.CENTER);
              break;
          }
        }
        return topics;
      }
    } else {
      response = await dio.get('/?tab=' + tabKey);
    }

    var tree = ETree.fromString(response.data);

    // 首页tab请求数据的时候 check 是否有未读提醒
    // 没有未读提醒  //*[@class='gray']
    // 有未读提醒    //*[@id="Wrapper"]/div/div[1]/div[1]/table/tr/td[1]/input
    var elements = tree.xpath("//*[@id='Wrapper']/div/div[1]/div[1]/table/tr/td[1]/input");
    if (elements != null) {
      String notificationInfo = elements.first.attributes["value"]; // value="1 条未读提醒"
      var unreadNumber = notificationInfo.split(' ')[0];
      print('未读数：' + unreadNumber);

      // 避免首页请求数据时一直弹出提醒
      var notificationCountSp = SpHelper.sp.getString(SP_NOTIFICATION_COUNT);
      if (notificationCountSp == null || notificationCountSp != unreadNumber) {
        eventBus.emit(MyEventHasNewNotification, unreadNumber);
      }

      SpHelper.sp.setString(SP_NOTIFICATION_COUNT, notificationInfo.split(' ')[0]);
    }

    var aRootNode = tree.xpath("//*[@class='cell item']");
    if (aRootNode != null) {
      for (var aNode in aRootNode) {
        TabTopicItem item = new TabTopicItem();
        // //*[@id="Wrapper"]/div/div[3]/div[3]/table/tbody/tr/td[3]/span[1]/strong/a
        item.memberId = aNode.xpath("/table/tr/td[3]/span[1]/strong/a/text()")[0].name;
        //*[@id="Wrapper"]/div/div[3]/div[3]/table/tbody/tr/td[1]/a/img
        item.avatar = aNode.xpath("/table/tr/td[1]/a[1]/img[@class='avatar']").first.attributes["src"];
        //*[@id="Wrapper"]/div/div[3]/div[3]/table/tbody/tr/td[3]/span[2]/a
        String topicUrl = aNode.xpath("/table/tr/td[3]/span[2]/a").first.attributes["href"]; // 得到是 /t/522540#reply17
        item.topicId = topicUrl.replaceAll("/t/", "").split("#")[0];
        //*[@id="Wrapper"]/div/div[3]/div[23]/table/tbody/tr/td[4]
        if (aNode.xpath("/table/tr/td[4]/a/text()") != null) {
          // 有评论数
          //*[@id="Wrapper"]/div/div/div[3]/table/tbody/tr/td[4]/a
          item.replyCount = aNode.xpath("/table/tr/td[4]/a/text()")[0].name;

          //*[@id="Wrapper"]/div/div[3]/div[22]/table/tbody/tr/td[3]/span[3]
          item.lastReplyTime = aNode.xpath("/table/tr/td[3]/span[3]/text()[1]")[0].name.split(' &nbsp;')[0];

          //*[@id="Wrapper"]/div/div[3]/div[22]/table/tbody/tr/td[3]/span[3]/strong/a
          if (aNode.xpath("/table/tr/td[3]/span[3]/strong/a/text()") != null) {
            // 遇到有评论数，但是没有最后回复id的情况，这里多加一个判断
            item.lastReplyMId = aNode.xpath("/table/tr/td[3]/span[3]/strong/a/text()")[0].name;
          }
        }
        //*[@id="Wrapper"]/div/div[3]/div[3]/table/tbody/tr/td[3]/span[2]/a
        item.topicContent = aNode
            .xpath("/table/tr/td[3]/span[2]/a/text()")[0]
            .name
            .replaceAll('&quot;', '"')
            .replaceAll('&amp;', '&')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>');

        //*[@id="Wrapper"]/div/div[3]/div[3]/table/tbody/tr/td[3]/span[1]/a
        item.nodeName = aNode.xpath("/table/tr/td[3]/span[1]/a/text()")[0].name;

        topics.add(item);
      }
      // 去数据库比对，判断是否为已读状态 todo
      return await DatabaseHelper.instance.addReadState(topics);
    }
    return topics;
  }

  // 节点导航
  static Future<List<NodeGroup>> getNodes() async {
    List<NodeGroup> nodeGroups = <NodeGroup>[];

    String content = '';

    final String reg4Node =
        "<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td align=\"right\" width=\"80\"><span class=\"fade\">(.*?)</td></tr></table>";

    final String reg4NodeGroup = "<span class=\"fade\">(.*?)</span></td>";
    final String reg4NodeItem = "<a href=\"/go/(.*?)\" style=\"font-size: 14px;\">(.*?)</a>";

    var response = await dio.get('/');
    content = response.data..replaceAll(new RegExp(r"[\r\n]|(?=\s+</?d)\s+"), '');

    RegExp exp = new RegExp(reg4Node);
    Iterable<Match> matches = exp.allMatches(content);

    for (Match match in matches) {
      NodeGroup nodeGroup = new NodeGroup();
      RegExp exp4GroupName = new RegExp(reg4NodeGroup);
      Match matchGroup = exp4GroupName.firstMatch(match.group(0));
      nodeGroup.nodeGroupName = matchGroup.group(1);

      RegExp exp4Node = new RegExp(reg4NodeItem);
      Iterable<Match> matchNodes = exp4Node.allMatches(match.group(0));
      for (Match matchNode in matchNodes) {
        NodeItem nodeItem = new NodeItem(matchNode.group(1), matchNode.group(2));
        /*nodeItem.nodeId = matchNode.group(1);
        nodeItem.nodeName = matchNode.group(2);*/
        nodeGroup.nodes.add(nodeItem);
      }
      nodeGroups.add(nodeGroup);
    }

    return nodeGroups;
  }

  // 节点导航页 -> 获取特定节点下的topics
  static Future<List<NodeTopicItem>> getNodeTopicsByTabKey(String tabKey, int p) async {
    String content = '';

    List<NodeTopicItem> topics = new List<NodeTopicItem>();

    // todo 这里">"花了几乎一个下午摸索出解析到数据，但是还是不完全明白原因
    final String reg4tag = "<div class=\"cell\">(.*?)</table></div>";
//    final String reg4tag = "<div class=\"cell\" (.*?)</table></div>";

    final String reg4MidAvatar = "<a href=\"/member/(.*?)\"><img src=\"(.*?)\" class=\"avatar\" ";

    final String reg4TRC = "<a href=\"/t/(.*?)#reply(.*?)\" class=\"topic-link\">(.*?)</a></span>";

    final String reg4CharactersClickTimes = "</strong> &nbsp;•&nbsp; (.*?) &nbsp;•&nbsp; (.*?)</span>";

    final String reg4inner = "<div class=\"inner\">(.*?)</table></div>";
    final String reg4pages = "<strong class=\"fade\">(.*?)</strong>";

    var response = await dio.get('/go/' + tabKey + "?p=" + p.toString());
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
      eventBus.emit(MyEventNodeIsFav, isFavWithOnce);
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
  static Future<bool> replyTopic(String topicId, String content) async {
    try {
      String once = await getOnce();
      if (once == null || once.isEmpty) {
        Fluttertoast.showToast(msg: '操作失败,无法获取到 once 😞', timeInSecForIos: 2, gravity: ToastGravity.CENTER);
        return false;
      }

      dio.options.contentType = ContentType.parse("application/x-www-form-urlencoded");

      FormData formData = new FormData.from({
        "once": once,
        "content": content,
      });

      var responseReply = await dio.post("/t/" + topicId, data: formData);
      dio.options.contentType = ContentType.json; // 还原
      var document = parse(responseReply.data);
      if (document.querySelector('#Wrapper > div > div > div.problem') != null) {
        // 回复失败
        String problem = document.querySelector('#Wrapper > div > div > div.problem').text;

        Fluttertoast.showToast(msg: '$problem', timeInSecForIos: 2, gravity: ToastGravity.CENTER);
        return false;
      }

      // 回复成功
      return true;
    } on DioError catch (e) {
      Fluttertoast.showToast(msg: '回复失败', timeInSecForIos: 2, gravity: ToastGravity.CENTER);
      //cookieJar.deleteAll();
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request);
      return false;
    }
  }

  // 创建主题：先用节点ID去获取 once，然后组装字段 POST 发帖
  static Future<String> createTopic(String nodeId, String title, String content) async {
    try {
      var response = await dio.get('/new/' + nodeId);
      String resp = response.data as String;
      if (resp.contains('你的帐号刚刚注册')) {
        return '你的帐号刚刚注册，暂时无法发帖。';
      }

      var tree = ETree.fromString(resp);
      String once = tree
          .xpath("//*[@id='Wrapper']/div/div[1]/div[2]/form/table/tr[3]/td/input[@name='once']")
          .first
          .attributes["value"];
      if (once == null || once.isEmpty) {
        return '操作失败,无法获取到 once!';
      }

      print('wml：' + once);

      dio.options.contentType = ContentType.parse("application/x-www-form-urlencoded");
      FormData formData = new FormData.from({
        "once": once,
        "title": title,
        "content": content,
        "syntax": "1", // 文本标记语法，0: 默认 1: Markdown
      });
      var responsePostTopic = await dio.post("/new/" + nodeId, data: formData);
      dio.options.contentType = ContentType.json; // 还原
      var document = parse(responsePostTopic.data);
      if (document.querySelector('#Wrapper > div > div > div.problem > ul') != null) {
        // 发布话题失败: 可能有多条错误，这里只取第一条提示用户
        String problem = document.querySelector('#Wrapper > div > div > div.problem > ul > li').text;
        return problem;
      }
      // 发布话题成功
      return '主题发布成功';
    } on DioError catch (e) {
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request);
      return '主题发布失败';
    }
  }

  // 获取 once
  static Future<String> getOnce() async {
    var response = await dio.get("/signin");
    var tree = ETree.fromString(response.data); //*[@id="Wrapper"]/div/div/div[2]/form/table/tbody/tr[3]/td/input[1]
    String once = tree
        .xpath("//*[@id='Wrapper']/div/div[1]/div[2]/form/table/tr[2]/td[2]/input[@name='once']")
        .first
        .attributes["value"];
    print(once);
    return once;
  }

  // 获取登录信息
  static Future<LoginFormData> parseLoginForm() async {
    // name password captcha once
    LoginFormData loginFormData = new LoginFormData();
    //dio.options.contentType = ContentType.json;
    //dio.options.responseType = ResponseType.JSON;
    var response = await dio.get("/signin");
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

    dio.options.responseType = ResponseType.bytes;
    response = await dio.get("/_captcha?once=" + loginFormData.once);
    dio.options.responseType = ResponseType.json; // 还原
    if ((response.data as List<int>).length == 0) throw new Exception('NetworkImage is an empty file');
    loginFormData.bytes = Uint8List.fromList(response.data);
    return loginFormData;
  }

  // 登录 POST -> 获取用户信息，Future<String> "true" "false" "2fa"
  static Future<String> loginPost(LoginFormData loginFormData) async {
    // 此处 Origin 和 Referer 是必要的
    dio.options.headers = {
      "Origin": 'https://www.v2ex.com',
      "Referer": "https://www.v2ex.com/signin",
      'user-agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
    };
    dio.options.contentType = ContentType.parse("application/x-www-form-urlencoded");
    //dio.options.responseType = ResponseType.JSON;

    FormData formData = new FormData.from({
      "once": loginFormData.once,
      "next": "/",
      loginFormData.username: loginFormData.usernameInput,
      loginFormData.password: loginFormData.passwordInput,
      loginFormData.captcha: loginFormData.captchaInput
    });

    try {
      var response = await dio.post("/signin", data: formData);
      dio.options.contentType = ContentType.json; // 还原
      if (response.statusCode == 302) {
        // 还原
        dio.options.headers = {
          'user-agent': Platform.isIOS
              ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
              : 'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.75 Mobile Safari/537.36'
        };
        // 这里实际已经登录成功了，去获取用户信息
        return await getUserInfo();
      } else {
        // 登录失败，去获取错误提示信息
        var tree = ETree.fromString(response.data);
        // //*[@id="Wrapper"]/div/div[1]/div[3]/ul/li "输入的验证码不正确"
        // //*[@id="Wrapper"]/div/div[1]/div[2]/ul/li "用户名和密码无法匹配" 等
        var errorInfo;
        if (tree.xpath('//*[@id="Wrapper"]/div/div[1]/div[3]/ul/li/text()') != null) {
          errorInfo = tree.xpath('//*[@id="Wrapper"]/div/div[1]/div[3]/ul/li/text()')[0].name;
        } else {
          errorInfo = tree.xpath('//*[@id="Wrapper"]/div/div[1]/div[2]/ul/li/text()')[0].name;
        }
        print("wml error!!!!：$errorInfo");
        Fluttertoast.showToast(msg: errorInfo, timeInSecForIos: 2, gravity: ToastGravity.CENTER);
        return "false";
      }
    } on DioError catch (e) {
      Fluttertoast.showToast(msg: '登录失败', timeInSecForIos: 2, gravity: ToastGravity.CENTER);
      //cookieJar.deleteAll();
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request);
      return "false";
    }
  }

  // 两步验证
  static Future<bool> twoFALogin(String code) async {
    String once = SpHelper.sp.getString(SP_ONCE);
    print("twoFALogin：" + once);
    if (once == null || once.isEmpty) {
      return false;
    }
    dio.options.contentType = ContentType.parse("application/x-www-form-urlencoded");
    FormData formData = new FormData.from({
      "once": once,
      "code": code,
    });
    print("wml: once = " + once + ",code = " + code);
    var response = await dio.post("/2fa", data: formData);
    dio.options.contentType = ContentType.json; // 还原
    if (response.statusCode == 302) {
      return true;
    }
    return false;
  }

  // 获取当前用户信息
  static Future<String> getUserInfo() async {
    var response = await dio.get(Strings.v2exHost);
    if (response.redirects.length > 0) {
      print("wml:" + response.redirects[0].location.path);
      // 需要两步验证
      if (response.redirects[0].location.path == "/2fa") {
        response = await dio.get('/2fa');
      }
    }
    var tree = ETree.fromString(response.data);
    var elementOfAvatarImg = tree.xpath("//*[@id='Top']/div/div/table/tr/td[3]/a[1]/img[1]")?.first;
    if (elementOfAvatarImg != null) {
      // 获取用户头像
      String avatar = Utils.avatarLarge(elementOfAvatarImg.attributes["src"]);
      String href = elementOfAvatarImg.parent.attributes["href"]; // "/member/w4mxl"
      var username = href.substring('/member/'.length);
      // 保存 username avatar
      SpHelper.sp.setString(SP_AVATAR, avatar);
      SpHelper.sp.setString(SP_USERNAME, username);
      // todo 判断用户是否开启了两步验证

      // 需要两步验证
      if (response.request.path == "/2fa") {
        var tree = ETree.fromString(response.data);
        // //*[@id="Wrapper"]/div/div[1]/div[2]/form/table/tbody/tr[3]/td[2]/input[1]
        String once = tree
            .xpath("//*[@id='Wrapper']/div/div[1]/div[2]/form/table/tr[3]/td[2]/input[@name='once']")
            .first
            .attributes["value"];
        print('两步验证前保存once:$once');
        SpHelper.sp.setString(SP_ONCE, once);
        return "2fa";
      }
      return "true";
    }
    return "false";
  }

  // 获取「主题收藏」下的topics [xpath 解析的]
  static Future<List<FavTopicItem>> getFavTopics(int p) async {
    List<FavTopicItem> topics = new List<FavTopicItem>();
    var response = await dio.get("/my/topics" + "?p=" + p.toString());
    var tree = ETree.fromString(response.data);

    //*[@id="Wrapper"]/div/div/div[1]/div/strong
//    if (tree.xpath("//*[@class='gray']") != null) {
//      var count = tree.xpath("//*[@class='gray']").first.xpath("/text()")[0].name;
//      eventBus.emit(MyEventFavCounts,count);
//    }
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
  static Future<List<FavNode>> getFavNodes() async {
    List<FavNode> nodes = new List<FavNode>();
    var response = await dio.get("/my/nodes");
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

  // 获取「通知」下的列表信息
  static Future<List<NotificationItem>> getNotifications(int p) async {
    List<NotificationItem> notifications = new List<NotificationItem>();
    // 调用 dio 之前检查登录时保存的cookie是否带上了
    var response = await dio.get("/notifications" + "?p=" + p.toString());
    var document = parse(response.data);

    var page = document.querySelector('strong.fade') != null ? document.querySelector('strong.fade').text : null;

    List<dom.Element> aRootNode = document.querySelectorAll('div.cell[id]'); // 2019.10.4 发现v2ex网站页面有改动，需要过滤
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
//        if (!date.contains('天')) {
//          date = date.split(' ')[0];
//        }
        item.date = date;

        item.userName = aNode.querySelector('table > tbody > tr > td:nth-child(3) > span.fade > a > strong').text;

        // document.querySelector('#n_9690800 > table > tbody > tr > td:nth-child(2) > span.fade')
        // 明明是 td:nth-child(2) ，可是取出来是 null，而 td:nth-child(3) 才对
        // <span class="fade"><a href="/member/jokyme"><strong>jokyme</strong></a> 在回复 <a href="/t/556167#reply64">千呼万唤使出来， V2EX 非官方小程序发布啦！</a> 时提到了你</span>
        // #n_10262034 > table > tbody > tr > td:nth-child(2) > span.fade > a:nth-child(1) > strong
        item.title =
            aNode.querySelector('table > tbody > tr > td:nth-child(3) > span.fade').innerHtml.split('</strong></a>')[1];

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

    return notifications;
  }

  // 获取用户主页数据
  static Future<MemberProfileModel> getMemberProfile(String userName) async {
    print('在请求$userName 个人页面数据');

    String currentUserName = SpHelper.sp.getString(SP_USERNAME);

    MemberProfileModel profileModel = MemberProfileModel();
    List<Clip> clips = List(); // 网站、位置、社交媒体id 等

    List<ProfileRecentTopicItem> topicList = List(); // 近期主题
    List<ProfileRecentReplyItem> replyList = List(); // 近期回复

    var response = await dio.get('/member/' + userName);
    var document = parse(response.data);

    // 登录状态且不是本人，才获取关注和屏蔽状态
    if (SpHelper.sp.containsKey(SP_USERNAME) && userName != SpHelper.sp.getString(SP_USERNAME)) {
      // onclick="if (confirm('确认要开始关注 wuqingdzx？')) { location.href = '/follow/278271?once=68661'; }"
      String followStr = document
          .querySelector('#Wrapper > div > div:nth-child(1) > div > table > tbody > tr > td:nth-child(5)  > div.fr > input')
          .attributes["value"];
      print("!!!!::::" + followStr);
      // 取消特别关注 加入特别关注
      profileModel.isFollow = (followStr == '取消特别关注');

      String blockStr = document
          .querySelector(
              '#Wrapper > div > div:nth-child(1) > div > table > tbody > tr > td:nth-child(5)  > div.fr >  input.super.normal.button')
          .attributes["value"];

      // Unblock Block
      profileModel.isBlock = (blockStr == 'Unblock');
      // onclick="if (confirm('确认要屏蔽 wuqingdzx？')) { location.href = '/block/278271?t=1399527187'; }"
      // todo 是不是这里的 token 都是 1399527187 ？
      profileModel.token = document
          .querySelector(
              '#Wrapper > div > div:nth-child(1) > div > table > tbody > tr > td:nth-child(5)  > div.fr >  input.super.normal.button')
          .attributes["onclick"]
          .split('?t=')[1]
          .split('\'')[0];
      print("!!!!::::" + blockStr + ",,,," + profileModel.token);
    }

    // 头像
    /*profileModel.avatar = currentUserName == userName
        ? SpHelper.sp.getString(SP_AVATAR) // 存储的照片比个人页获取的要高清一些
        : document
            .querySelector('#Wrapper > div > div:nth-child(1) > div > table > tbody > tr > td:nth-child(1) > img')
            .attributes["src"];*/

    // 是否在线
    if (document.querySelector('strong.online') != null) {
      profileModel.online = true;
    }

    // 用户名
    /*profileModel.userName =
        document.querySelector('#Wrapper > div > div:nth-child(1) > div > table > tbody > tr > td:nth-child(5) > h1').text;*/
    // 用户加入信息
    profileModel.memberInfo = document
        .querySelector('#Wrapper > div > div:nth-child(1) > div > table > tbody > tr > td:nth-child(5) > span.gray')
        .text
        .replaceFirst('V2EX ', '');

    // 签名
    if (document.querySelector(
            '#Wrapper > div > div:nth-child(1) > div:nth-child(1) > table > tbody > tr > td:nth-child(5) > span.bigger') !=
        null) {
      profileModel.sign = document
          .querySelector(
              '#Wrapper > div > div:nth-child(1) > div:nth-child(1) > table > tbody > tr > td:nth-child(5) > span.bigger')
          .text;
    }

    if (document.querySelector(
            '#Wrapper > div > div:nth-child(1) > div:nth-child(1) > table > tbody > tr > td:nth-child(5) > span:nth-child(8) > li') !=
        null) {
      profileModel.company = document
          .querySelector(
              '#Wrapper > div > div:nth-child(1) > div:nth-child(1) > table > tbody > tr > td:nth-child(5) > span:nth-child(8)')
          .innerHtml;
    }

    List<dom.Element> nodes = document.querySelectorAll("#Wrapper > div > div:nth-child(1) > div.widgets > a");
    if (nodes != null && nodes.length > 0) {
      for (var node in nodes) {
        Clip clip = Clip();
        clip.icon = node.querySelector('img').attributes['src'];
        clip.name = node.text.trim();
        clip.url = node.attributes['href'];
        print('wml::${clip.name}');
        clips.add(clip);
      }
      profileModel.clips = clips;

      // 个人简介
      if (document.querySelector("#Wrapper > div > div:nth-child(1) > div[class='cell']") != null) {
        profileModel.memberIntro =
            document.querySelector("#Wrapper > div > div:nth-child(1) > div[class='cell']:nth-child(5)").text;
      }
    } else {
      // 个人简介
      if (document.querySelector("#Wrapper > div > div:nth-child(1) > div[class='cell']") != null) {
        profileModel.memberIntro =
            document.querySelector("#Wrapper > div > div:nth-child(1) > div[class='cell']:nth-child(3)").text;
      }
    }

    // 解析"最近主题" : 可能是多个 / 0 / 用户设置为隐藏
    String select = currentUserName == userName
        ? "#Wrapper > div > div:nth-child(9) > div[class='cell item']"
        : "#Wrapper > div > div:nth-child(5) > div[class='cell item']";
    if (document.querySelector(select) != null) {
      List<dom.Element> rootNode = document.querySelectorAll(select);
      for (var value in rootNode) {
        ProfileRecentTopicItem recentTopicItem = ProfileRecentTopicItem();
        recentTopicItem.topicId = value
            .querySelector('table > tbody > tr > td:nth-child(1) > span.item_title > a')
            .attributes["href"]
            .replaceAll("/t/", "")
            .split("#")[0]; // 得到是 /t/522540#reply17
        recentTopicItem.replyCount = value
            .querySelector('table > tbody > tr > td:nth-child(1) > span.item_title > a')
            .attributes["href"]
            .replaceAll("/t/", "")
            .split("#")[1]
            .replaceFirst('reply', '');

        recentTopicItem.topicTitle = value.querySelector('table > tbody > tr > td:nth-child(1) > span.item_title > a').text;
        print("wml::${recentTopicItem.topicTitle}");

        // #Wrapper > div > div:nth-child(3) > div:nth-child(2) > table > tbody > tr > td:nth-child(1) > span:nth-child(1) > a
        recentTopicItem.nodeId = value
            .querySelector('table > tbody > tr > td:nth-child(1) > span > a')
            .attributes["href"]
            .replaceAll('/go/', '');
        recentTopicItem.nodeName = document.querySelector('table > tbody > tr > td:nth-child(1) > span > a').text;

        if (recentTopicItem.replyCount != '0') {
          recentTopicItem.lastReplyTime =
              ' • ' + value.querySelector("table > tbody > tr > td:nth-child(1) > span:nth-child(8)").text;
        }
        topicList.add(recentTopicItem);
      }
      print("wml::${rootNode.length}");
    } else if (document.querySelector("#Wrapper > div > div:nth-child(5) > div.inner") != null) {
      // 用户设置为隐藏
      topicList = null;
    }
    profileModel.topicList = topicList;

    // 解析"最近回复" : 可能是多个 / 0
    String selectReply = currentUserName == userName
        ? '#Wrapper > div > div:nth-child(13) > div.dock_area'
        : '#Wrapper > div > div:nth-child(9) > div.dock_area';
    if (document.querySelector(selectReply) != null) {
      var dockAreaList = document.querySelectorAll('div.dock_area');
      var replyContentList = document.querySelectorAll('div.reply_content');
      for (int i = 0; i < dockAreaList.length; i++) {
        ProfileRecentReplyItem recentReplyItem = ProfileRecentReplyItem();
        recentReplyItem.replyTime = dockAreaList[i]
            .querySelector('table > tbody > tr > td > div > span.fade')
            .text
            .replaceFirst(' +08:00', ''); // 时间 去除+ 08:00;*/;
        recentReplyItem.dockAreaText = dockAreaList[i].querySelector('table > tbody > tr > td > span').innerHtml;
        recentReplyItem.replyContent = replyContentList[i].innerHtml;
        replyList.add(recentReplyItem);
      }
      print("wmllll::${dockAreaList.length}");
    }
    profileModel.replyList = replyList;

    return profileModel;
  }

  // 关注 / 取消关注 用户
  // if (confirm('确认要开始关注 wuqingdzx？')) { location.href = '/follow/278271?once=68661'; }
  // if (confirm('确认要取消对 wuqingdzx 的关注？')) { location.href = '/unfollow/278271?once=39422'; }
  static Future<bool> follow(bool isFollow, String userId) async {
    String once = await getOnce();
    if (once == null || once.isEmpty) {
      print('wml::follow:: once error');
      return false;
    }
    String url = isFollow ? ("/unfollow/" + userId + "?once=" + once) : ("/follow/" + userId + "?once=" + once);
    print('wml::follow:: $url');
    var response = await dio.get(url);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // 屏蔽 / 取消屏蔽 用户
  // if (confirm('确认要屏蔽 wmllll？')) { location.href = '/block/391045?t=1399527187'; }
  // if (confirm('确认要解除对 wmllll 的屏蔽？')) { location.href = '/unblock/391045?t=1399527187'; }
  static Future<bool> block(bool isBlock, String userId, String token) async {
    String url = isBlock ? ("/unblock/" + userId + "?t=" + token) : ("/block/" + userId + "?t=" + token);
    print('wml::block:: $url');
    var response = await dio.get(url);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // 获取用户的所有主题列表信息 https://www.v2ex.com/member/w4mxl/topics?p=1
  static Future<List<ProfileRecentTopicItem>> getAllTopics(String userName, int p) async {
    List<ProfileRecentTopicItem> topics = List<ProfileRecentTopicItem>();
    var response = await dio.get("/member/" + userName + "/topics?p=" + p.toString());
    var document = parse(response.data);

    var page = document.querySelector('strong.fade') != null ? document.querySelector('strong.fade').text : null;

    List<dom.Element> aRootNode = document.querySelectorAll("div[class='cell item']");
    if (aRootNode != null) {
      for (var aNode in aRootNode) {
        ProfileRecentTopicItem item = new ProfileRecentTopicItem();

        if (page != null) {
          item.maxPage = int.parse(page.split('/')[1]);
        }

        item.topicId = aNode
            .querySelector('table > tbody > tr > td:nth-child(1) > span.item_title > a')
            .attributes["href"]
            .replaceAll("/t/", "")
            .split("#")[0]; // 得到是 /t/522540#reply17
        item.replyCount = aNode
            .querySelector('table > tbody > tr > td:nth-child(1) > span.item_title > a')
            .attributes["href"]
            .replaceAll("/t/", "")
            .split("#")[1]
            .replaceFirst('reply', '');

        item.topicTitle = aNode.querySelector('table > tbody > tr > td:nth-child(1) > span.item_title > a').text;

        item.nodeId = aNode
            .querySelector('table > tbody > tr > td:nth-child(1) > span > a')
            .attributes["href"]
            .replaceAll('/go/', '');
        item.nodeName = document.querySelector('table > tbody > tr > td:nth-child(1) > span > a').text;

        if (item.replyCount != '0') {
          item.lastReplyTime = ' • ' + aNode.querySelector("table > tbody > tr > td:nth-child(1) > span:nth-child(8)").text;
        }
        topics.add(item);
      }
    }

    return topics;
  }

  // 获取用户的所有回复列表信息 https://www.v2ex.com/member/w4mxl/replies
  static Future<List<ProfileRecentReplyItem>> getAllReplies(String userName, int p) async {
    List<ProfileRecentReplyItem> replies = List<ProfileRecentReplyItem>();
    var response = await dio.get("/member/" + userName + "/replies?p=" + p.toString());
    var document = parse(response.data);

    var page = document.querySelector('strong.fade') != null ? document.querySelector('strong.fade').text : null;

    var dockAreaList = document.querySelectorAll('div.dock_area');
    var replyContentList = document.querySelectorAll('div.reply_content');

    for (int i = 0; i < dockAreaList.length; i++) {
      ProfileRecentReplyItem item = new ProfileRecentReplyItem();

      if (page != null) {
        item.maxPage = int.parse(page.split('/')[1]);
      }

      item.replyTime = dockAreaList[i]
          .querySelector('table > tbody > tr > td > div > span.fade')
          .text
          .replaceFirst(' +08:00', ''); // 时间 去除+ 08:00;*/;
      item.dockAreaText = dockAreaList[i].querySelector('table > tbody > tr > td > span').innerHtml;
      item.replyContent = replyContentList[i].innerHtml;
      replies.add(item);
    }
    return replies;
  }

  // 获取帖子详情及下面的评论信息 [html 解析的] todo 关注 html 库 nth-child
  static Future<TopicDetailModel> getTopicDetailAndReplies(String topicId, int p) async {
    print('在请求第$p页面数据');
    TopicDetailModel detailModel = TopicDetailModel();
    List<TopicSubtleItem> subtleList = List(); // 附言
    List<ReplyItem> replies = List();

    var response = await dio.get("/t/" + topicId + "?p=" + p.toString());
    // Use html parser and query selector
    var document = parse(response.data);

    detailModel.topicId = topicId;

    if (response.isRedirect || document.querySelector('#Main > div.box > div.message') != null) {
      Fluttertoast.showToast(msg: '查看本主题需要先登录 😞', gravity: ToastGravity.CENTER, timeInSecForIos: 2);
      return detailModel;
    }

    detailModel.avatar =
        document.querySelector('#Wrapper > div > div:nth-child(1) > div.header > div.fr > a > img').attributes["src"];
    detailModel.createdId = document.querySelector('#Wrapper > div > div:nth-child(1) > div.header > small > a').text;
    detailModel.nodeId = document
        .querySelector('#Wrapper > div > div:nth-child(1) > div.header > a:nth-child(6)')
        .attributes["href"]
        .replaceAll('/go/', '');
    detailModel.nodeName = document.querySelector('#Wrapper > div > div:nth-child(1) > div.header > a:nth-child(6)').text;
    //  at 9 小时 26 分钟前，1608 次点击
    detailModel.smallGray = document
        .querySelector('#Wrapper > div > div:nth-child(1) > div.header > small')
        .text
        .split('at')[1]
        .replaceFirst(' +08:00', ''); // 时间 去除+ 08:00;

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
        subtleItem.fade = node.querySelector('span.fade').text.replaceFirst(' +08:00', ''); // 时间（去除+ 08:00）;
        subtleItem.content = node.querySelector('div.topic_content').innerHtml;
        subtleList.add(subtleItem);
      }
    }
    detailModel.subtleList = subtleList;

    // token 是否收藏
    // <a href="/unfavorite/topic/541492?t=lqstjafahqohhptitvcrplmjbllwqsxc" class="op">取消收藏</a>
    // #Wrapper > div > div:nth-child(1) > div.inner > div > a:nth-child(2)
    if (document.querySelector("#Wrapper > div > div:nth-child(1) > div.inner > div > a[class='op']") != null) {
      String collect =
          document.querySelector("#Wrapper > div > div:nth-child(1) > div.inner > div > a[class='op']").attributes["href"];
      detailModel.token = collect.split('?t=')[1];
      detailModel.isFavorite = collect.startsWith('/unfavorite');
    }

    // <a href="#;" onclick="if (confirm('确定不想再看到这个主题？')) { location.href = '/ignore/topic/583319?once=62479'; }"
    //    class="op" style="user-select: auto;">忽略主题</a>
    // #Wrapper > div > div:nth-child(1) > div.inner > div > a:nth-child(5)

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

    return detailModel;
  }

  // 感谢主题
  static Future<bool> thankTopic(String topicId) async {
    String once = await getOnce();
    print("thankTopic：" + once);
    if (once == null || once.isEmpty) {
      return false;
    }
    var response = await dio.post("/thank/topic/" + topicId + "?once=" + once);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // 收藏/取消收藏 主题 todo 发现操作过其中一次后，再次请求虽然也返回200，但是并没有实际成功！！
  static Future<bool> favoriteTopic(bool isFavorite, String topicId, String token) async {
    String url =
        isFavorite ? ("/unfavorite/topic/" + topicId + "?t=" + token) : ("/favorite/topic/" + topicId + "?t=" + token);
    var response = await dio.get(url);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // 忽略主题
  // <a href="#;" onclick="if (confirm('确定不想再看到这个主题？'))
  // { location.href = '/ignore/topic/556280?once=35630'; }" class="tb" style="user-select: auto;">忽略主题</a>
  static Future<bool> ignoreTopic(String topicId) async {
    String once = await getOnce();
    print("ignoreTopic：" + once);
    if (once == null || once.isEmpty) {
      return false;
    }
    var response = await dio.get("/ignore/topic/" + topicId + "?once=" + once);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // 报告主题
  // https://www.v2ex.com/report/topic/36307?t=1399527187
  static Future<bool> reportTopic(String topicId) async {
    String url = "/report/topic/" + topicId + "?t=1399527187"; // todo 目前看 t 是固定值
    var response = await dio.get(url);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // 感谢某条评论 https://www.v2ex.com/thank/reply/7626703?once=62479
  static Future<bool> thankTopicReply(String replyID) async {
    String once = await getOnce();
    print("thankTopicReply：" + once);
    if (once == null || once.isEmpty) {
      return false;
    }
    var response = await dio.post("/thank/reply/" + replyID + "?once=" + once);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // 收藏/取消收藏 节点 https://www.v2ex.com/favorite/node/39?once=87770
  // 测试发现 [ 这里操作收藏节点和取消收藏用同一个 token 却是可以的 ]
  static Future<bool> favoriteNode(bool isFavorite, String nodeIdWithOnce) async {
    String url = isFavorite ? ("/unfavorite/node/" + nodeIdWithOnce) : ("/favorite/node/" + nodeIdWithOnce);
    var response = await dio.get(url);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
