# Flutter Neumorphic lib 架构索引

## 项目类型
- 推断：Flutter UI 插件 / 组件库
- 证据：[../flutter_neumorphic.dart](../flutter_neumorphic.dart) 声明 library 并导出主题、形状、装饰和 widget；[../src/widget/app.dart](../src/widget/app.dart) 封装 `MaterialApp`；源码大量导入 Flutter `material` 与 `widgets`。
- 置信度：高

## 架构树
- [../flutter_neumorphic.dart](../flutter_neumorphic.dart)：公共 API 聚合入口，向插件使用者导出核心类型和组件。
- [../src/colors.dart](../src/theme/colors.dart)：Neumorphic 默认颜色常量。
- [../src/light_source.dart](../src/light_source.dart)：光源方向模型，影响阴影方向和渐变方向。
- [../src/surface_type.dart](../src/surface_type.dart)：表面形态枚举，区分 `flat`、`concave`、`convex`。
- [../src/neumorphic_box_shape.dart](../src/neumorphic_box_shape.dart)：形状门面，把 `circle`、`rect`、`roundRect`、`stadium`、`beveled`、自定义 path 映射到 `NeumorphicPathProvider`。
- [../src/clip_path/](../src/clip_path/)：路径与裁剪层，负责把形状参数转换成 Flutter `Path`。
- [../src/decoration/](../src/decoration/)：绘制层，把 `NeumorphicStyle`、shape、depth 转换成 Flutter `Decoration` / `BoxPainter`。
- [../src/decoration/cache/](../src/decoration/cache/)：绘制缓存层，缓存尺寸、路径、分段路径、阴影偏移、mask filter 和颜色。
- [../src/theme/](../src/theme/)：主题层，定义 `NeumorphicThemeData`、`NeumorphicStyle`、InheritedWidget 和主题包装器。
- [../src/widget/](../src/widget/)：组件层，公开 app、app bar、container、button、checkbox、slider、switch、text 等控件。
- [../src/widget/clipper/neumorphic_box_shape_clipper.dart](../src/widget/clipper/neumorphic_box_shape_clipper.dart)：组件裁剪工具，把同一个 shape path 应用到 child 裁剪。
- [./](./)：本架构文档目录。

## 核心入口
- [../flutter_neumorphic.dart](../flutter_neumorphic.dart)：显式导出公共 API，是插件用户最可能导入的入口。
- [../src/widget/app.dart](../src/widget/app.dart)：`NeumorphicApp` 封装 `NeumorphicTheme`、`IconTheme` 和 `MaterialApp`，是整包式应用入口。
- [../src/theme/neumorphic_theme.dart](../src/theme/neumorphic_theme.dart)：`NeumorphicTheme` 提供主题上下文、全局主题初始化和主题查询静态方法。
- [../src/widget/container.dart](../src/widget/container.dart)：`NeumorphicContainer` 是视觉渲染核心，大多数控件通过它获得凹凸效果。
- [../src/neumorphic_box_shape.dart](../src/neumorphic_box_shape.dart)：形状 API 入口，使用者通过 `NeumorphicBoxShape.*` 选择路径来源。

## 模块边界
- `public-api`：[../flutter_neumorphic.dart](../flutter_neumorphic.dart) 只负责导出，不直接实现 UI 行为。
- `theme`：[../src/theme/](../src/theme/) 定义主题数据、样式数据、主题状态传播和 Material 主题桥接。
- `shape-path`：[../src/neumorphic_box_shape.dart](../src/neumorphic_box_shape.dart) 与 [../src/clip_path/](../src/clip_path/) 把高级 shape 选择转换成可绘制、可裁剪的 `Path`。
- `decoration-painting`：[../src/decoration/](../src/decoration/) 根据样式深度选择 emboss/deboss painter，并执行阴影、渐变、背景和边框绘制。
- `widget-kit`：[../src/widget/](../src/widget/) 面向用户提供 Flutter widgets，组合主题、容器、动画和输入事件。
- `tokens`：[../src/colors.dart](../src/theme/colors.dart)、[../src/light_source.dart](../src/light_source.dart)、[../src/surface_type.dart](../src/surface_type.dart)、[../src/neumorphic_icons.dart](../src/neumorphic_icons.dart) 提供基础设计 token 与枚举。

## 源码详解

### 形状路径模块
- 形状不是由 widget 自己直接写死路径，而是由 [../src/neumorphic_box_shape.dart](../src/neumorphic_box_shape.dart) 保存一个 `customShapePathProvider`。
- `NeumorphicPathProvider` 定义在 [../src/clip_path/neumorphic_path_provider.dart](../src/clip_path/neumorphic_path_provider.dart)，它继承 `CustomClipper<Path>`，`getClip(size)` 直接返回 `getPath(size)`。
- 因为 path provider 本身就是 `CustomClipper<Path>`，同一个对象既能给 `ClipPath` 裁剪 child，也能给 painter 获取 `Path` 来绘制背景、阴影、渐变和边框。
- [../src/decoration/cache/abstract_neumorphic_painter_cache.dart](../src/decoration/cache/abstract_neumorphic_painter_cache.dart) 的 `updatePath(newPath)` 会缓存完整 path，并通过 `computeMetrics()` 拆出 `subPaths`，供多段 path 分别绘制。
- `oneGradientPerPath` 决定 concave/convex 渐变是否按子路径分开绘制：普通矩形、圆、圆角矩形、体育场、斜角形都是 `false`；Flutter logo 自定义路径是 `true`。

#### 内置形状 Path 来源
- `NeumorphicBoxShape.rect()` -> [../src/clip_path/rect_path_provider.dart](../src/clip_path/rect_path_provider.dart)：用 `Path.addRect(Rect.fromLTWH(0, 0, width, height))` 得到矩形路径。
- `NeumorphicBoxShape.circle()` -> [../src/clip_path/circle_path_provider.dart](../src/clip_path/circle_path_provider.dart)：用 `Path.addOval(Rect.fromCircle(...))`，半径取宽高一半中的较小值，因此非正方形区域内会生成居中的最大圆。
- `NeumorphicBoxShape.roundRect(borderRadius)` -> [../src/clip_path/rrect_path_provider.dart](../src/clip_path/rrect_path_provider.dart)：用 `RRect.fromLTRBAndCorners(...)` 和 `Path.addRRect(...)`，四角半径来自传入的 `BorderRadius`。
- `NeumorphicBoxShape.stadium()` -> [../src/clip_path/stadium_path_provider.dart](../src/clip_path/stadium_path_provider.dart)：继承 `RRectPathProvider`，传入 `BorderRadius.all(Radius.circular(1000))`，依赖 Flutter 的 RRect 约束形成胶囊/体育场效果。
- `NeumorphicBoxShape.beveled(borderRadius)` -> [../src/clip_path/beveled_path_provider.dart](../src/clip_path/beveled_path_provider.dart)：先构造 `RRect`，再计算 8 个顶点，使用 `Path.addPolygon(vertices, true)` 得到斜切角多边形。
- `NeumorphicBoxShape.path(provider)` -> 任意自定义 `NeumorphicPathProvider`：调用者提供 `getPath(size)` 和 `oneGradientPerPath`。
- [../src/clip_path/custom_path/flutter_logo_path_provider.dart](../src/clip_path/custom_path/flutter_logo_path_provider.dart)：内置自定义示例，按 `size.width / 166` 与 `size.height / 202` 缩放硬编码坐标，并用多次 `moveTo` 和 `lineTo` 生成 Flutter logo 路径。

### 容器裁剪与装饰绘制模块
- [../src/widget/container.dart](../src/widget/container.dart) 在 `AnimatedContainer` 中同时设置 `child`、`foregroundDecoration` 和 `decoration`：child 通过 [../src/widget/clipper/neumorphic_box_shape_clipper.dart](../src/widget/clipper/neumorphic_box_shape_clipper.dart) 裁剪；前景/背景装饰通过 `NeumorphicDecoration` 绘制同一个 shape。
- 裁剪发生在 child 层：[../src/widget/clipper/neumorphic_box_shape_clipper.dart](../src/widget/clipper/neumorphic_box_shape_clipper.dart) 返回 `ClipPath(clipper: shape.customShapePathProvider, child: child)`。
- 绘制发生在 decoration 层：[../src/widget/container.dart](../src/widget/container.dart) 同时创建背景 `decoration` 和前景 `foregroundDecoration`，二者都是 `NeumorphicDecoration`。
- [../src/decoration/neumorphic_decorations.dart](../src/decoration/neumorphic_decorations.dart) 根据 `style.depth` 选择 painter：`depth >= 0` 使用 [../src/decoration/neumorphic_emboss_decoration_painter.dart](../src/decoration/neumorphic_emboss_decoration_painter.dart)，`depth < 0` 使用 [../src/decoration/neumorphic_deboss_decoration_painter.dart](../src/decoration/neumorphic_deboss_decoration_painter.dart)。
- painter 在 size 变化时调用 `shape.customShapePathProvider.getPath(size)`，再把这个 path 缓存在 painter cache 中。也就是说：裁剪和绘制使用同一个 path provider，但调用点不同。
- `drawSurfaceAboveChild` 控制凹凸/渐变效果画在 child 上方还是只由背景 decoration 完成：它改变 `foregroundDecoration` 和 `decoration` 的 `drawGradient` 和 `drawShadow` 分工，不改变 path 的生成方式。
- 这个插件的形状机制可以概括为：`PathProvider 生成 Path -> ClipPath 用于裁剪 child -> Decoration painter 用同 Path 画视觉效果`。

### 拟物阴影模块
- 阴影参数来自 [../src/theme/themes.dart](../src/theme/themes.dart)：`NeumorphicThemeData` 和 `NeumorphicStyle` 提供 `depth`、`borderDepth`、`intensity`、`borderIntensity`、`lightSource`、明暗阴影颜色和 `disableDepth`。
- 光源模型来自 [../src/light_source.dart](../src/light_source.dart)：`LightSource` 保存 `dx/dy`，`offset` 用来把深度转换成阴影偏移，`invert()` 用来得到反方向。
- 颜色强度来自 [../src/colors.dart](../src/theme/colors.dart)：`embossWhiteColor`、`embossBlackColor`、`dmbossWhiteColor`、`dmbossBlackColor` 都通过调整 alpha 表达强弱，`intensity` 越大，阴影越不透明。
- 模糊半径来自 [../src/decoration/cache/abstract_neumorphic_painter_cache.dart](../src/decoration/cache/abstract_neumorphic_painter_cache.dart)：`updateStyleDepth` 与 `updateBorderStyleDepth` 会把 depth 的绝对值按控件半径裁剪，再写入 `MaskFilter.blur(BlurStyle.normal, depth)`。
- 偏移计算来自 [../src/decoration/cache/neumorphic_emboss_painter_cache.dart](../src/decoration/cache/neumorphic_emboss_painter_cache.dart) 和 [../src/decoration/cache/neumorphic_deboss_painter_cache.dart](../src/decoration/cache/neumorphic_deboss_painter_cache.dart)：`xDepth = lightSource.dx * depth`，`yDepth = lightSource.dy * depth`，再生成白/黑阴影的平移量和缩放 mask 需要的比例。
- 凸出效果来自 [../src/decoration/neumorphic_emboss_decoration_painter.dart](../src/decoration/neumorphic_emboss_decoration_painter.dart)，它不是只画组件周围的阴影，而是分成“外部投影”和“边缘亮暗”两类视觉信息。
- 凸出外部投影在 `_drawShadow` 中完成：白色 path 沿光源方向偏移，黑色 path 沿反光源方向偏移；两者都用 `saveLayer` 和 `BlendMode.dstOut` mask 抠掉与本体重叠的部分，只留下组件外侧的柔和投影。默认光源是左上，所以左上外缘更亮，右下外侧更暗。
- 凸出边缘亮暗在 `_drawGradient` 的非 `concave/convex` 分支中完成：painter 使用 `borderDepth` 对应的 `_whiteForegroundPaint` 和 `_blackForegroundPaint`，再用按比例放大的 path 作为 mask，把白色和黑色只留在靠近边界的窄区域。这个细窄的明暗边不是组件外部阴影，而是组件“边框/棱边”上的高光和暗部，负责让平面看起来有厚度。
- `drawSurfaceAboveChild` 会影响这些边缘效果的位置：当效果被放到 `foregroundDecoration` 时，边缘高光和暗部会覆盖在 child 上方；当只由背景 decoration 绘制时，child 可能盖住一部分边缘视觉。
- 凹入效果来自 [../src/decoration/neumorphic_deboss_decoration_painter.dart](../src/decoration/neumorphic_deboss_decoration_painter.dart)，同样分为外缘和内部阴影。`_paintBorder` 使用 `borderDepth` 画出洞口边缘的明暗：靠阴影方向的一侧更暗，靠光源方向的一侧更亮，形成“边框被压下去”的边缘感。
- 凹入内部阴影在 `_paintShadows` 中完成：它先画白/黑 path，再把按 cache 比例放大的 path 作为 `dstOut` mask 抠掉中间区域，让明暗留在形状内部边缘。这个效果表现的不是外投影，而是凹槽内壁受光后的内侧高光和内侧暗影。
- `concave` / `convex` 表面来自 [../src/decoration/neumorphic_box_decoration_helper.dart](../src/decoration/neumorphic_box_decoration_helper.dart)：`getGradientShader` 用 light source 到反向 light source 的线性渐变叠在 path 上；`convex` 会使用反向光源，`concave` 使用原光源。它负责整个表面的缓慢明暗变化，和边框上的窄高光/窄暗部是两层不同效果。
- `flat` 表面没有 concave/convex 的整面渐变，因此主要依赖外部投影加 `borderDepth` 相关的前景 mask 来形成边缘亮暗；视觉上更像平整材质从背景中鼓起或压下。
- 可以把拟物视觉拆成三层：第一层是组件外侧投影，表示离开背景或压入背景；第二层是组件边框/棱边上的亮部和暗部，表示厚度和边界；第三层是 `concave/convex` 的表面渐变，表示表面本身的弯曲方向。
- 性能上最重的部分是多次 `saveLayer`、`MaskFilter.blur`、`Path.transform` 和 `BlendMode.dstOut`，不是 path provider 本身。`depth`、`borderDepth` 越大，模糊和 layer 覆盖范围越大；多段 path 会让这些操作按 `subPaths` 重复执行。

### 拟物边框模块
- 这里有两种“边框”概念：`NeumorphicBorder` 是显式线条边框；`borderDepth` / `borderIntensity` 是拟物明暗边框。两者不会叠加：当 `style.border.isEnabled == true` 时，emboss 和 deboss painter 都走 `_drawBorder`，只用 `border.color` 和 `border.width` 沿 path 画一条普通 stroke。
- 当 `NeumorphicBorder` 未启用时，painter 才走拟物边框分支。默认值来自 [../src/theme/themes.dart](../src/theme/themes.dart)：`borderDepth` 默认 `0.8`，`borderIntensity` 默认 `1`；`NeumorphicStyle.copyWithThemeIfNull` 会把组件未指定的边框深度和强度从主题补齐。
- [../src/decoration/cache/abstract_neumorphic_painter_cache.dart](../src/decoration/cache/abstract_neumorphic_painter_cache.dart) 的 `updateBorderStyleDepth` 会把 `borderDepth.abs()` 按控件半径裁剪，并生成 `borderMaskFilter`；`updateBorderShadowColor` 用 `borderIntensity` 调整边框亮色/暗色的 alpha。
- [../src/decoration/cache/neumorphic_emboss_painter_cache.dart](../src/decoration/cache/neumorphic_emboss_painter_cache.dart) 和 [../src/decoration/cache/neumorphic_deboss_painter_cache.dart](../src/decoration/cache/neumorphic_deboss_painter_cache.dart) 的 `updateBorderTranslations` 使用同一套几何公式：`borderXDepth = lightSource.dx * borderDepth`，`borderYDepth = lightSource.dy * borderDepth`，再计算 padding、缩放后的 path 尺寸，以及白/黑 mask 的平移量。
- emboss 模式的拟物边框在 [../src/decoration/neumorphic_emboss_decoration_painter.dart](../src/decoration/neumorphic_emboss_decoration_painter.dart) 的 `_paintBorder` 中实现。它先画完整 path 的白色边缘层和黑色边缘层，再用按 `borderScaleX` / `borderScaleY` 放大的 path 作为 `BlendMode.dstOut` mask 抠掉主体，只留下靠近边缘的一圈亮带和暗带。视觉上这圈明暗边表示凸起表面的棱边厚度。
- deboss 模式的拟物边框在 [../src/decoration/neumorphic_deboss_decoration_painter.dart](../src/decoration/neumorphic_deboss_decoration_painter.dart) 的 `_paintBorder` 中实现。它用 `borderDepthOffset` 分别把黑色和白色 blurred path 朝光源两侧偏移，然后用原 path 作为 `dstOut` mask 抠掉中间，只留下洞口外缘的暗边和亮边。视觉上这圈明暗边表示表面被压下去后形成的外唇。
- deboss 的 `_paintBorder` 和 `_paintShadows` 不是一回事：`_paintBorder` 使用 `borderDepth` 画凹槽口的外缘；`_paintShadows` 使用主 `depth` 和缩放 path mask 画形状内部边缘的内阴影。前者是“边框/洞口”，后者是“凹进去的内壁”。
- `drawSurfaceAboveChild` 主要决定表面渐变在前景还是背景 decoration 绘制；背景和投影只在背景 painter 中画。拟物边框绘制本身存在于 emboss/deboss painter 的元素绘制阶段，因此同一个 shape path 仍然是边框、阴影、背景和 child 裁剪的共同几何来源。

### 拟物阴影与拟物边框对比
- emboss 的拟物阴影和拟物边框方向相似，但留下颜色的位置相反。`_paintShadow` 先把白/黑 path 平移到组件外侧，再用原 path 作为 `dstOut` mask 抠掉本体重叠区域，所以只剩组件外部投影；`_paintBorder` 则先把颜色画在原 path 内，再用放大和平移后的 path 抠掉主体，因此剩下的亮带/暗带只能位于原 shape 内部边缘。
- deboss 的拟物边框和拟物阴影表现的是两个不同结构。`_paintBorder` 先画偏移后的 blurred path，再用原 path 抠掉中间，留下凹槽洞口外唇；`_paintShadows` 先在原 path 内画白/黑颜色，再用放大和平移后的 path 抠掉中间，留下凹槽内壁的内侧高光和内侧暗影。
- emboss 拟物边框之所以能“向内部渐变、外部干净”，关键是第一笔颜色只画在原 path 里：外部从一开始就没有被涂色。后续 `dstOut` mask 只负责从这块内部颜色中挖掉主体区域，`MaskFilter.blur` 让残留边带变软，于是可见颜色从边缘向内部衰减，而不是溢出到外部。
- deboss 拟物阴影之所以也能“向内部渐变、外部干净”，原因类似：`_paintShadows` 的第一笔白/黑颜色画在原 path 内，放大 path 的 `dstOut` mask 抠掉内部大部分区域，只留下靠近内边缘的一圈。因为原始颜色没有画到 path 外，外部背景保持干净。
- `Matrix4` 在这两个“内部边缘”效果里负责生成放大的 mask path。emboss 的 `_paintBorder` 使用 `Matrix4.identity()..scaleByDouble(_cache.borderScaleX, _cache.borderScaleY, 1.0, 1.0)`，deboss 的 `_paintShadows` 使用 `Matrix4.identity()..scaleByDouble(_cache.scaleX, _cache.scaleY, 1.0, 1.0)`，然后都通过 `path.transform(matrix4.storage)` 得到放大后的 path。
- emboss 拟物边框的 `borderScaleX/Y` 来自 `borderDepth`：cache 先根据 `lightSource` 计算 `borderXPadding` / `borderYPadding`，再得到 `borderScaledWidth = width + 2 * borderXPadding`、`borderScaleX = borderScaledWidth / width`。所以 `borderDepth` 越大，放大的 mask path 越大，最终留下的内部边带越宽。
- deboss 拟物阴影的 `scaleX/Y` 来自主 `depth`，不是 `borderDepth`：cache 用 `depth` 算 `xPadding` / `yPadding`，再把原 path 放大成内部阴影 mask。它控制的是凹槽内壁阴影宽度；deboss 的洞口外唇仍由 `_paintBorder` 和 `borderDepthOffset` 控制。
- `Matrix4` 只决定 mask path 放大多少，不决定哪一侧亮、哪一侧暗。方向由后续 `translate(...)` 决定：emboss 拟物边框使用 `borderBlackShadowLeftTranslation` / `borderWhiteShadowLeftTranslation` 等字段移动放大 mask；deboss 拟物阴影使用 `whiteShadowLeftTranslation` / `blackShadowLeftTranslation` 等字段移动放大 mask。缩放负责“挖掉中间”，平移负责“让哪一侧残留下来”。
- 反过来看，真正会画到外部的是 emboss 的 `_paintShadow` 和 deboss 的 `_paintBorder`：前者负责外投影，后者负责凹槽口外唇。它们都通过“先偏移画，再用原 path 抠掉重叠”的方式避免覆盖组件主体。
- 当前小 `borderDepth` 问题来自 emboss 拟物边框这套 mask 几何在亚像素深度下几乎重合：当放大/平移后的 mask 与原 path 差异小于一个逻辑像素时，方向性的内部亮暗带会退化成 path 抗锯齿残差。

## 关键关系
- [../src/neumorphic_box_shape.dart](../src/neumorphic_box_shape.dart) depends_on [../src/clip_path/](../src/clip_path/)：构造函数选择具体 path provider，显式 import，置信度高。
- [../src/clip_path/neumorphic_path_provider.dart](../src/clip_path/neumorphic_path_provider.dart) depends_on Flutter `CustomClipper<Path>`：继承关系，说明 path provider 同时是裁剪器，置信度高。
- [../src/widget/clipper/neumorphic_box_shape_clipper.dart](../src/widget/clipper/neumorphic_box_shape_clipper.dart) depends_on [../src/neumorphic_box_shape.dart](../src/neumorphic_box_shape.dart)：使用 `shape.customShapePathProvider` 作为 `ClipPath` 的 clipper，置信度高。
- [../src/widget/container.dart](../src/widget/container.dart) depends_on [../src/widget/clipper/neumorphic_box_shape_clipper.dart](../src/widget/clipper/neumorphic_box_shape_clipper.dart) 和 [../src/decoration/neumorphic_decorations.dart](../src/decoration/neumorphic_decorations.dart)：同一个 shape 同时进入裁剪和绘制，置信度高。
- [../src/decoration/neumorphic_emboss_decoration_painter.dart](../src/decoration/neumorphic_emboss_decoration_painter.dart) 与 [../src/decoration/neumorphic_deboss_decoration_painter.dart](../src/decoration/neumorphic_deboss_decoration_painter.dart) depends_on path provider 输出：调用 `shape.customShapePathProvider.getPath(size)` 更新缓存，置信度高。
- [../src/decoration/cache/abstract_neumorphic_painter_cache.dart](../src/decoration/cache/abstract_neumorphic_painter_cache.dart) impacts 多段路径绘制：`computeMetrics()` 将 path 拆成 `subPaths`，供 painter 按 path 或整体绘制，置信度高。
- [../src/light_source.dart](../src/light_source.dart) influenced_by [../src/theme/themes.dart](../src/theme/themes.dart)：主题和样式保存光源方向，painter cache 用它计算阴影偏移，置信度高。
- [../src/colors.dart](../src/theme/colors.dart) impacts [../src/decoration/cache/neumorphic_emboss_painter_cache.dart](../src/decoration/cache/neumorphic_emboss_painter_cache.dart) 和 [../src/decoration/cache/neumorphic_deboss_painter_cache.dart](../src/decoration/cache/neumorphic_deboss_painter_cache.dart)：cache 通过颜色工具按 intensity 生成 alpha 阴影色，置信度高。
- [../src/decoration/neumorphic_box_decoration_helper.dart](../src/decoration/neumorphic_box_decoration_helper.dart) impacts concave/convex 表面：提供沿光源方向的线性渐变 shader，置信度高。
- [../src/theme/themes.dart](../src/theme/themes.dart) controls 显式边框与拟物边框分支：`NeumorphicBorder.isEnabled` 为 true 时画普通 stroke，为 false 时由 `borderDepth` / `borderIntensity` 参与明暗边绘制，置信度高。
- [../src/decoration/cache/abstract_neumorphic_painter_cache.dart](../src/decoration/cache/abstract_neumorphic_painter_cache.dart) impacts 拟物边框厚度、模糊和颜色强度：`updateBorderStyleDepth` 与 `updateBorderShadowColor` 直接喂给 emboss/deboss 的边框 paint 和 mask，置信度高。
- [../src/decoration/cache/neumorphic_emboss_painter_cache.dart](../src/decoration/cache/neumorphic_emboss_painter_cache.dart) impacts emboss 边框 mask：`updateBorderTranslations` 计算缩放 path 和白/黑 mask 平移量，置信度高。
- [../src/decoration/cache/neumorphic_deboss_painter_cache.dart](../src/decoration/cache/neumorphic_deboss_painter_cache.dart) impacts deboss 边框外唇：`updateBorderTranslations` 和 `updateBorderDepthOffset` 提供偏移、缩放与模糊参数，置信度高。

## 主要流程骨架
- 公共 API 使用流：[../flutter_neumorphic.dart](../flutter_neumorphic.dart) -> [../src/widget/](../src/widget/) / [../src/theme/](../src/theme/) -> 插件使用者代码。
- 应用启动/主题流：[../src/widget/app.dart](../src/widget/app.dart) -> [../src/theme/neumorphic_theme.dart](../src/theme/neumorphic_theme.dart) -> [../src/theme/neumorphic_theme_inherited.dart](../src/theme/neumorphic_theme_inherited.dart) / [../src/theme/theme_wrapper.dart](../src/theme/theme_wrapper.dart) -> 子组件通过 `NeumorphicTheme.currentTheme(context)` 读取主题。
- 容器渲染流：[../src/widget/container.dart](../src/widget/container.dart) -> `NeumorphicStyle.copyWithThemeIfNull` in [../src/theme/themes.dart](../src/theme/themes.dart) -> [../src/decoration/neumorphic_decorations.dart](../src/decoration/neumorphic_decorations.dart) -> emboss/deboss painter -> painter cache -> Flutter `Canvas`。
- 形状路径流：[../src/neumorphic_box_shape.dart](../src/neumorphic_box_shape.dart) -> [../src/clip_path/neumorphic_path_provider.dart](../src/clip_path/neumorphic_path_provider.dart) 子类 -> [../src/widget/clipper/neumorphic_box_shape_clipper.dart](../src/widget/clipper/neumorphic_box_shape_clipper.dart) 裁剪 child，同时 -> decoration painter 绘制阴影/渐变/边框。
- 拟物阴影流：[../src/theme/themes.dart](../src/theme/themes.dart) style/theme 参数 -> [../src/light_source.dart](../src/light_source.dart) 光源偏移 -> painter cache 计算颜色、模糊、平移和缩放 -> emboss/deboss painter 用 `saveLayer`、mask 和 path 绘制明暗边。
- 显式边框流：`NeumorphicStyle.border.isEnabled=true` -> emboss/deboss painter 的 `_drawBorder` -> 沿同一个 path 使用 `border.color` / `border.width` 画普通线条。
- emboss 拟物边框流：非负 `depth` 且显式边框关闭 -> `borderDepth` / `borderIntensity` -> emboss cache 计算边框缩放和 mask 平移 -> `_paintBorder` 用白/黑 path 与放大 path 的 `dstOut` mask 留出凸起边缘明暗。
- deboss 拟物边框流：负 `depth` 且显式边框关闭 -> `borderDepth` / `borderIntensity` -> deboss cache 计算 `borderDepthOffset` 和边框颜色 -> `_paintBorder` 用偏移 blurred path 与原 path 的 `dstOut` mask 留出凹陷洞口外唇。
- 交互控件流：[../src/widget/button.dart](../src/widget/button.dart) / slider / switch / toggle -> 手势或动画状态 -> [../src/widget/container.dart](../src/widget/container.dart) depth/style 变化 -> decoration lerp 和 repaint。

## 高耦合枢纽文件
- [../flutter_neumorphic.dart](../flutter_neumorphic.dart)：导出所有公共组件，任何 API 暴露调整都会影响外部使用者。
- [../src/theme/themes.dart](../src/theme/themes.dart)：定义 `NeumorphicThemeData`、`NeumorphicStyle`、默认主题与样式插值，是视觉参数中心。
- [../src/widget/container.dart](../src/widget/container.dart)：绝大多数视觉控件的底层构件，影响渲染、裁剪和动画行为。
- [../src/neumorphic_box_shape.dart](../src/neumorphic_box_shape.dart)：shape 选择和 lerp 的中心，影响裁剪和绘制路径一致性。
- [../src/clip_path/neumorphic_path_provider.dart](../src/clip_path/neumorphic_path_provider.dart)：路径协议中心，同时约束裁剪和绘制。
- [../src/decoration/neumorphic_decorations.dart](../src/decoration/neumorphic_decorations.dart)：emboss/deboss painter 分发点，影响所有容器装饰绘制。
- [../src/decoration/cache/abstract_neumorphic_painter_cache.dart](../src/decoration/cache/abstract_neumorphic_painter_cache.dart)：阴影、路径和尺寸缓存基类，影响绘制性能与正确性。

## 推荐阅读顺序
- [../flutter_neumorphic.dart](../flutter_neumorphic.dart)：先看插件对外暴露了哪些 API。
- [../src/neumorphic_box_shape.dart](../src/neumorphic_box_shape.dart)：理解形状 API 如何选择 path provider。
- [../src/clip_path/neumorphic_path_provider.dart](../src/clip_path/neumorphic_path_provider.dart)：理解 path provider 为什么既能生成 path 又能作为 clipper。
- [../src/clip_path/rect_path_provider.dart](../src/clip_path/rect_path_provider.dart)、[../src/clip_path/circle_path_provider.dart](../src/clip_path/circle_path_provider.dart)、[../src/clip_path/rrect_path_provider.dart](../src/clip_path/rrect_path_provider.dart)、[../src/clip_path/beveled_path_provider.dart](../src/clip_path/beveled_path_provider.dart)：理解内置形状的 path 生成细节。
- [../src/widget/container.dart](../src/widget/container.dart)：理解同一个 shape 如何进入 child 裁剪和 decoration 绘制。
- [../src/decoration/neumorphic_decorations.dart](../src/decoration/neumorphic_decorations.dart)：理解 depth 正负如何选择凸出/凹入绘制。
- [../src/light_source.dart](../src/light_source.dart) 与 [../src/colors.dart](../src/theme/colors.dart)：理解阴影方向与强度的基础模型。
- [../src/decoration/cache/neumorphic_emboss_painter_cache.dart](../src/decoration/cache/neumorphic_emboss_painter_cache.dart) 与 [../src/decoration/cache/neumorphic_deboss_painter_cache.dart](../src/decoration/cache/neumorphic_deboss_painter_cache.dart)：理解 depth 如何变成偏移、缩放和模糊。
- [../src/decoration/neumorphic_emboss_decoration_painter.dart](../src/decoration/neumorphic_emboss_decoration_painter.dart) 与 [../src/decoration/neumorphic_deboss_decoration_painter.dart](../src/decoration/neumorphic_deboss_decoration_painter.dart)：理解 Canvas 如何使用 path 绘制效果。
- [../src/theme/themes.dart](../src/theme/themes.dart) 的 `NeumorphicBorder`、`borderDepth`、`borderIntensity`：理解普通 stroke 边框与拟物明暗边框的开关关系。

## 风险与未知
- 只读取了 [../](../) 下的 `lib` 范围：插件名称、依赖版本、示例工程和测试覆盖没有纳入判断；需要读取仓库根目录配置才能确认包元数据和外部使用方式。
- 部分源码注释存在编码异常：行为判断基于代码本身，注释语义置信度低。
- `StadiumPathProvider` 通过超大圆角 RRect 间接得到 stadium path；最终半径约束由 Flutter 的 RRect/path 实现处理，这一点从本库源码只能确认意图，具体归一化细节属于 Flutter 框架实现。
