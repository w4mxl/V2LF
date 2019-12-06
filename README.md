Language: [English](README.md) | [中文简体](README-ZH.md)

<p align="center">
  <img src="https://s1.ax1x.com/2018/12/29/FfM6Yt.png" alt="FfM6Yt.png" border="0" />
</p>

## V2LF

[![LICENSE](https://img.shields.io/badge/license-GPL%20v3.0-blue.svg?style=flat-square)](https://github.com/w4mxl/V2LF/blob/master/LICENSE)

`V2LF` is a v2ex unofficial app.
**'V2LF' means 'way to love flutter'.**
The original intention of developing this app is to learn flutter.

[![Get it from iTunes](https://upload.wikimedia.org/wikipedia/commons/f/f8/Download_on_the_App_Store_Badge_NL_RGB_blk.svg)](https://apps.apple.com/cn/app/v2lf/id1455778208?mt=8) [![Get it on Google Play](https://upload.wikimedia.org/wikipedia/commons/archive/7/78/20190802123605%21Google_Play_Store_badge_EN.svg)](https://play.google.com/store/apps/details?id=io.github.w4mxl.v2lf)

[iOS TestFlight](https://testflight.apple.com/join/cvx4MQuh)

[CoolApk](https://www.coolapk.com/apk/221879)

## ScreenShot

![](https://i.loli.net/2019/08/19/NQVUa8p13GZdSxt.jpg)
![](https://i.loli.net/2019/08/19/CTg61O7XNWtb9V2.jpg)

## Building the project

### Missing Key.Properties file

If you try to build the project straight away, you'll get an error complaining that a `key.properties` file is missing and Exit code 1 from: /V2LF/android/gradlew app:properties:. To resolve that,

1.  Open V2LF\android\app\build.gradle file and comment following lines-

```
//keystoreProperties.load(new FileInputStream(keystorePropertiesFile))

signingConfigs {
// release {
// keyAlias keystoreProperties['keyAlias']
// keyPassword keystoreProperties['keyPassword']
// storeFile file(keystoreProperties['storeFile'])
// storePassword keystoreProperties['storePassword']
// }
}
buildTypes {
// release {
// signingConfig signingConfigs.release
// }
}
```

2.  Open V2LF\android\local.properties and add -

```
flutter.versionName=1.0.0
flutter.versionCode=1
flutter.buildMode=release
```

### The stack & building from source

The project is currently built using the latest Flutter Channel dev, with Dart 2 enabled.

To build the project, ensure that you have a recent version of the Flutter SDK installed. Then either run `flutter run` in the project root or use your IDE of choice.

## To-Do

Please pay attention to the project progress in [trello](https://trello.com/b/YPOJsfQx/v2lf)

## Related Links

- [邀请体验： V2LF - 用 Flutter 开发的 V2EX App](https://www.v2ex.com/t/548936#reply169)
- [V2LF - 使用 Flutter 开发的开源的 V2EX 客户端](https://www.v2ex.com/t/563913#reply57)
- [V2LF - 更新支持了 iOS（iPadOS）13 / Android 10 Dark Mode](https://www.v2ex.com/t/613127)

## License

[GPL v3.0 License](https://www.wikiwand.com/zh/GNU%E9%80%9A%E7%94%A8%E5%85%AC%E5%85%B1%E8%AE%B8%E5%8F%AF%E8%AF%81)
