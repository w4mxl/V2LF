class Node {
  String avatarLarge;
  String name;
  String avatarNormal;
  String title;
  String url;
  String footer;
  String header;
  String titleAlternative;
  String avatarMini;
  String parentNodeName;
  bool root;
  int topics;
  int stars;
  int id;

  Node({this.avatarLarge, this.name, this.avatarNormal, this.title, this.url, this.footer, this.header, this.titleAlternative, this.avatarMini, this.parentNodeName, this.root, this.topics, this.stars, this.id});

  Node.fromJson(Map<String, dynamic> json) {    
    avatarLarge = json['avatar_large'];
    name = json['name'];
    avatarNormal = json['avatar_normal'];
    title = json['title'];
    url = json['url'];
    footer = json['footer'];
    header = json['header'];
    titleAlternative = json['title_alternative'];
    avatarMini = json['avatar_mini'];
    parentNodeName = json['parent_node_name'];
    root = json['root'];
    topics = json['topics'];
    stars = json['stars'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['avatar_large'] = avatarLarge;
    data['name'] = name;
    data['avatar_normal'] = avatarNormal;
    data['title'] = title;
    data['url'] = url;
    data['footer'] = footer;
    data['header'] = header;
    data['title_alternative'] = titleAlternative;
    data['avatar_mini'] = avatarMini;
    data['parent_node_name'] = parentNodeName;
    data['root'] = root;
    data['topics'] = topics;
    data['stars'] = stars;
    data['id'] = id;
    return data;
  }

}
