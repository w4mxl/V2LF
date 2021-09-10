class TimeBase {
  int timestamp;

  TimeBase(this.timestamp);

  String getShowTime({int timestamp}) {
    int time;

    if (timestamp == null) {
      time = this.timestamp;
    } else {
      time = timestamp;
    }

    return getStandardDate(time);
  }

  static String getStandardDate(int timestamp) {
    String temp = "";
    try {
      int now = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
      int diff = now - timestamp;
      int months = (diff ~/ (60 * 60 * 24 * 30));
      int days = (diff ~/ (60 * 60 * 24));
      int hours = ((diff - days * (60 * 60 * 24)) ~/ (60 * 60));
      int minutes = ((diff - days * (60 * 60 * 24) - hours * (60 * 60)) ~/ 60);
      if (months > 0) {
        temp = months.toString() + "月前";
      } else if (days > 0) {
        temp = days.toString() + "天前";
      } else if (hours > 0) {
        temp = hours.toString() + "小时前";
      } else {
        temp = minutes.toString() + "分钟前";
      }
    } catch (e) {
      e.toString();
    }
    return temp;
  }
}
