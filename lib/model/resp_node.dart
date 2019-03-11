import 'dart:convert';

class Node {
  int id;
  int topics;
  String avatarLarge;
  String avatarMini;
  String avatarNormal;
  String name;
  String title;
  String titleAlternative;
  String url;

  Node.fromParams(
      {this.id,
      this.topics,
      this.avatarLarge,
      this.avatarMini,
      this.avatarNormal,
      this.name,
      this.title,
      this.titleAlternative,
      this.url});

  Node.fromJson(jsonRes) {
    id = jsonRes['id'];
    topics = jsonRes['topics'];
    avatarLarge = jsonRes['avatar_large'];
    avatarMini = jsonRes['avatar_mini'];
    avatarNormal = jsonRes['avatar_normal'];
    name = jsonRes['name'];
    title = jsonRes['title'];
    titleAlternative = jsonRes['title_alternative'];
    url = jsonRes['url'];
  }

  @override
  String toString() {
    return '{"id": $id,"topics": $topics,"avatar_large": ${avatarLarge != null ? '${json.encode(avatarLarge)}' : 'null'},"avatar_mini": ${avatarMini != null ? '${json.encode(avatarMini)}' : 'null'},"avatar_normal": ${avatarNormal != null ? '${json.encode(avatarNormal)}' : 'null'},"name": ${name != null ? '${json.encode(name)}' : 'null'},"title": ${title != null ? '${json.encode(title)}' : 'null'},"title_alternative": ${titleAlternative != null ? '${json.encode(titleAlternative)}' : 'null'},"url": ${url != null ? '${json.encode(url)}' : 'null'}}';
  }
}
