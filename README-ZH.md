Language: [English](README.md) | [中文简体](README-ZH.md)

<p align="center">
  <img src="https://s1.ax1x.com/2018/12/29/FfM6Yt.png" alt="FfM6Yt.png" border="0" />
</p>

## V2LF

`V2LF` 是一个 v2ex 技术社区的第三方 app。
**'V2LF' 名字是取 'way to love flutter' 的缩写。**
开发这个 app 的初衷是想在实战中学习 Flutter。

[![LICENSE](https://img.shields.io/badge/license-GPL%20v3.0-blue.svg?style=flat-square)](https://github.com/w4mxl/V2LF/blob/master/LICENSE)

## 截图预览

![](https://ws3.sinaimg.cn/large/006tNc79gy1g2n2s34asfj31xl0u0hdt.jpg)
![](https://ws2.sinaimg.cn/large/006tNc79gy1g2n2sd61vnj31xl0u0npd.jpg)


## 编译运行

### 缺失 Key.Properties 文件

下载源码后首次运行，您将会收到一个错误，提示缺少 key.properties 文件。
请通过下面步骤解决这个问题，

1.  打开 V2LF\android\app\build.gradle 文件，然后参考下面，注释掉其中一些代码

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

2.  打开 V2LF\android\local.properties ，然后在最后添加下面几行代码：

```
flutter.versionName=1.0.0
flutter.versionCode=1
flutter.buildMode=release
```

### 开发环境

这个项目目前是在 Flutter Dev 分支 + Dart 2 环境下开发的，每次 Flutter SDK 升级后也会做相应的适配和兼容。
想正常编译运行此项目，请先确定您已经正确配置好 Flutter 开发环境。

## To-Do

如您对此项目进展有兴趣，请通过关注 [trello](https://trello.com/b/YPOJsfQx/v2lf) 来追踪最新动态。

## 代码许可

[GPL v3.0 License](https://www.wikiwand.com/zh/GNU%E9%80%9A%E7%94%A8%E5%85%AC%E5%85%B1%E8%AE%B8%E5%8F%AF%E8%AF%81)
