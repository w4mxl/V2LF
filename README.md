Language: [English](README.md) | [中文简体](README-ZH.md)

<p align="center">
  <img src="https://s1.ax1x.com/2018/12/29/FfM6Yt.png" alt="FfM6Yt.png" border="0" />
</p>

## V2LF

[![LICENSE](https://img.shields.io/badge/license-GPL%20v3.0-blue.svg?style=flat-square)](https://github.com/w4mxl/V2LF/blob/master/LICENSE)

`V2LF` is a v2ex unofficial app.
**'V2LF' means 'way to love flutter'.**
The original intention of developing this app is to learn flutter.

🆓 **Completely Free**
- [iOS TestFlight (1500 maximum number of people)](https://testflight.apple.com/join/cvx4MQuh)

- [CoolApk](https://www.coolapk.com/apk/221879)

💹 **Paid Support ($1.99)**
- [![Get it from iTunes](https://upload.wikimedia.org/wikipedia/commons/f/f8/Download_on_the_App_Store_Badge_NL_RGB_blk.svg)](https://apps.apple.com/cn/app/v2lf/id1455778208?mt=8)

- [![Get it on Google Play](https://upload.wikimedia.org/wikipedia/commons/archive/7/78/20190802123605%21Google_Play_Store_badge_EN.svg)](https://play.google.com/store/apps/details?id=io.github.w4mxl.v2lf)


## ScreenShot

- on iPhone
![](https://i.loli.net/2019/08/19/NQVUa8p13GZdSxt.jpg)
![](https://i.loli.net/2019/08/19/CTg61O7XNWtb9V2.jpg)

- on iPad (The way i use most)
![](https://tva1.sinaimg.cn/large/007S8ZIlgy1gic60gzt63j31410u0jwj.jpg)
![](https://tva1.sinaimg.cn/large/007S8ZIlgy1gic61arpirj316y0u0djo.jpg)
![](https://tva1.sinaimg.cn/large/007S8ZIlgy1gic61nzclgj316y0u0jtq.jpg)

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

The project is currently built using the latest Flutter Channel `beta`.

To build the project, ensure that you have a recent version of the Flutter SDK installed. Then either run `flutter run` in the project root or use your IDE of choice.

## To-Do

If you are interested in this project, please pay attention to the project progress in this [notion page](https://www.notion.so/f6328282617a4b76b56ceeef83883a3e?v=739b62f32b7e4f58a81b8ace87105b3a). You can also leave a comment on that page.

## Related Links

- [邀请体验： V2LF - 用 Flutter 开发的 V2EX App](https://www.v2ex.com/t/548936#reply169)
- [V2LF - 使用 Flutter 开发的开源的 V2EX 客户端](https://www.v2ex.com/t/563913#reply57)
- [V2LF - 更新支持了 iOS（iPadOS）13 / Android 10 Dark Mode](https://www.v2ex.com/t/613127)

## Reward

If you like to use `V2LF`, or feel that this project is helpful to you, you can click on the upper right corner ⭐Star to support me, thank you ^_^ <br />

If you are happy, you can also scan the QR code below and reward me to have a pop-ice and double happy instantly ; )

<p align="center"><img src="https://tva1.sinaimg.cn/large/007S8ZIlgy1gid7jerzz1j30m40xkaaf.jpg"  width="240" ></p>

## License

[GPL v3.0 License](https://www.wikiwand.com/zh/GNU%E9%80%9A%E7%94%A8%E5%85%AC%E5%85%B1%E8%AE%B8%E5%8F%AF%E8%AF%81)
