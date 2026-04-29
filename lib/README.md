# Flutter-Neumorphic `lib` 架构索引

本文档聚焦 `lib/` 目录，目标是用尽量低的阅读成本建立这个插件的整体认知，让后续分析只读取真正需要的文件。

## 1. 项目类型

- 类型：Flutter UI 组件库 / 插件
- 主要语言：Dart
- 对外入口：`lib/flutter_neumorphic.dart`
- 运行形态：以主题系统为中心，以 `NeumorphicContainer` 为核心渲染容器，在其上继续封装按钮、滑块、开关、文本、应用壳等组件
- 置信度：high
- 证据：
  - `pubspec.yaml` 仅依赖 Flutter SDK，并注册了 `NeumorphicIcons.ttf`
  - `lib/flutter_neumorphic.dart` 主要承担 export 汇总职责，符合公共包 API 入口的常见形态

## 2. `lib/` 顶层结构树

```text
lib/
|-- flutter_neumorphic.dart         # 公共 API 入口
|-- src/
|   |-- colors.dart                 # 颜色常量与默认阴影/文本色
|   |-- light_source.dart           # 光源方向模型
|   |-- surface_type.dart           # flat / concave / convex 等表面语义
|   |-- neumorphic_box_shape.dart   # 统一的盒模型形状抽象，承接 path provider
|   |-- neumorphic_icons.dart       # 图标字体入口
|   |-- clip_path/                  # 几何路径生成层
|   |-- decoration/                 # painter、渐变、边框、缓存
|   |-- theme/                      # ThemeData、Inherited theme 状态、app bar 主题
|   `-- widget/                     # 复用型 neumorphic 组件
`-- dev_progress.md                 # 开发记录，不属于运行时核心路径
```

## 3. 分层架构

### 3.1 公共 API 层

- `lib/flutter_neumorphic.dart`
  - 角色：整个包对外的统一导出面
  - `depends_on`：`src/colors.dart`、`src/neumorphic_box_shape.dart`、`src/theme/*.dart`、`src/widget/*.dart`
  - 关系类型：explicit
  - 证据：`export` 语句
  - 置信度：high
  - `depended_on_by`：很多内部文件也反向 import 它，作为统一符号入口
  - 证据：重复出现的 `import '../../flutter_neumorphic.dart'`
  - 置信度：high
  - 影响：修改这里会影响包的可见 API、对外暴露方式以及内部 import 风格

### 3.2 几何与基础类型层

- `lib/src/neumorphic_box_shape.dart`
  - 角色：统一 `rect`、`roundRect`、`circle`、`stadium`、`beveled` 和 custom path 等形状
  - `depends_on`：`src/clip_path/*.dart`
  - 关系类型：explicit
  - 证据：直接 import 各类 path provider
  - 置信度：high
  - `depended_on_by`：`src/widget/container.dart`、`src/decoration/*.dart` 以及部分 widget 样式定义
  - 影响：几乎所有需要渲染 neumorphic 形状的组件都会受影响

- `lib/src/clip_path/neumorphic_path_provider.dart`
  - 角色：自定义路径生成与裁剪的抽象基类
  - `depends_on`：Flutter `CustomClipper<Path>`
  - 关系类型：explicit
  - 置信度：high
  - `depended_on_by`：`neumorphic_box_shape.dart` 以及 circle、rect、rrect 等具体 provider
  - 影响：影响裁剪行为，以及是否按子路径拆分渐变

- `lib/src/colors.dart`、`lib/src/light_source.dart`、`lib/src/surface_type.dart`
  - 角色：颜色、光照、表面语义等共享常量与枚举
  - `depended_on_by`：主题层、绘制层以及 widget 里的样式对象
  - 关系类型：explicit
  - 置信度：high

### 3.3 主题层

- `lib/src/theme/themes.dart`
  - 角色：定义 `NeumorphicThemeData`，是颜色、深度、强度、文本、图标、app bar、按钮样式等默认值的集中定义处
  - `depends_on`：颜色/光源/表面等基础类型，以及公共导出符号
  - 关系类型：explicit
  - 证据：直接 import `../../flutter_neumorphic.dart`
  - 置信度：high
  - `depended_on_by`：`neumorphic_theme.dart`，以及通过 `NeumorphicTheme.currentTheme(context)` 间接读取主题的多数 widget
  - 关系类型：explicit + inferred
  - 置信度：high
  - 影响：修改这里会改变几乎所有组件的默认外观

- `lib/src/theme/neumorphic_theme.dart`
  - 角色：有状态的主题宿主与静态访问入口，负责当前主题、暗色模式选择、全局初始化和深度包装
  - `depends_on`：`themes.dart`、`theme_wrapper.dart`、`neumorphic_theme_inherited.dart`
  - 关系类型：explicit
  - 置信度：high
  - `depended_on_by`：`widget/container.dart`、`widget/button.dart`、`widget/slider.dart` 以及许多其他 widget
  - 关系类型：explicit
  - 置信度：high
  - 影响：修改这里会影响主题值的传播方式，以及暗色模式如何决策

- `lib/src/theme/neumorphic_theme_inherited.dart`
  - 角色：Inherited theme 状态包装层，并提供更新 hook
  - `depends_on`：`ThemeWrapper`
  - `depended_on_by`：`NeumorphicTheme.of(context)`
  - 关系类型：explicit
  - 置信度：high
  - 影响：运行时主题更新行为

- `lib/src/theme/theme_wrapper.dart`
  - 角色：不可变的 light/dark theme 选择器，基于 `ThemeMode` 与平台亮度决定当前主题
  - `depends_on`：Flutter `ThemeMode`、平台亮度
  - 关系类型：explicit
  - 置信度：high
  - 影响：决定运行时当前启用的是哪套主题

### 3.4 绘制与 painter 层

- `lib/src/decoration/neumorphic_decorations.dart`
  - 角色：定义 `NeumorphicDecoration`，并根据 style depth 选择 emboss 或 deboss painter
  - `depends_on`：`neumorphic_emboss_decoration_painter.dart`、`neumorphic_deboss_decoration_painter.dart`、`neumorphic_box_shape.dart`
  - 关系类型：explicit
  - 置信度：high
  - `depended_on_by`：`widget/container.dart`
  - 证据：同时赋给 `foregroundDecoration` 与 `decoration`
  - 置信度：high
  - 影响：控制所有 neumorphic 容器的绘制方式

- `lib/src/decoration/neumorphic_emboss_decoration_painter.dart`
  - 角色：核心 painter，负责阴影、渐变、边框、路径缓存与阴影位移等视觉逻辑
  - `depends_on`：`cache/neumorphic_emboss_painter_cache.dart`、`neumorphic_box_decoration_helper.dart`、`themes.dart`
  - 关系类型：explicit
  - 置信度：high
  - `depended_on_by`：`NeumorphicDecoration.createBoxPainter()`
  - 置信度：high
  - 影响：直接决定最终视觉效果和绘制成本

- `lib/src/decoration/cache/*`
  - 角色：缓存 path、mask filter、shadow offset、color 等派生绘制状态
  - 影响：影响重绘成本与视觉性能
  - 置信度：medium-high

- `lib/src/decoration/neumorphic_box_decoration_helper.dart`
  - 角色：渐变 shader 的辅助工具
  - `depended_on_by`：emboss/deboss painter
  - 关系类型：explicit
  - 置信度：high
  - 影响：影响渐变方向以及高光/阴影混合效果

### 3.5 Widget 层

- `lib/src/widget/container.dart`
  - 角色：整个包的渲染汇聚点；在 `AnimatedContainer` 中组合主题值、shape、动画、裁剪、背景/前景 decoration
  - `depends_on`：`neumorphic_box_shape.dart`、`neumorphic_decorations.dart`、`neumorphic_theme.dart`、`clipper/neumorphic_box_shape_clipper.dart`
  - 关系类型：explicit
  - 置信度：high
  - `depended_on_by`：按钮、文本、进度、滑块、图标及其他高层 widget
  - 关系类型：explicit + inferred
  - 置信度：high
  - 影响：这是整个 `lib/` 树里影响面最大的文件之一

- `lib/src/widget/app.dart`
  - 角色：`NeumorphicApp`，在 `MaterialApp` 外包裹 `NeumorphicTheme`
  - `depends_on`：`NeumorphicTheme`、`MaterialApp`
  - 关系类型：explicit
  - 置信度：high
  - `depended_on_by`：把该包作为应用壳来使用的宿主 app
  - 关系类型：inferred
  - 置信度：medium
  - 影响：应用级主题注入、图标主题传播、路由启动

- `lib/src/widget/button.dart`
  - 角色：交互式 neumorphic 按钮，负责按压深度动画、缩放动画和 haptic feedback
  - `depends_on`：`NeumorphicContainer`、`NeumorphicTheme`、`animation/animated_scale.dart`
  - 关系类型：explicit
  - 置信度：high
  - 影响：按钮交互和按压态视觉反馈
  - `influenced_by`：主题按钮样式、app bar 按钮样式、`onPressed` 和 pressed state

- `lib/src/widget/slider.dart`
  - 角色：滑块组件，使用 `NeumorphicProgress` 渲染轨道，使用 `NeumorphicContainer` 渲染 thumb
  - `depends_on`：`NeumorphicTheme`、`NeumorphicProgress`、`NeumorphicContainer`
  - 关系类型：explicit
  - 置信度：high
  - 影响：范围选择类 UI 的行为与 thumb 渲染
  - `influenced_by`：`SliderStyle`、accent color、variant color、light source

- `lib/src/widget/*`
  - 角色：app bar、checkbox、radio、switch、toggle、text、icon、progress、indicator 等复用组件
  - 共性依赖模式：多数文件直接 import `../../flutter_neumorphic.dart`
  - 关系类型：explicit
  - 置信度：high

## 4. 主流程骨架

### 4.1 应用启动路径

`lib/flutter_neumorphic.dart`
-> `lib/src/widget/app.dart`
-> `NeumorphicTheme`
-> `lib/src/theme/neumorphic_theme_inherited.dart`
-> `MaterialApp`

- 含义：当宿主应用使用 `NeumorphicApp` 时，主题状态会在应用根部附近注入
- 证据：`widget/app.dart` 中的直接 build 树
- 置信度：high

### 4.2 Widget 渲染路径

`lib/src/widget/button.dart` 或其他高层 widget
-> `lib/src/widget/container.dart`
-> `lib/src/decoration/neumorphic_decorations.dart`
-> `lib/src/decoration/neumorphic_*_decoration_painter.dart`
-> `lib/src/neumorphic_box_shape.dart`
-> `lib/src/clip_path/*`

- 含义：大多数组件最终都会收敛到 `NeumorphicContainer`，再流向 decoration painter 和 shape/path provider
- 证据：显式 import 以及 decoration 赋值链路
- 置信度：high

### 4.3 主题解析路径

`lib/src/theme/themes.dart`
-> `lib/src/theme/theme_wrapper.dart`
-> `lib/src/theme/neumorphic_theme.dart`
-> `NeumorphicTheme.currentTheme(context)`
-> `lib/src/widget/*`

- 含义：默认主题值先统一声明，再包进 light/dark 选择器，最后由各 widget 在 build 时按需读取
- 证据：显式静态方法调用与 wrapper 用法
- 置信度：high

## 5. 最高价值阅读顺序

如果目标是快速理解这个包，建议先看：

1. `lib/flutter_neumorphic.dart`
   - 原因：先看公共 API 面
2. `lib/src/theme/themes.dart`
   - 原因：这里定义默认样式系统
3. `lib/src/theme/neumorphic_theme.dart`
   - 原因：这里解释主题值如何被提供和读取
4. `lib/src/widget/container.dart`
   - 原因：这是被大量 widget 复用的渲染核心
5. `lib/src/decoration/neumorphic_decorations.dart`
   - 原因：这里决定 painter 策略
6. `lib/src/decoration/neumorphic_emboss_decoration_painter.dart`
   - 原因：这里承载最重的视觉逻辑
7. `lib/src/neumorphic_box_shape.dart`
   - 原因：这里解释 box shape 如何接入路径系统
8. `lib/src/widget/button.dart` 或 `lib/src/widget/slider.dart`
   - 原因：它们是高层 widget 如何组合下层模块的代表性样例

## 6. 依赖与影响总结

- 主题层是默认值来源
  - `themes.dart` 和 `neumorphic_theme.dart` 决定样式字段缺省时 widget 继承什么值
- `NeumorphicContainer` 是渲染汇聚点
  - 很多 widget 不直接绘制，而是委托给 container 层
- decoration 层是视觉引擎
  - 阴影、渐变、边框、缓存都在这里实现
- shape/path 层是几何抽象
  - 它不持有主题状态，但会强烈影响裁剪和最终轮廓
- widget 层负责交互和语义
  - 手势、pressed state、动画触发和具体组件组合都发生在这里

## 7. 可能的改动影响面

- 修改 `lib/src/theme/themes.dart`
  - 可能影响：几乎所有默认颜色、深度、强度、图标样式、按钮样式
  - 置信度：high

- 修改 `lib/src/theme/neumorphic_theme.dart`
  - 可能影响：主题传播、暗色模式逻辑、全局初始化逻辑
  - 置信度：high

- 修改 `lib/src/widget/container.dart`
  - 可能影响：几乎所有基于该包构建的可视组件
  - 置信度：high

- 修改 `lib/src/decoration/neumorphic_decorations.dart` 或 painter 文件
  - 可能影响：emboss/deboss 外观、阴影方向、渐变行为、重绘成本
  - 置信度：high

- 修改 `lib/src/neumorphic_box_shape.dart` 或 `lib/src/clip_path/*`
  - 可能影响：裁剪、shape 插值、round-rect/circle/beveled/custom path 的最终输出
  - 置信度：high

## 8. 不确定点

- `lib/src/widget/` 下不是每个 widget 文件都做了细展开
  - 当前推断：它们中的多数复用了相同的主题和 container 基础设施
  - 证据：重复 import `flutter_neumorphic.dart`
  - 置信度：medium

- `app_bar.dart`、`background.dart`、`indicator.dart`、`progress.dart` 本文未逐个展开内部实现
  - 当前推断：它们主要是在共享渲染栈之上的场景化包装
  - 置信度：medium

## 9. 建议的下一步阅读

按目标选择下一步：

1. 想看主题链路
   - 读 `src/theme/themes.dart` -> `src/theme/neumorphic_theme.dart`
2. 想看渲染链路
   - 读 `src/widget/container.dart` -> `src/decoration/neumorphic_decorations.dart` -> `src/decoration/neumorphic_emboss_decoration_painter.dart`
3. 想看形状系统
   - 读 `src/neumorphic_box_shape.dart` -> `src/clip_path/neumorphic_path_provider.dart` -> 任一具体 provider
4. 想看具体 widget 组合方式
   - 读 `src/widget/button.dart` 或 `src/widget/slider.dart`
