import 'package:event_bus/event_bus.dart';

EventBus eventBus = new EventBus();

/// Event SETTING.
class MyEventSettingChange {
  MyEventSettingChange();
}

/// Event FAV_COUNTS.
class MyEventFavCounts {
  String count;

  MyEventFavCounts(this.count);
}

/// Event Tabs. 设置中自定义了主页 tabs
class MyEventTabsChange {
  MyEventTabsChange();
}

/// Event 帖子详情页刷新
class MyEventRefreshTopic {
  MyEventRefreshTopic();
}

/// Event NODE_IS_FAV. 节点是否被收藏
class MyEventNodeIsFav {
  bool isFavourite;

  MyEventNodeIsFav(this.isFavourite);
}
