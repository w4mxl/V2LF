import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/model/web/item_node_topic.dart';
import 'package:flutter_app/model/web/item_tab_topic.dart';
import 'package:flutter_app/model/web/node.dart';

// 通过爬取网页数据作为返回

V2exApi v2exApi = new V2exApi();

class V2exApi {
  var httpClient = new HttpClient();

  static final V2exApi _v2exApi = new V2exApi._internal();

  factory V2exApi() {
    return _v2exApi;
  }

  V2exApi._internal();

  // 主页获取特定节点下的topics
  Future<List<TabTopicItem>> getTopicsByTabKey(String tabKey) async {
    String content = '';

    List<TabTopicItem> topics = new List<TabTopicItem>();

    final String reg4tag = "<div class=\"cell item\" (.*?)</table></div>";

    final String reg4MidAvatar = "<a href=\"/member/(.*?)\"><img src=\"(.*?)\" class=\"avatar\" ";

    final String reg4TRC = "<a href=\"/t/(.*?)#reply(.*?)\">(.*?)</a></span>";

    final String reg4NodeIdName = "<a class=\"node\" href=\"/go/(.*?)\">(.*?)</a>";

    final String reg4LastReply = "</strong> &nbsp;•&nbsp; (.*?) &nbsp;•&nbsp; 最后回复来自 <strong><a href=\"/member/(.*?)\">";

    var uri = new Uri.https('www.v2ex.com', '/', {'tab': tabKey});
    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();

    content = responseBody.replaceAll(new RegExp(r"[\r\n]|(?=\s+</?d)\s+"), '');

    RegExp exp = new RegExp(reg4tag);
    Iterable<Match> matches = exp.allMatches(content);
    for (Match match in matches) {
      String regString = match.group(0);
      TabTopicItem item = new TabTopicItem();
      Match match4MidAvatar = new RegExp(reg4MidAvatar).firstMatch(regString);
      item.memberId = match4MidAvatar.group(1);
      item.avatar = "https:${match4MidAvatar.group(2)}";
      Match match4TRC = new RegExp(reg4TRC).firstMatch(regString);
      item.topicId = match4TRC.group(1);
      item.replyCount = match4TRC.group(2);
      item.topicContent = match4TRC
          .group(3)
          .replaceAll('&quot;', '"')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>');
      Match match4NodeIdName = new RegExp(reg4NodeIdName).firstMatch(regString);
      item.nodeId = match4NodeIdName.group(1);
      item.nodeName = match4NodeIdName.group(2);
      if (regString.contains("最后回复来自")) {
        Match match4LastReply = new RegExp(reg4LastReply).firstMatch(regString);
        item.lastReplyTime = match4LastReply.group(1);
        item.lastReplyMId = match4LastReply.group(2);
      }
      /*item.content = (await NetworkApi.getTopicDetails(int.parse(item.topicId)))
          .list[0]
          .content;*/
      topics.add(item);
    }
    return topics;
  }

  // 获取 V2EX / 节点导航
  Future<List<NodeGroup>> getNodes() async {
    List<NodeGroup> nodeGroups = <NodeGroup>[];

    String content = '';

    final String reg4Node =
        "<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td align=\"right\" width=\"60\"><span class=\"fade\">(.*?)</td></tr></table>";

    final String reg4NodeGroup = "<span class=\"fade\">(.*?)</span></td>";
    final String reg4NodeItem = "<a href=\"/go/(.*?)\" style=\"font-size: 14px;\">(.*?)</a>";

    var uri = new Uri.https('www.v2ex.com', '/');
    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();

    content = responseBody.replaceAll(new RegExp(r"[\r\n]|(?=\s+</?d)\s+"), '');

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

  // 节点导航页 -> 获取特定节点下的topics [ 已经移到了 dioSingleton 中 ]
  Future<List<NodeTopicItem>> getNodeTopicsByTabKey(String tabKey, int p) async {
    String content = '';

    List<NodeTopicItem> topics = new List<NodeTopicItem>();

    // 这里">"花了几乎一个下午摸索出解析到数据，但是还是不完全明白原因
    final String reg4tag = "<div class=\"cell\"> (.*?)</table></div>";
//    final String reg4tag = "<div class=\"cell\" (.*?)</table></div>";

    final String reg4MidAvatar = "<a href=\"/member/(.*?)\"><img src=\"(.*?)\" class=\"avatar\" ";

    final String reg4TRC = "<a href=\"/t/(.*?)#reply(.*?)\">(.*?)</a></span>";

    final String reg4CharactersClickTimes = "</strong> &nbsp;•&nbsp; (.*?) &nbsp;•&nbsp; (.*?)</span>";

    final String reg4inner = "<div class=\"inner\"> (.*?)</table></div>";
    final String reg4pages = "<strong class=\"fade\">(.*?)</strong>";

    // 这里要 https 才能使下面的user-agent有效
    var uri = new Uri.https('www.v2ex.com', '/go/' + tabKey, {'p': p.toString()});
    var request = await httpClient.getUrl(uri); // Uri.parse("https://www.v2ex.com/go/share")
    //使用iPhone的UA
    request.headers.add("user-agent",
        "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1");
    //等待连接服务器（会将请求信息发送给服务器）
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    print(responseBody);

    content = responseBody.replaceAll(new RegExp(r"[\r\n]|(?=\s+</?d)\s+"), '');

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
}
