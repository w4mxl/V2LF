// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

// ignore: unnecessary_new
final messages = new MessageLookup();

// ignore: unused_element
final _keepAnalysisHappy = Intl.defaultLocale;

// ignore: non_constant_identifier_names
typedef MessageIfAbsent(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  get localeName => 'en';

  static m0(num) => "Loading page ${num} ...";

  static m1(name) => "Welcome back, ${name}!";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "about" : MessageLookupByLibrary.simpleMessage("About"),
    "account" : MessageLookupByLibrary.simpleMessage("Account"),
    "actionFav" : MessageLookupByLibrary.simpleMessage("Favorite"),
    "browser" : MessageLookupByLibrary.simpleMessage("Open from browser"),
    "cancel" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "captcha" : MessageLookupByLibrary.simpleMessage("Captcha"),
    "copyContent" : MessageLookupByLibrary.simpleMessage("Copy content"),
    "copyLink" : MessageLookupByLibrary.simpleMessage("Copy link"),
    "enterAccount" : MessageLookupByLibrary.simpleMessage("Enter account"),
    "enterCaptcha" : MessageLookupByLibrary.simpleMessage("Enter right captcha"),
    "enterPassword" : MessageLookupByLibrary.simpleMessage("Enter password"),
    "favorites" : MessageLookupByLibrary.simpleMessage("Favorites"),
    "feedback" : MessageLookupByLibrary.simpleMessage("Feedback"),
    "forgetPassword" : MessageLookupByLibrary.simpleMessage("Forgot password ?"),
    "languageAuto" : MessageLookupByLibrary.simpleMessage("Auto"),
    "loadingPage" : m0,
    "login" : MessageLookupByLibrary.simpleMessage("Login"),
    "logout" : MessageLookupByLibrary.simpleMessage("Logout"),
    "logoutLong" : MessageLookupByLibrary.simpleMessage("Log out"),
    "noComment" : MessageLookupByLibrary.simpleMessage("no comment yet"),
    "nodes" : MessageLookupByLibrary.simpleMessage("Nodes"),
    "notifications" : MessageLookupByLibrary.simpleMessage("Notifications"),
    "password" : MessageLookupByLibrary.simpleMessage("Password"),
    "reply" : MessageLookupByLibrary.simpleMessage("Reply"),
    "replyHint" : MessageLookupByLibrary.simpleMessage("(u_u)  Please try to make the reply helpful to others"),
    "replySuccess" : MessageLookupByLibrary.simpleMessage("Reply Success!"),
    "settings" : MessageLookupByLibrary.simpleMessage("Settings"),
    "share" : MessageLookupByLibrary.simpleMessage("Share"),
    "sureLogout" : MessageLookupByLibrary.simpleMessage("Are you sure you want to sign out ?"),
    "thank" : MessageLookupByLibrary.simpleMessage("Thank"),
    "titleLanguage" : MessageLookupByLibrary.simpleMessage("Language"),
    "titleSetting" : MessageLookupByLibrary.simpleMessage("Setting"),
    "titleTheme" : MessageLookupByLibrary.simpleMessage("Theme"),
    "toastLoginSuccess" : m1
  };
}
