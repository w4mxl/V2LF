class LanguageModel {
  String languageCode;
  String scriptCode;
  bool isSelected;

  LanguageModel(this.languageCode, this.scriptCode, {this.isSelected: false});

  LanguageModel.fromJson(Map<String, dynamic> json)
      : languageCode = json['languageCode'],
        scriptCode = json['scriptCode'],
        isSelected = json['isSelected'];

  Map<String, dynamic> toJson() => {
        'languageCode': languageCode,
        'scriptCode': scriptCode,
        'isSelected': isSelected,
      };

  @override
  String toString() {
    StringBuffer sb = new StringBuffer('{');
    sb.write("\"languageCode\":\"$languageCode\"");
    sb.write(",\"scriptCode\":\"$scriptCode\"");
    sb.write('}');
    return sb.toString();
  }
}
