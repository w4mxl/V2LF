/// @author: wml
/// @date  : 2019/3/13 18:21
/// @email : mxl1989@gmail.com
/// @desc  : 排序 Tab Model

class TabModel {
  String title;
  String key;
  bool checked;

  TabModel(this.title, this.key, {this.checked: true});

  TabModel.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        key = json['key'],
        checked = json['checked'];

  Map<String, dynamic> toJson() => {
    'title': title,
    'key': key,
    'checked': checked,
  };

  @override
  String toString() {
    StringBuffer sb = new StringBuffer('{');
    sb.write("\"title\":\"$title\"");
    sb.write(",\"key\":\"$key\"");
    sb.write(",\"checked\":\"$checked\"");
    sb.write('}');
    return sb.toString();
  }
}
