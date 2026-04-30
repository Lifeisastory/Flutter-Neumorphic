# Architecture Index

## Artifact Metadata
- Artifact: architecture-index
- Language: English
- Source: generated-from-lib-scan
- Scan scope: `lib/` only

## Project Type
- Inference: Flutter UI plugin / widget library
- Evidence: `lib/flutter_neumorphic.dart` declares a library and exports widget, theme, shape, and decoration APIs; `lib/src/widget/app.dart` wraps Flutter `MaterialApp`; source files import Flutter `material` and `widgets`.
- Confidence: high

## Entrypoints
- `lib/flutter_neumorphic.dart` | public API export hub | `library flutter_neumorphic` plus explicit exports | high
- `lib/src/widget/app.dart` | application wrapper entrypoint | `NeumorphicApp` builds `NeumorphicTheme`, `IconTheme`, and `MaterialApp` | high
- `lib/src/theme/neumorphic_theme.dart` | theme provider entrypoint | `NeumorphicTheme` exposes static theme lookup/update methods and builds `NeumorphicThemeInherited` | high
- `lib/src/widget/container.dart` | rendering entrypoint for neumorphic surfaces | `NeumorphicContainer` resolves theme/style and builds `NeumorphicDecoration` | high

## Modules
- `lib/flutter_neumorphic.dart` | public API facade | explicit export list | high
- `lib/src/theme/` | theme and style model layer | classes `NeumorphicThemeData`, `NeumorphicStyle`, `NeumorphicTheme`, `ThemeWrapper`, app bar theme | high
- `lib/src/widget/` | public widget kit | files define app, app bar, background, button, inputs, sliders, text, icons, progress, and container widgets | high
- `lib/src/decoration/` | decoration and canvas painting layer | `NeumorphicDecoration`, emboss/deboss painters, text painters | high
- `lib/src/decoration/cache/` | painter cache layer | cache classes store size, path, shadow colors, offsets, masks, and subpaths | high
- `lib/src/clip_path/` | path provider and clipping layer | `NeumorphicPathProvider` subclasses produce Flutter `Path` objects | high
- `lib/src/widget/animation/` | local widget animation helpers | `AnimatedScale` used by button and switch | high
- `lib/src/widget/clipper/` | widget clipping helper | `NeumorphicBoxShapeClipper` applies `NeumorphicBoxShape` to children | high
- `lib/src/colors.dart`, `lib/src/light_source.dart`, `lib/src/surface_type.dart`, `lib/src/neumorphic_icons.dart` | design tokens and primitives | constants, enum, direction model, icon data | high

## Files
- `lib/flutter_neumorphic.dart` | public export hub | exports most public source files | high
- `lib/src/colors.dart` | default color constants | class `NeumorphicColors` | high
- `lib/src/light_source.dart` | light source model | class `LightSource` | high
- `lib/src/surface_type.dart` | surface shape enum | enum `NeumorphicSurfaceType` | high
- `lib/src/neumorphic_box_shape.dart` | shape facade over path providers | constructors select path provider implementations and provide shape lerp | high
- `lib/src/neumorphic_icons.dart` | bundled icon constants | class `NeumorphicIcons` | high
- `lib/src/clip_path/neumorphic_path_provider.dart` | abstract path provider contract | extends `CustomClipper<Path>` and exposes `getPath` / `oneGradientPerPath` | high
- `lib/src/clip_path/beveled_path_provider.dart` | beveled path implementation | extends `NeumorphicPathProvider` | high
- `lib/src/clip_path/circle_path_provider.dart` | circle path implementation | extends `NeumorphicPathProvider` | high
- `lib/src/clip_path/rect_path_provider.dart` | rectangle path implementation | extends `NeumorphicPathProvider` | high
- `lib/src/clip_path/rrect_path_provider.dart` | rounded rectangle path implementation | extends `NeumorphicPathProvider` | high
- `lib/src/clip_path/stadium_path_provider.dart` | stadium path implementation | extends `RRectPathProvider` | high
- `lib/src/clip_path/custom_path/flutter_logo_path_provider.dart` | custom Flutter logo path implementation | extends `NeumorphicPathProvider` | high
- `lib/src/decoration/neumorphic_decorations.dart` | decoration dispatcher | creates emboss painter for non-negative depth and deboss painter for negative depth | high
- `lib/src/decoration/neumorphic_emboss_decoration_painter.dart` | raised/emboss canvas painter | draws background, shadows, gradients, and borders from cached path/style data | high
- `lib/src/decoration/neumorphic_deboss_decoration_painter.dart` | inset/deboss canvas painter | draws inner/outer shadow effects from cached path/style data | high
- `lib/src/decoration/neumorphic_box_decoration_helper.dart` | gradient helper | imported by emboss painter and text emboss painter | high
- `lib/src/decoration/neumorphic_text_decorations.dart` | text decoration dispatcher | creates text emboss/deboss painters | high
- `lib/src/decoration/neumorphic_text_emboss_decoration_painter.dart` | raised text painter | class names and imports indicate text emboss painting | medium
- `lib/src/decoration/neumorphic_text_deboss_decoration_painter.dart` | inset text painter | class names and imports indicate text deboss painting | medium
- `lib/src/decoration/cache/abstract_neumorphic_painter_cache.dart` | painter cache base | stores size, path, subpaths, depth offsets, mask filters, and shadow colors | high
- `lib/src/decoration/cache/neumorphic_emboss_painter_cache.dart` | emboss cache implementation | extends abstract cache | high
- `lib/src/decoration/cache/neumorphic_deboss_painter_cache.dart` | deboss cache implementation | extends abstract cache | high
- `lib/src/theme/themes.dart` | theme/style data hub | defines `NeumorphicThemeData`, `NeumorphicStyle`, `NeumorphicBorder`, default themes | high
- `lib/src/theme/neumorphic_theme.dart` | theme provider widget | builds inherited provider and exposes static lookup helpers | high
- `lib/src/theme/neumorphic_theme_inherited.dart` | inherited theme state bridge | updates `ThemeWrapper` through callback | high
- `lib/src/theme/theme_wrapper.dart` | current light/dark theme resolver | uses `ThemeMode` and platform brightness | high
- `lib/src/theme/app_bar.dart` | app bar theme data | class names define app bar theme and icons | high
- `lib/src/widget/app.dart` | app-level wrapper | wraps `MaterialApp` in `NeumorphicTheme` and `IconTheme` | high
- `lib/src/widget/container.dart` | base neumorphic visual container | builds animated container, clipper, foreground/background decorations | high
- `lib/src/widget/button.dart` | interactive pressable container | handles gesture depth animation and haptic feedback | high
- `lib/src/widget/app_bar.dart` | neumorphic app bar widget | class names and app bar theme imports | high
- `lib/src/widget/background.dart` | themed background widget | imports theme and defines `NeumorphicBackground` | high
- `lib/src/widget/back_button.dart` | back button wrapper | imports public API and defines `NeumorphicBackButton` | high
- `lib/src/widget/close_button.dart` | close button wrapper | imports public API and defines `NeumorphicCloseButton` | high
- `lib/src/widget/floating_action_button.dart` | floating action button wrapper | defines `NeumorphicFloatingActionButton` | high
- `lib/src/widget/icon.dart` | icon rendering widget | exports decoration, shape, and theme APIs | high
- `lib/src/widget/text.dart` | neumorphic text widget | depends on text decoration layer | high
- `lib/src/widget/checkbox.dart` | checkbox control | imports icons, container, and button | high
- `lib/src/widget/radio.dart` | radio control | imports button and container | high
- `lib/src/widget/switch.dart` | switch control | imports public API and animated scale | high
- `lib/src/widget/toggle.dart` | segmented toggle control | imports public API | high
- `lib/src/widget/slider.dart` | single value slider | imports public API | high
- `lib/src/widget/range_slider.dart` | range slider | imports public API | high
- `lib/src/widget/indicator.dart` | value indicator | imports container | high
- `lib/src/widget/progress.dart` | determinate and indeterminate progress | imports container | high
- `lib/src/widget/animation/animated_scale.dart` | scale animation widget | class `AnimatedScale` | high
- `lib/src/widget/clipper/neumorphic_box_shape_clipper.dart` | shape clipper widget | imports `NeumorphicBoxShape` | high

## Shape Path Details
- `lib/src/neumorphic_box_shape.dart` | shape facade | stores one `customShapePathProvider` and constructors select concrete `NeumorphicPathProvider` implementations | code-confirmed | high
- `lib/src/clip_path/neumorphic_path_provider.dart` | shared path/clipper protocol | extends `CustomClipper<Path>`; `getClip(size)` returns `getPath(size)`; implementers also expose `oneGradientPerPath` | code-confirmed | high
- `lib/src/clip_path/rect_path_provider.dart` | rectangle path | `Path.addRect(Rect.fromLTWH(0, 0, size.width, size.height))`; `oneGradientPerPath=false` | code-confirmed | high
- `lib/src/clip_path/circle_path_provider.dart` | centered max circle path | `Path.addOval(Rect.fromCircle(center: midpoint, radius: min(width/2, height/2)))`; `oneGradientPerPath=false` | code-confirmed | high
- `lib/src/clip_path/rrect_path_provider.dart` | rounded rectangle path | `RRect.fromLTRBAndCorners(...)` from stored `BorderRadius`, then `Path.addRRect(...)`; `oneGradientPerPath=false` | code-confirmed | high
- `lib/src/clip_path/stadium_path_provider.dart` | stadium/capsule path | subclasses `RRectPathProvider` with `BorderRadius.all(Radius.circular(1000))`; final radius normalization is handled by Flutter path/RRect behavior | code-confirmed with Flutter-framework detail inferred | medium
- `lib/src/clip_path/beveled_path_provider.dart` | beveled polygon path | builds an `RRect`, computes eight corner vertices, then calls `Path.addPolygon(vertices, true)`; `oneGradientPerPath=false` | code-confirmed | high
- `lib/src/clip_path/custom_path/flutter_logo_path_provider.dart` | multi-subpath custom logo path | scales hard-coded 166x202 coordinates to widget size and emits `moveTo/lineTo`; `oneGradientPerPath=true` | code-confirmed | high
- `lib/src/widget/clipper/neumorphic_box_shape_clipper.dart` | child clipping use of shape path | passes `shape.customShapePathProvider` directly to `ClipPath.clipper` | code-confirmed | high
- `lib/src/widget/container.dart` | combined clipping and decoration use | wraps child in `NeumorphicBoxShapeClipper` and creates both foreground/background `NeumorphicDecoration` with the same `shape` | code-confirmed | high
- `lib/src/decoration/cache/abstract_neumorphic_painter_cache.dart` | painter path cache and subpath splitting | `updatePath(newPath)` stores the full path and extracts `subPaths` through `computeMetrics()` | code-confirmed | high

## Neumorphic Shadow Details
- `lib/src/theme/themes.dart` | shadow parameter source | `NeumorphicThemeData` and `NeumorphicStyle` provide `depth`, `borderDepth`, `intensity`, `borderIntensity`, `lightSource`, shadow colors, and `disableDepth` | code-confirmed | high
- `lib/src/light_source.dart` | light direction vector | stores `dx/dy`, exposes `offset`, `toOffset(distance)`, `invert()`, and lerp support | code-confirmed | high
- `lib/src/colors.dart` | shadow alpha generation | emboss/deboss shadow color helpers call `_applyPercentageOnOpacity`, so intensity changes alpha rather than geometry | code-confirmed | high
- `lib/src/decoration/cache/abstract_neumorphic_painter_cache.dart` | depth-to-blur cache | `updateStyleDepth` and `updateBorderStyleDepth` clamp absolute depth by widget radius and set `MaskFilter.blur(BlurStyle.normal, depth)` | code-confirmed | high
- `lib/src/decoration/cache/neumorphic_emboss_painter_cache.dart` | raised shadow translation cache | computes `xDepth/yDepth`, white/black shadow translations, scaled sizes, and border translations from `lightSource` and depth | code-confirmed | high
- `lib/src/decoration/cache/neumorphic_deboss_painter_cache.dart` | inset shadow translation cache | computes the same translation and scale fields for deboss/inset painting | code-confirmed | high
- `lib/src/decoration/neumorphic_emboss_decoration_painter.dart` | raised shadow painter | `_drawShadow` uses two `saveLayer` passes: light path translated with the light source and dark path translated opposite the light source, each clipped by `BlendMode.dstOut` masks | code-confirmed | high
- `lib/src/decoration/neumorphic_deboss_decoration_painter.dart` | inset shadow painter | `_paintBorder` draws border outer edges; `_paintShadows` draws light/dark paths and masks them with scaled transformed paths to leave inner shadows | code-confirmed | high
- `lib/src/decoration/neumorphic_box_decoration_helper.dart` | concave/convex surface gradient | `getGradientShader` creates a linear gradient from light source to inverted light source; emboss painter uses original source for concave and inverted source for convex | code-confirmed | high
- `lib/src/decoration/neumorphic_emboss_decoration_painter.dart` | flat surface foreground bevel | for non-concave/non-convex surfaces, `_drawGradient` uses border foreground paints and scaled masks instead of a whole-surface gradient | code-confirmed | high
- `lib/src/decoration/neumorphic_emboss_decoration_painter.dart` | raised edge highlight/shade | non-concave/non-convex `_drawGradient` uses `_whiteForegroundPaint` and `_blackForegroundPaint` with scaled `dstOut` masks, leaving narrow light/dark bands near the shape edge; this is edge bevel lighting, not the outer drop shadow | code-confirmed | high
- `lib/src/decoration/neumorphic_deboss_decoration_painter.dart` | inset edge highlight/shade | `_paintBorder` uses border depth and dstOut masks to draw the lip of the inset shape, while `_paintShadows` leaves light/dark bands on the inner wall | code-confirmed | high
- conceptual shadow layers | neumorphic visual model | visual result is composed from outer cast shadow, narrow edge highlight/shade, and optional concave/convex whole-surface gradient | code-confirmed | high
- performance characteristic | shadow cost driver | repeated `saveLayer`, `MaskFilter.blur`, `Path.transform`, `BlendMode.dstOut`, and per-subpath loops dominate cost more than path-provider lookup | code-confirmed | medium

## Neumorphic Border Details
- `lib/src/theme/themes.dart` | border parameter source | `NeumorphicThemeData` defaults `borderDepth` to `0.8` and `borderIntensity` to `1`; `NeumorphicStyle.copyWithThemeIfNull` fills missing style values from theme | code-confirmed | high
- `lib/src/theme/themes.dart` | explicit border switch | `NeumorphicBorder.isEnabled=true` makes both emboss and deboss painters draw a simple stroked path using `border.color` and `border.width`; this bypasses the neumorphic light/dark border pass | code-confirmed | high
- `lib/src/decoration/cache/abstract_neumorphic_painter_cache.dart` | border depth cache | `updateBorderStyleDepth` clamps absolute `borderDepth` by widget radius and creates `borderMaskFilter`; `updateBorderShadowColor` applies `borderIntensity` to the selected light/dark border colors | code-confirmed | high
- `lib/src/decoration/cache/neumorphic_emboss_painter_cache.dart` | emboss border geometry | `updateBorderTranslations` converts `borderDepth` and `lightSource` into `borderXDepth`, `borderYDepth`, padding, scaled path size, and white/black mask translations | code-confirmed | high
- `lib/src/decoration/cache/neumorphic_deboss_painter_cache.dart` | deboss border geometry | uses the same `borderDepth` translation and scale formulas as emboss; deboss additionally uses `borderDepthOffset` for the outer lip pass | code-confirmed | high
- `lib/src/decoration/neumorphic_emboss_decoration_painter.dart` | raised neumorphic border | when explicit `NeumorphicBorder` is disabled, `_paintBorder` draws light and dark border paints, then subtracts a scaled/transformed path with `BlendMode.dstOut`; the remaining narrow bands form raised edge highlight/shade | code-confirmed | high
- `lib/src/decoration/neumorphic_deboss_decoration_painter.dart` | inset neumorphic border | when explicit `NeumorphicBorder` is disabled, `_paintBorder` draws two offset blurred paths and subtracts the original path, leaving a light/dark lip around the inset opening | code-confirmed | high
- `lib/src/decoration/neumorphic_deboss_decoration_painter.dart` | inset inner wall distinction | deboss `_paintShadows` is separate from `_paintBorder`: it uses `depth` and scaled masks to leave shadows inside the shape, while `_paintBorder` uses `borderDepth` for the outer rim | code-confirmed | high
- `lib/src/decoration/neumorphic_decorations.dart` | foreground/background split | border painting happens in both foreground and background `NeumorphicDecoration` painters; shadow and background are restricted to background, while `drawSurfaceAboveChild` mainly changes which painter draws the surface gradient | code-confirmed | high

## Shadow Border Comparison
- emboss shadow vs emboss border | outside vs inside | emboss `_paintShadow` starts from translated light/dark paths and subtracts the original path, so the remaining blur is outside the component; emboss `_paintBorder` starts by painting the original path itself and subtracts a scaled/translated path, so the remaining light/dark bands can only stay inside the original shape | code-confirmed | high
- deboss border vs deboss shadow | outer lip vs inner wall | deboss `_paintBorder` starts from offset blurred paths and subtracts the original path, leaving the lip around the opening; deboss `_paintShadows` starts from the original path and subtracts scaled/translated paths, leaving bands on the inner wall | code-confirmed | high
- clean outside mechanism | paint extent controls residue | for emboss border and deboss inner shadow, the first draw is clipped to the original path before the `dstOut` mask is applied; because no light/dark paint is initially deposited outside that path, the exterior remains clean even though the mask is larger or translated | code-confirmed | high
- inward gradient mechanism | blur plus subtractive masking | `MaskFilter.blur` softens the painted band or mask edge, while `BlendMode.dstOut` removes the central overlap; the surviving pixels fade from the edge toward the interior rather than spilling outward | code-confirmed | high
- `Matrix4` role in inner-edge masks | scaled mask path generator | emboss `_paintBorder` builds `Matrix4.identity()..scaleByDouble(borderScaleX, borderScaleY, 1.0, 1.0)` and deboss `_paintShadows` builds `Matrix4.identity()..scaleByDouble(scaleX, scaleY, 1.0, 1.0)`; `path.transform(matrix4.storage)` creates the enlarged mask path that subtracts the center and leaves an inner edge band | code-confirmed | high
- scale source for emboss border | border-depth geometry | emboss border `borderScaleX/Y` come from `borderScaledWidth/Height = size + 2 * borderPadding`, where border padding is derived from `borderDepth` and `lightSource`; larger `borderDepth` enlarges the mask more and leaves a wider border band | code-confirmed | high
- scale source for deboss inner shadow | depth geometry | deboss inner shadow `scaleX/Y` come from `scaledWidth/Height = size + 2 * padding`, where padding is derived from main `depth` and `lightSource`; this controls the width of the recessed inner-wall shadow, not the outer lip | code-confirmed | high
- translation role with scaled masks | directional placement | the `Matrix4` scale is anchored at the path coordinate origin, so the painters also translate the enlarged mask with white/black shadow translation fields; scaling decides mask size, translation decides which side survives as highlight or shadow | code-confirmed | high
- implementation risk | subpixel border depth | when `borderDepth` is much smaller than one logical pixel, emboss border masking becomes almost coincident with the original path; the intended directional inner bands can collapse into anti-aliased edge residue | code-confirmed with rendering inference | medium

## Relationships
- `lib/flutter_neumorphic.dart` | depends_on | `lib/src/colors.dart` and exported public files | explicit | export statements | high
- `lib/src/widget/app.dart` | depends_on | `lib/src/theme/neumorphic_theme.dart` | explicit | imports public API and instantiates `NeumorphicTheme` | high
- `lib/src/widget/app.dart` | impacts | app startup/theme flow | explicit | `build` wraps `MaterialApp` | high
- `lib/src/theme/neumorphic_theme.dart` | depends_on | `lib/src/theme/neumorphic_theme_inherited.dart` | explicit | exported and instantiated as `NeumorphicThemeInherited` | high
- `lib/src/theme/neumorphic_theme.dart` | depends_on | `lib/src/theme/theme_wrapper.dart` | explicit | `_themeHost = ThemeWrapper(...)` | high
- `lib/src/theme/neumorphic_theme.dart` | impacts | all theme-consuming widgets | inferred | widgets call `NeumorphicTheme.currentTheme(context)` | high
- `lib/src/theme/themes.dart` | depends_on | `lib/src/colors.dart` | explicit | exported through themes and used as `NeumorphicColors.*` | high
- `lib/src/theme/themes.dart` | depends_on | `lib/src/light_source.dart` | explicit | exported through themes and used by `LightSource` fields | high
- `lib/src/theme/themes.dart` | depends_on | `lib/src/surface_type.dart` | explicit | default shape uses `NeumorphicSurfaceType.flat` | high
- `lib/src/theme/themes.dart` | influenced_by | `lib/src/widget/container.dart` | explicit | references `NeumorphicContainer.MIN_DEPTH` and related constants through public API | high
- `lib/src/widget/container.dart` | depends_on | `lib/src/theme/neumorphic_theme.dart` | explicit | imports and calls `NeumorphicTheme.currentTheme` | high
- `lib/src/widget/container.dart` | depends_on | `lib/src/decoration/neumorphic_decorations.dart` | explicit | creates foreground/background `NeumorphicDecoration` | high
- `lib/src/widget/container.dart` | depends_on | `lib/src/neumorphic_box_shape.dart` | explicit | resolves `NeumorphicBoxShape` and passes shape to clipper/decoration | high
- `lib/src/widget/container.dart` | impacts | most widget-kit controls | inferred | controls import and compose `NeumorphicContainer` | high
- `lib/src/decoration/neumorphic_decorations.dart` | depends_on | `lib/src/decoration/neumorphic_emboss_decoration_painter.dart` | explicit | creates painter when depth is non-negative | high
- `lib/src/decoration/neumorphic_decorations.dart` | depends_on | `lib/src/decoration/neumorphic_deboss_decoration_painter.dart` | explicit | creates painter when depth is negative | high
- `lib/src/decoration/neumorphic_decorations.dart` | impacts | container render path | explicit | `NeumorphicContainer` creates this decoration | high
- `lib/src/decoration/neumorphic_emboss_decoration_painter.dart` | depends_on | `lib/src/decoration/cache/neumorphic_emboss_painter_cache.dart` | explicit | cache field and import | high
- `lib/src/decoration/neumorphic_deboss_decoration_painter.dart` | depends_on | `lib/src/decoration/cache/neumorphic_deboss_painter_cache.dart` | explicit | cache field and import | high
- `lib/src/decoration/cache/abstract_neumorphic_painter_cache.dart` | depends_on | `lib/src/light_source.dart` | explicit | imported public API and `LightSource` fields | high
- `lib/src/neumorphic_box_shape.dart` | depends_on | `lib/src/clip_path/*_path_provider.dart` | explicit | constructors instantiate provider classes | high
- `lib/src/clip_path/*_path_provider.dart` | depends_on | `lib/src/clip_path/neumorphic_path_provider.dart` | explicit | provider classes extend abstract provider | high
- `lib/src/widget/button.dart` | depends_on | `lib/src/widget/container.dart` | explicit | builds `NeumorphicContainer` | high
- `lib/src/widget/button.dart` | depends_on | `lib/src/widget/animation/animated_scale.dart` | explicit | wraps child in `AnimatedScale` | high
- `lib/src/widget/checkbox.dart` | depends_on | `lib/src/widget/button.dart` | explicit | import `button.dart` | high
- `lib/src/widget/checkbox.dart` | depends_on | `lib/src/widget/container.dart` | explicit | imports container | high
- `lib/src/widget/radio.dart` | depends_on | `lib/src/widget/button.dart` | explicit | imports button | high
- `lib/src/widget/radio.dart` | depends_on | `lib/src/widget/container.dart` | explicit | imports container | high
- `lib/src/widget/text.dart` | depends_on | `lib/src/decoration/neumorphic_text_decorations.dart` | explicit | import | high
- `lib/src/widget/clipper/neumorphic_box_shape_clipper.dart` | depends_on | `lib/src/clip_path/neumorphic_path_provider.dart` | explicit | `shape.customShapePathProvider` is passed to Flutter `ClipPath` as a `CustomClipper<Path>` | high
- `lib/src/decoration/neumorphic_emboss_decoration_painter.dart` | depends_on | `lib/src/clip_path/neumorphic_path_provider.dart` | explicit | calls `shape.customShapePathProvider.getPath(configuration.size!)` before cache update | high
- `lib/src/decoration/neumorphic_deboss_decoration_painter.dart` | depends_on | `lib/src/clip_path/neumorphic_path_provider.dart` | explicit | calls `shape.customShapePathProvider.getPath(configuration.size!)` before cache update | high
- `lib/src/decoration/cache/abstract_neumorphic_painter_cache.dart` | impacts | multi-subpath gradient/painting behavior | explicit | `updatePath` computes `subPaths` from `Path.computeMetrics()` | high
- `lib/src/clip_path/custom_path/flutter_logo_path_provider.dart` | influences | concave/convex gradient splitting | explicit | `oneGradientPerPath=true`; `NeumorphicContainer` forwards this as `renderingByPath` | high
- `lib/src/theme/themes.dart` | influenced_by | `lib/src/light_source.dart` | explicit | `NeumorphicThemeData` and `NeumorphicStyle` store `LightSource` values | high
- `lib/src/decoration/cache/abstract_neumorphic_painter_cache.dart` | depends_on | `lib/src/light_source.dart` | explicit | cache computes `depthOffset` from `lightSource.offset` | high
- `lib/src/decoration/cache/neumorphic_emboss_painter_cache.dart` | depends_on | `lib/src/colors.dart` | explicit | delegates shadow color generation to `NeumorphicColors.emboss*` helpers | high
- `lib/src/decoration/cache/neumorphic_deboss_painter_cache.dart` | depends_on | `lib/src/colors.dart` | explicit | delegates shadow color generation to `NeumorphicColors.dmboss*` helpers | high
- `lib/src/decoration/neumorphic_emboss_decoration_painter.dart` | depends_on | `lib/src/decoration/neumorphic_box_decoration_helper.dart` | explicit | uses `getGradientShader` for concave/convex surfaces | high
- `lib/src/decoration/neumorphic_emboss_decoration_painter.dart` | impacts | raised shadow rendering | explicit | draws light and dark external shadows with translated paths and dstOut masks | high
- `lib/src/decoration/neumorphic_deboss_decoration_painter.dart` | impacts | inset shadow rendering | explicit | draws outer edges and inner shadows with scaled path masks | high
- `lib/src/theme/themes.dart` | controls | neumorphic-vs-explicit border rendering | explicit | `NeumorphicBorder.isEnabled` selects direct stroke drawing; disabled border lets `borderDepth`/`borderIntensity` drive light/dark edge rendering | high
- `lib/src/decoration/cache/abstract_neumorphic_painter_cache.dart` | impacts | emboss/deboss border thickness and blur | explicit | `updateBorderStyleDepth` and `updateBorderShadowColor` feed painter border paints and masks | high
- `lib/src/decoration/cache/neumorphic_emboss_painter_cache.dart` | impacts | raised border mask transforms | explicit | `updateBorderTranslations` computes border scaled path and translations used by emboss `_paintBorder` | high
- `lib/src/decoration/cache/neumorphic_deboss_painter_cache.dart` | impacts | inset border lip transforms | explicit | `updateBorderTranslations` and `updateBorderDepthOffset` feed deboss `_paintBorder` | high

## Flows
- public API usage | `lib/flutter_neumorphic.dart` -> exported `lib/src/theme/*` and `lib/src/widget/*` -> consuming Flutter app | high
- application startup theme flow | `lib/src/widget/app.dart` -> `lib/src/theme/neumorphic_theme.dart` -> `lib/src/theme/neumorphic_theme_inherited.dart` -> child widgets calling `NeumorphicTheme.currentTheme(context)` | high
- container render flow | `lib/src/widget/container.dart` -> `lib/src/theme/themes.dart` style resolution -> `lib/src/decoration/neumorphic_decorations.dart` -> emboss/deboss painter -> painter cache -> Flutter `Canvas` | high
- shape clipping flow | `lib/src/neumorphic_box_shape.dart` -> `lib/src/clip_path/neumorphic_path_provider.dart` subclasses -> `lib/src/widget/clipper/neumorphic_box_shape_clipper.dart` and painters | high
- interaction control flow | `lib/src/widget/button.dart` / sliders / switch / toggle -> gesture or animation state -> `lib/src/widget/container.dart` depth/style changes -> decoration lerp/repaint | medium
- text render flow | `lib/src/widget/text.dart` -> `lib/src/decoration/neumorphic_text_decorations.dart` -> text emboss/deboss painters | high
- shape path generation and use | `lib/src/neumorphic_box_shape.dart` -> selected `lib/src/clip_path/*_path_provider.dart` -> `getPath(size)` / `getClip(size)` -> `lib/src/widget/clipper/neumorphic_box_shape_clipper.dart` clips child and decoration painters draw with the same generated path | high
- custom multi-path rendering | custom `NeumorphicPathProvider` with `oneGradientPerPath=true` -> `lib/src/widget/container.dart` sets `renderingByPath` -> painter cache extracts `subPaths` -> emboss painter can draw gradients per subpath | high
- raised neumorphic shadow flow | `lib/src/theme/themes.dart` style values -> `lib/src/light_source.dart` direction -> `lib/src/decoration/cache/neumorphic_emboss_painter_cache.dart` blur/offset/color cache -> `lib/src/decoration/neumorphic_emboss_decoration_painter.dart` two saveLayer dstOut shadow passes | high
- inset neumorphic shadow flow | negative depth in `lib/src/decoration/neumorphic_decorations.dart` -> `lib/src/decoration/cache/neumorphic_deboss_painter_cache.dart` blur/offset/color cache -> `lib/src/decoration/neumorphic_deboss_decoration_painter.dart` outer edge plus scaled-path inner masks | high
- concave/convex surface flow | `NeumorphicSurfaceType.concave/convex` -> `lib/src/decoration/neumorphic_box_decoration_helper.dart` gradient shader -> `lib/src/decoration/neumorphic_emboss_decoration_painter.dart` path gradient fill | high
- explicit border flow | `NeumorphicStyle.border.isEnabled=true` -> emboss/deboss painter `_drawBorder` -> one stroked path using `border.color` / `border.width` | high
- raised neumorphic border flow | non-negative `depth` plus disabled explicit border -> `borderDepth` / `borderIntensity` theme values -> emboss cache border translations and `borderMaskFilter` -> emboss `_paintBorder` light/dark path passes with scaled `dstOut` masks | high
- inset neumorphic border flow | negative `depth` plus disabled explicit border -> `borderDepth` / `borderIntensity` theme values -> deboss cache `borderDepthOffset` and border colors -> deboss `_paintBorder` offset blurred lip passes with original-path `dstOut` masks | high

## Recommended Next Reads
- `lib/flutter_neumorphic.dart` | public API surface and export policy
- `lib/src/theme/themes.dart` | theme/style schema and default visual tokens
- `lib/src/theme/neumorphic_theme.dart` | theme provider behavior and global theme initialization
- `lib/src/widget/container.dart` | shared visual rendering primitive
- `lib/src/decoration/neumorphic_decorations.dart` | emboss/deboss painter dispatch logic
- `lib/src/decoration/neumorphic_emboss_decoration_painter.dart` | raised surface canvas implementation
- `lib/src/decoration/neumorphic_deboss_decoration_painter.dart` | inset surface canvas implementation
- `lib/src/neumorphic_box_shape.dart` | shape facade and interpolation behavior
- `lib/src/clip_path/neumorphic_path_provider.dart` | shared contract that makes path providers usable for both clipping and painting
- `lib/src/widget/clipper/neumorphic_box_shape_clipper.dart` | direct `ClipPath` integration point for shape paths
- `lib/src/clip_path/beveled_path_provider.dart` | most custom built-in path construction; useful when adding new polygonal shapes
- `lib/src/clip_path/custom_path/flutter_logo_path_provider.dart` | example of a multi-subpath custom provider and `oneGradientPerPath=true`
- `lib/src/light_source.dart` | light direction model for neumorphic shadows
- `lib/src/colors.dart` | shadow alpha/intensity generation
- `lib/src/decoration/cache/neumorphic_emboss_painter_cache.dart` | raised shadow offset and scale calculations
- `lib/src/decoration/cache/neumorphic_deboss_painter_cache.dart` | inset shadow offset and scale calculations
- `lib/src/decoration/neumorphic_box_decoration_helper.dart` | concave/convex gradient shader
- `lib/src/widget/button.dart` | representative interactive widget composition

## Risks And Unknowns
- package metadata | not inspected because scan scope was restricted to `lib/` | `pubspec.yaml`
- dependency versions | not inspected because scan scope was restricted to `lib/` | `pubspec.yaml`
- package-name consistency | some files import `package:my_neumorphic/...`; actual package name cannot be confirmed from `lib/` alone | `pubspec.yaml`
- examples and external usage | not inspected because scan scope was restricted to `lib/` | `example/`
- test coverage | not inspected because scan scope was restricted to `lib/` | `test/`
- garbled comments | several comments appear encoding-corrupted; behavior claims are based on code, not those comments | original source encoding or history
- Flutter RRect normalization | `StadiumPathProvider` uses a very large circular radius; exact radius clamping is delegated to Flutter framework behavior, not implemented in this package | Flutter `RRect` / `Path.addRRect` implementation
- shadow performance profile | exact GPU cost depends on Flutter engine backend, device, path complexity, and layer bounds; source confirms expensive primitives but not runtime timings | Flutter performance profiling / DevTools
