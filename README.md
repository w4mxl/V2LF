# V2LF

<p align="center">
  <img src="https://s1.ax1x.com/2018/12/29/FfM6Yt.png" alt="FfM6Yt.png" border="0" />
</p>

`V2LF` is a v2ex unofficial app.**'V2LF' means 'way to love flutter'.**
The original intention of developing this app is to learn flutter.

[![LICENSE](https://img.shields.io/badge/license-GPL%20v3.0-blue.svg?style=flat-square)](https://github.com/w4mxl/V2LF/blob/master/LICENSE)

## ScreenShot

![](https://ws3.sinaimg.cn/large/006tNc79gy1g2n2s34asfj31xl0u0hdt.jpg)
![](https://ws2.sinaimg.cn/large/006tNc79gy1g2n2sd61vnj31xl0u0npd.jpg)


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

## License

[GPL v3.0 License](https://www.wikiwand.com/zh/GNU%E9%80%9A%E7%94%A8%E5%85%AC%E5%85%B1%E8%AE%B8%E5%8F%AF%E8%AF%81)
