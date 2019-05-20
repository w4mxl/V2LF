/// @author: wml
/// @date  : 2019-05-20 16:59
/// @email : mxl1989@gmail.com
/// @desc  : Landscape images from Google Now Header

import 'dart:math';

class GoogleNowImg {
  static const INDEX_DAWN = 0;
  static const INDEX_DAY = 1;
  static const INDEX_DUSK = 2;
  static const INDEX_NIGHT = 3;

  static var defaultImg = const [
    'https://i.loli.net/2019/05/20/5ce270544521d42070.png',
    'https://i.loli.net/2019/05/20/5ce27054472c845738.png',
    'https://i.loli.net/2019/05/20/5ce270544bcae83237.png',
    'https://i.loli.net/2019/05/20/5ce2705449c7a74567.png',
  ];

  static var austin = const [
    'https://i.loli.net/2019/05/20/5ce26c2c7519570778.png',
    'https://i.loli.net/2019/05/20/5ce26c2c892dd29077.png',
    'https://i.loli.net/2019/05/20/5ce26c2c93d8660742.png',
    'https://i.loli.net/2019/05/20/5ce26c2ca515482308.png',
  ];

  static var beach = const [
    'https://i.loli.net/2019/05/20/5ce26c2c9bfb668439.png',
    'https://i.loli.net/2019/05/20/5ce26c2cc264a57391.png',
    'https://i.loli.net/2019/05/20/5ce26c2cbdfaf30572.png',
    'https://i.loli.net/2019/05/20/5ce26c2cccc9322439.png',
  ];

  static var berlin = const [
    'https://i.loli.net/2019/05/20/5ce26fc47bf9321766.png',
    'https://i.loli.net/2019/05/20/5ce26fc489c3532856.png',
    'https://i.loli.net/2019/05/20/5ce26fc4997d166013.png',
    'https://i.loli.net/2019/05/20/5ce26fc4a1f3b42593.png',
  ];

  static var chicago = const [
    'https://i.loli.net/2019/05/20/5ce26fc4daa2b49652.png',
    'https://i.loli.net/2019/05/20/5ce26fc4e2d8684748.png',
    'https://i.loli.net/2019/05/20/5ce26fc4eafbc40917.png',
    'https://i.loli.net/2019/05/20/5ce26fc4ed65545841.png',
  ];

  static var greatPlains = const [
    'https://i.loli.net/2019/05/20/5ce270544dace86284.png',
    'https://i.loli.net/2019/05/20/5ce27054534e839698.png',
    'https://i.loli.net/2019/05/20/5ce2705458f5291614.png',
    'https://i.loli.net/2019/05/20/5ce2705460ffe17302.png',
  ];

  static var london = const [
    'https://i.loli.net/2019/05/20/5ce2710b3f13b38955.png',
    'https://i.loli.net/2019/05/20/5ce2710b5da0656133.png',
    'https://i.loli.net/2019/05/20/5ce2710b97ad139006.png',
    'https://i.loli.net/2019/05/20/5ce2710ba00e532816.png',
  ];

  static var newYork = const [
    'https://i.loli.net/2019/05/20/5ce2710ba4a6596319.png',
    'https://i.loli.net/2019/05/20/5ce2710ba8d5d69212.png',
    'https://i.loli.net/2019/05/20/5ce2710bad48438625.png',
    'https://i.loli.net/2019/05/20/5ce2710bb173d26842.png',
  ];

  static var paris = const [
    'https://i.loli.net/2019/05/20/5ce271771daf778847.png',
    'https://i.loli.net/2019/05/20/5ce2717749b3a86020.png',
    'https://i.loli.net/2019/05/20/5ce2717740f3f24400.png',
    'https://i.loli.net/2019/05/20/5ce271775849d28241.png',
  ];

  static var sanFrancisco = const [
    'https://i.loli.net/2019/05/20/5ce27177522a396631.png',
    'https://i.loli.net/2019/05/20/5ce2717764f7816290.png',
    'https://i.loli.net/2019/05/20/5ce271776d52b65815.png',
    'https://i.loli.net/2019/05/20/5ce271777598b70698.png',
  ];

  static var seattle = const [
    'https://i.loli.net/2019/05/20/5ce271dff41b534132.png',
    'https://i.loli.net/2019/05/20/5ce271e046f5b57786.png',
    'https://i.loli.net/2019/05/20/5ce271e04a5d129554.png',
    'https://i.loli.net/2019/05/20/5ce271e042c9f30263.png',
  ];

  static var tahoe = const [
    'https://i.loli.net/2019/05/20/5ce271e08d17e66505.png',
    'https://i.loli.net/2019/05/20/5ce271e06af6442515.png',
    'https://i.loli.net/2019/05/20/5ce271e08158f47998.png',
    'https://i.loli.net/2019/05/20/5ce271e093c1039698.png',
  ];

  static var allLocation = [
    defaultImg,
    austin,
    beach,
    berlin,
    chicago,
    greatPlains,
    london,
    newYork,
    paris,
    sanFrancisco,
    seattle,
    tahoe
  ];

  /// 获取一个随机的城市（同一小时内，随机出的保持相同）
  static int getRandomLocationIndex() {
    return Random(DateTime.now().hour).nextInt(allLocation.length);
  }

  /// 获取当前时间段属于哪个区间
  static int getCurrentTimeIndex() {
    var hour = DateTime.now().hour;
    print(hour);
    if (hour < 4) {
      return INDEX_NIGHT;
    } else if (hour < 7) {
      return INDEX_DAWN;
    } else if (hour < 17) {
      return INDEX_DAY;
    } else if (hour < 20) {
      return INDEX_DUSK;
    } else {
      return INDEX_NIGHT;
    }
  }
}
