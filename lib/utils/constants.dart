import 'package:flutter_app/models/tab.dart';

const String HOST = 'https://www.v2ex.com/';
const String API_PATH = 'api/';

const String API_HOST = HOST + API_PATH;

/// 取网站信息
/// @GET
/// {
///   "title" : "V2EX",
///   "slogan" : "way to explore",
///   "description" : "创意工作者们的社区",
///   "domain" : "www.v2ex.com"
/// }
const String API_SITE_INFO = API_HOST + 'site/info.json';

/// 取网站状态
/// @GET
/// {
///   "topic_max" : 126172,
///   "member_max" : 71033
/// }
const String API_SITE_STATUS = API_HOST + 'site/stats.json';

/// 取最新主题
/// @GET
const String API_TOPICS_LATEST = API_HOST + 'topics/latest.json';

/// 取热议主题
/// @GET
const String API_TOPICS_HOT = API_HOST + 'topics/hot.json';

/// 主题详细信息
/// @GET
/// @param id 话题id
const String API_TOPIC_DETAILS = API_HOST + 'topics/show.json';

/// 取主题回复
/// @GET
/// @param topic_id
/// @param page
/// @param page_size
const String API_TOPIC_REPLY = API_HOST + 'replies/show.json';

/// 取用户信息
/// @GET
/// @param username
const String API_MEMBER = API_HOST + 'members/show.json';

/// 取节点信息
/// @GET
/// @param name
const String API_NODE = API_HOST + 'nodes/show.json';

/// 取所有节点列表
/// @GET
/// @param name
const String API_ALL_NODES = API_HOST + 'nodes/all.json';

// 获取今日诗词token
// {
//   "status": "success",
//   "data": "RgU1rBKtLym/MhhYIXs42WNoqLyZeXY3EkAcDNrcfKkzj8ILIsAP1Hx0NGhdOO1I"
// }
const String API_JINRISHICI_TOKEN = 'https://v2.jinrishici.com/token';

// 您需要在 HTTP 的 Headers 头中指定 Token
// X-User-Token： RgU1rBKtLym/MhhYIXs42WNoqLyZeXY3EkAcDNrcfKkzj8ILIsAP1Hx0NGhdOO1I
const String API_JINRISHICI_ONE = 'https://v2.jinrishici.com/one.json';

List<TabModel> TABS = <TabModel>[
  TabModel('全部', 'all'),
  TabModel('最热', 'hot'),
  TabModel('技术', 'tech'),
  TabModel('创意', 'creative'),
  TabModel('好玩', 'play'),
  TabModel('APPLE', 'apple'),
  TabModel(
    '酷工作',
    'jobs',
  ),
  TabModel('交易', 'deals'),
  TabModel('城市', 'city'),
  TabModel('问与答', 'qna'),
  TabModel('R2', 'r2'),
];
