import 'dart:convert';

class Member {

  int id;
  String avatarLarge;
  String avatarMini;
  String avatarNormal;
  String tagline;
  String username;


  Member.fromParams({this.id, this.avatarLarge, this.avatarMini, this.avatarNormal, this.tagline, this.username});

  Member.fromJson(jsonRes) {
    id = jsonRes['id'];
    avatarLarge = jsonRes['avatar_large'];
    avatarMini = jsonRes['avatar_mini'];
    avatarNormal = jsonRes['avatar_normal'];
    tagline = jsonRes['tagline'];
    username = jsonRes['username'];

  }

  @override
  String toString() {
    return '{"id": $id,"avatar_large": ${avatarLarge != null?json.encode(avatarLarge):'null'},"avatar_mini": ${avatarMini != null?json.encode(avatarMini):'null'},"avatar_normal": ${avatarNormal != null?json.encode(avatarNormal):'null'},"tagline": ${tagline != null?json.encode(tagline):'null'},"username": ${username != null?json.encode(username):'null'}}';
  }
}