import 'dart:convert' show json;

import 'package:flutter_app/model/resp_member.dart';
import 'package:flutter_app/model/resp_node.dart';

class TopicsResp {
  List<Topic> list;

  factory TopicsResp(jsonStr) => jsonStr is String
      ? TopicsResp.fromJson(json.decode(jsonStr))
      : TopicsResp.fromJson(jsonStr);

  TopicsResp.fromJson(jsonRes) {
    list = [];

    for (var listItem in jsonRes) {
      list.add(new Topic.fromJson(listItem));
    }
  }

  @override
  String toString() {
    return '{"json_list": $list}';
  }
}

class Topic {
  int created;
  int id;
  int last_modified;
  int last_touched;
  int replies;
  String content;
  String content_rendered;
  String title;
  String url;
  Member member;
  Node node;

  Topic.fromParams(
      {this.created,
      this.id,
      this.last_modified,
      this.last_touched,
      this.replies,
      this.content,
      this.content_rendered,
      this.title,
      this.url,
      this.member,
      this.node});

  Topic.fromJson(jsonRes) {
    created = jsonRes['created'];
    id = jsonRes['id'];
    last_modified = jsonRes['last_modified'];
    last_touched = jsonRes['last_touched'];
    replies = jsonRes['replies'];
    content = jsonRes['content'];
    content_rendered = jsonRes['content_rendered'];
    title = jsonRes['title'];
    url = jsonRes['url'];
    member = new Member.fromJson(jsonRes['member']);
    node = new Node.fromJson(jsonRes['node']);
  }

  @override
  String toString() {
    return '{"created": $created,"id": $id,"last_modified": $last_modified,"last_touched": $last_touched,"replies": $replies,"content": ${content != null ? '${json.encode(content)}' : 'null'},"content_rendered": ${content_rendered != null ? '${json.encode(content_rendered)}' : 'null'},"title": ${title != null ? '${json.encode(title)}' : 'null'},"url": ${url != null ? '${json.encode(url)}' : 'null'},"member": $member,"node": $node}';
  }
}
