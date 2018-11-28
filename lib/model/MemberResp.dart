import 'dart:convert';

class Member {

  int id;
  String avatar_large;
  String avatar_mini;
  String avatar_normal;
  String tagline;
  String username;


  Member.fromParams({this.id, this.avatar_large, this.avatar_mini, this.avatar_normal, this.tagline, this.username});

  Member.fromJson(jsonRes) {
    id = jsonRes['id'];
    avatar_large = jsonRes['avatar_large'];
    avatar_mini = jsonRes['avatar_mini'];
    avatar_normal = jsonRes['avatar_normal'];
    tagline = jsonRes['tagline'];
    username = jsonRes['username'];

  }

  @override
  String toString() {
    return '{"id": $id,"avatar_large": ${avatar_large != null?'${json.encode(avatar_large)}':'null'},"avatar_mini": ${avatar_mini != null?'${json.encode(avatar_mini)}':'null'},"avatar_normal": ${avatar_normal != null?'${json.encode(avatar_normal)}':'null'},"tagline": ${tagline != null?'${json.encode(tagline)}':'null'},"username": ${username != null?'${json.encode(username)}':'null'}}';
  }
}