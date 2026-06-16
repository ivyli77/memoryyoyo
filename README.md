# 旅行故事盲盒 · Travel Story Blind Box

一个记录、随机抽取、回看「过去旅行的一句话/一段话故事」的安卓小工具。
胶片 / 旅行明信片复古风,本地永久保存,无需联网、无需账号。

## 三个标签页

1. **记录** — 在明信片上写下一句话或一段旅行故事,投入盲盒。
2. **抽取** — 转动胶卷,缓缓减速,定格中间一帧,「显影」浮现一段随机旧时光。
3. **故事库** — 所有记录,新→旧排列,轻触任意一张即可二次修改或删除。

数据用 `shared_preferences` 存在本机,关掉再打开仍在;卸载 App 会清空。

---

## 怎么编译成 APK

本工程只包含 `lib/` 源码和 `pubspec.yaml`。安卓/iOS 的平台脚手架用 Flutter 一行命令生成即可。

### 0. 准备环境
安装 [Flutter SDK](https://docs.flutter.dev/get-started/install)(含 Android SDK / Android Studio),确认:
```bash
flutter doctor
```

### 1. 生成平台脚手架并放入源码
```bash
# 在本文件夹的上一级目录执行,生成完整安卓工程骨架
flutter create travel_story_blindbox

# 然后用本工程的 lib/ 和 pubspec.yaml 覆盖刚生成的同名文件:
#   - 用本 lib/        覆盖 travel_story_blindbox/lib/
#   - 用本 pubspec.yaml 覆盖 travel_story_blindbox/pubspec.yaml
```
> 如果你已经在本文件夹里,也可以直接 `flutter create .`(它只补平台目录,不会动已有的 lib/ 与 pubspec.yaml)。

### 2. 拉依赖
```bash
cd travel_story_blindbox
flutter pub get
```

### 3. 真机/模拟器先跑一遍
```bash
flutter run
```

### 4. 打 release APK
```bash
flutter build apk --release
```
产物路径:
```
build/app/outputs/flutter-apk/app-release.apk
```
把它传到手机安装即可(需在系统里允许「未知来源」安装)。

> 想要更小的体积可按 ABI 分包:
> `flutter build apk --split-per-abi`

---

## 可改的小地方

| 想改什么 | 去哪里 |
|---|---|
| 配色 / 字体 | `lib/theme/app_theme.dart` |
| 抽取动画时长、定格位置、帧色调 | `lib/screens/draw_screen.dart` 顶部常量与 `_toneGradient` |
| 应用名 | `pubspec.yaml` 的 `name`,以及 `flutter create` 生成的 `AndroidManifest.xml` 里的 `android:label` |
| 应用图标 | 推荐用 [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) |

## 文件结构
```
lib/
  main.dart                 # 入口 + 三 tab 底部导航
  theme/app_theme.dart      # 配色与主题
  models/story.dart         # 故事数据模型
  services/story_store.dart # 本地存储（shared_preferences）
  utils/date_format.dart    # 日期格式化
  widgets/
    screen_header.dart      # 各页头部
    edit_sheet.dart         # 编辑/删除底部弹层
  screens/
    record_screen.dart      # Tab1 记录
    draw_screen.dart        # Tab2 抽取（胶卷动画）
    library_screen.dart     # Tab3 故事库
```
