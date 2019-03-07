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
