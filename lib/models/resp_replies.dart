import 'dart:convert' show json;

import 'package:flutter_app/models/resp_member.dart';

class RepliesResp {
  List<Reply> list;

  factory RepliesResp(jsonStr) =>
      jsonStr is String ? RepliesResp.fromJson(json.decode(jsonStr)) : RepliesResp.fromJson(jsonStr);

  RepliesResp.fromJson(jsonRes) {
    list = [];

    for (var listItem in jsonRes) {
      list.add(Reply.fromJson(listItem));
    }
  }

  @override
  String toString() {
    return '{"json_list": $list}';
  }
}

class Reply {
  int created;
  int id;
  int lastModified;
  int lastTouched;
  int replies;
  String content;
  String contentRendered;
  String lastReplyBy;
  String title;
  String url;
  Member member;

  Reply.fromParams(
      {this.created,
      this.id,
      this.lastModified,
      this.lastTouched,
      this.replies,
      this.content,
      this.contentRendered,
      this.lastReplyBy,
      this.title,
      this.url,
      this.member});

  Reply.fromJson(jsonRes) {
    created = jsonRes['created'];
    id = jsonRes['id'];
    lastModified = jsonRes['last_modified'];
    lastTouched = jsonRes['last_touched'];
    replies = jsonRes['replies'];
    content = jsonRes['content'];
    contentRendered = jsonRes['content_rendered'];
    lastReplyBy = jsonRes['last_reply_by'];
    title = jsonRes['title'];
    url = jsonRes['url'];
    member = Member.fromJson(jsonRes['member']);
  }

  @override
  String toString() {
    return '{"created": $created,"id": $id,"last_modified": $lastModified,"last_touched": $lastTouched,"replies": $replies,"content": ${content != null ? json.encode(content) : 'null'},"content_rendered": ${contentRendered != null ? json.encode(contentRendered) : 'null'},"last_reply_by": ${lastReplyBy != null ? json.encode(lastReplyBy) : 'null'},"title": ${title != null ? json.encode(title) : 'null'},"url": ${url != null ? json.encode(url) : 'null'},"member": $member}';
  }
}
