# Neumorphic Decoration Notes

本文档只基于以下几个文件整理：

- `lib/src/decoration/cache/abstract_neumorphic_painter_cache.dart`
- `lib/src/decoration/cache/neumorphic_deboss_painter_cache.dart`
- `lib/src/decoration/cache/neumorphic_emboss_painter_cache.dart`
- `lib/src/decoration/neumorphic_deboss_decoration_painter.dart`
- `lib/src/decoration/neumorphic_emboss_decoration_painter.dart`
- `lib/src/theme/themes.dart`
- `lib/src/theme/neumorphic_theme.dart`
- `lib/src/widget/checkbox.dart`
- `lib/src/widget/indicator.dart`
- `lib/src/widget/progress.dart`
- `lib/src/widget/radio.dart`
- `lib/src/widget/range_slider.dart`
- `lib/src/widget/slider.dart`
- `lib/src/widget/switch.dart`
- `lib/src/widget/toggle.dart`

## 1. 缓存层的职责

### `AbstractNeumorphicPainterCache`

这个抽象类负责缓存绘制时反复使用的数据：

- 组件位置和尺寸：`originOffset`、`width`、`height`
- 当前路径和拆分后的子路径：`path`、`subPaths`
- 绘制深度：`depth`
- 光源方向：`lightSource`
- 阴影颜色：`shadowLightColor`、`shadowDarkColor`
- 模糊：`maskFilter`
- 图层范围：`layerRect`

现在它已经从“一套绘制参数”扩展成“两套绘制参数”：

- 主参数：控制原始实现
- 附加参数：控制后加上的那层边沿效果

附加参数和主参数一样，也各自拥有：

- `depth`
- `intensity`
- `maskFilter`
- `depthOffset`
- 阴影颜色缓存

其中几组核心更新逻辑如下：

- `updateSize()`：缓存尺寸、偏移，并更新 `layerRect`
- `updateStyleDepth()`：把样式里的 `depth` 转成实际绘制深度，并生成 `maskFilter`
- `updateLightSource()`：结合 `lightSource` 和 `oppositeShadowLightSource` 得到真正参与绘制的光源
- `updateShadowColor()`：根据 `intensity` 计算最终高光色和阴影色
- `updateTranslations()`：由子类实现，负责计算高光/阴影图层的平移和缩放

### `NeumorphicDebossPainterCache` / `NeumorphicEmbossPainterCache`

这两个缓存类的 `updateTranslations()` 计算公式是一致的，都会生成：

- `whiteShadowLeftTranslation` / `whiteShadowTopTranslation`
- `blackShadowLeftTranslation` / `blackShadowTopTranslation`
- `scaleX` / `scaleY`

它们的含义不是“绘制顺序”，而是“哪一套遮罩最终会露出哪一侧的边沿”。

在加入独立控制以后，这两个 cache 也都新增了附加参数对应的第二套位移/缩放缓存。

## 2. Deboss 的实现方式

`NeumorphicDebossDecorationPainter` 的绘制顺序是：

1. 画背景
2. 画边框
3. 画内阴影

内阴影的关键在 `_paintShadows()`：

- 先画完整路径
- 再画一个经过平移和缩放的路径
- 第二次绘制使用 `BlendMode.dstOut`，把第一层的一部分“抠掉”

这样就会只在边沿留下细窄的高光或阴影带，形成凹入效果。

当光源位于左上时：

- 黑色层会留在左上边沿
- 白色层会留在右下边沿

这正是凹入效果需要的视觉结果。

## 3. Emboss 的实现方式

`NeumorphicEmbossDecorationPainter` 实际包含两部分视觉：

- `_drawShadow()`：负责元素外侧的投影，营造“凸出”
- `_drawGradient()`：负责元素表面的明暗变化

在 `shape == flat` 的分支里，`_drawGradient()` 复用了和 `deboss` 很接近的“路径 + 位移遮罩”做法，想在前景边沿再补一层细节光照。

现在 `emboss` 已经拆成两组参数：

- `depth / intensity`：控制外阴影
- `secondaryDepth / secondaryIntensity`：控制内部高光/阴影

## 4. 问题根因

问题不是简单的“先画白色还是先画黑色”。

真正决定边沿落点的是各自使用的 `translation`：

- `whiteShadowTranslation` 会让白色层最终露在一侧
- `blackShadowTranslation` 会让黑色层最终露在另一侧

如果只是交换绘制顺序，而白色仍然使用原来的 `whiteShadowTranslation`，黑色仍然使用原来的 `blackShadowTranslation`，那么亮边和暗边出现的位置不会改变。

所以你看到的现象才会是：

- 左上依旧是阴影
- 右下依旧是高光

## 5. 修复方法

在 `NeumorphicEmbossDecorationPainter._drawGradient()` 的 `flat` 分支中，不能只交换绘制顺序，而是要交换“颜色和位移的绑定关系”：

- 白色高光层改为使用 `blackShadowTranslation`
- 黑色阴影层改为使用 `whiteShadowTranslation`

这样当光源在左上时，前景边沿就会得到符合凸出效果的结果：

- 左上是高光
- 右下是阴影

对应地，`deboss` 现在也是两组参数：

- `depth / intensity`：控制内部凹入阴影
- `secondaryDepth / secondaryIntensity`：控制外部柔和边沿

## 6. 变更记录

### v1

- `emboss` 的 `flat` 前景边沿最初只是尝试交换绘制顺序。
- ~~只交换白色层和黑色层的绘制先后即可改变左右明暗位置~~
- 实际验证后确认：真正决定边沿落点的是 `translation`，不是绘制顺序。

### v2

- 在 `lib/src/decoration/neumorphic_emboss_decoration_painter.dart` 中修正了前景边沿的方向绑定：
  - 白色高光层改为使用 `blackShadowTranslation`
  - 黑色阴影层改为使用 `whiteShadowTranslation`
- ~~emboss 前景继续复用外阴影那组模糊底层画笔也能得到自然边沿~~
- 新结论：这种做法方向对了，但边沿会偏硬。

### v3

- `emboss` 前景新增一组专用画笔：
  - `_whiteForegroundPaint`
  - `_whiteForegroundMaskPaint`
  - `_blackForegroundPaint`
  - `_blackForegroundMaskPaint`
- `emboss` 的 `flat` 前景边沿改为完全参照 `deboss` 的内阴影模式：
  - 前景高光/阴影底层画笔不加模糊
  - 只给前景遮罩画笔加 `maskFilter`
- 这样得到的是更柔和的“左上高光、右下阴影”边沿。

### v4

- `deboss` 在保持内部凹入阴影实现不变的前提下，补充了一层外部柔和边沿。
- 新增的外部边沿效果为：
  - 左上外侧增加暗边
  - 右下外侧增加亮边
- `deboss` 外部边沿使用的是与 `emboss` 外阴影同类的软边模型：
  - 底层颜色画笔加 `maskFilter`
  - 遮罩画笔使用 `BlendMode.dstOut`
- 为了让外边沿跟随光源方向，同时补上了 `depthOffset` 的更新逻辑。
- 最终效果是：
  - 外侧左上暗、右下亮
  - 内侧左上暗、右下亮
  - 内外边沿彼此衔接，让 `deboss` 的边缘更圆润

### v5

- 补充外部柔和边沿后，`deboss` 原来的 `layerRect` 仍然只覆盖组件本身。
- ~~`deboss` 继续使用 `newOffset & newSize` 的图层范围也足够承载新增外边沿~~
- 实际验证后确认：新增的外扩模糊会超出原矩形范围，导致边沿和边框出现裁剪。
- 因此把 `lib/src/decoration/cache/neumorphic_deboss_painter_cache.dart` 中的 `updateLayerRect()` 改成了与 `emboss` 同类的外扩矩形，给外部柔和边沿和边框留出足够的绘制空间。

### v6

- 为了独立控制原始效果和新增边沿效果，缓存层从一套参数扩展成了两套：
  - `depth / intensity`
  - `secondaryDepth / secondaryIntensity`
- ~~新增的那层边沿效果继续复用主 `depth / intensity` 也足够~~
- 实际改造后确认：如果仍然共用一套参数，就无法分别调节：
  - `emboss` 外阴影 与 内部高光/阴影
  - `deboss` 内部凹入阴影 与 外部柔和边沿
- 因此：
  - `emboss`
    - `depth / intensity` 控制外阴影
    - `secondaryDepth / secondaryIntensity` 控制内部高光/阴影
  - `deboss`
    - `depth / intensity` 控制内部高光/阴影
    - `secondaryDepth / secondaryIntensity` 控制外部柔和边沿
- `theme` 层新增了附加参数默认值：
  - `secondaryDepth = 0.2`
  - `secondaryIntensity = 0.5`
- `NeumorphicStyle` 同步新增了这两个参数，并在 `copyWithThemeIfNull`、`copyWith`、`applyDisableDepth` 中一起传递。
- `widget` 层里会重新构造 `NeumorphicStyle(...)` 的封装组件，也补上了这组参数的透传，避免在组件封装过程中丢失它们。
