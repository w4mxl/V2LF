import 'dart:convert';

class Node {
  int id;
  int topics;
  String avatar_large;
  String avatar_mini;
  String avatar_normal;
  String name;
  String title;
  String title_alternative;
  String url;

  Node.fromParams(
      {this.id,
      this.topics,
      this.avatar_large,
      this.avatar_mini,
      this.avatar_normal,
      this.name,
      this.title,
      this.title_alternative,
      this.url});

  Node.fromJson(jsonRes) {
    id = jsonRes['id'];
    topics = jsonRes['topics'];
    avatar_large = jsonRes['avatar_large'];
    avatar_mini = jsonRes['avatar_mini'];
    avatar_normal = jsonRes['avatar_normal'];
    name = jsonRes['name'];
    title = jsonRes['title'];
    title_alternative = jsonRes['title_alternative'];
    url = jsonRes['url'];
  }

  @override
  String toString() {
    return '{"id": $id,"topics": $topics,"avatar_large": ${avatar_large != null ? '${json.encode(avatar_large)}' : 'null'},"avatar_mini": ${avatar_mini != null ? '${json.encode(avatar_mini)}' : 'null'},"avatar_normal": ${avatar_normal != null ? '${json.encode(avatar_normal)}' : 'null'},"name": ${name != null ? '${json.encode(name)}' : 'null'},"title": ${title != null ? '${json.encode(title)}' : 'null'},"title_alternative": ${title_alternative != null ? '${json.encode(title_alternative)}' : 'null'},"url": ${url != null ? '${json.encode(url)}' : 'null'}}';
  }
}
