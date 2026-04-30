import 'package:flutter/material.dart';

import '../neumorphic_box_shape.dart';
import '../theme/themes.dart';
import 'cache/neumorphic_emboss_painter_cache.dart';
import 'neumorphic_box_decoration_helper.dart';

class NeumorphicEmbossDecorationPainter extends BoxPainter {
  final NeumorphicStyle style;
  final NeumorphicBoxShape shape;

  NeumorphicEmbossPainterCache _cache = NeumorphicEmbossPainterCache();

  late Paint _backgroundPaint;
  // 外围阴影
  late Paint _whiteShadowPaint;
  late Paint _whiteShadowMaskPaint;
  late Paint _blackShadowPaint;
  late Paint _blackShadowMaskPaint;
  // 边框前景亮部和暗部
  late Paint _whiteBorderPaint;
  late Paint _whiteBorderMaskPaint;
  late Paint _blackBorderPaint;
  late Paint _blackBorderMaskPaint;
  // 表面效果
  late Paint _surfaceGradientPaint;
  // 绘制简单的线条边框
  late Paint _borderPaint;

  void generatePainters() {
    this._backgroundPaint = Paint();
    
    this._whiteShadowPaint = Paint();
    this._whiteShadowMaskPaint = Paint()..blendMode = BlendMode.dstOut;
    this._blackShadowPaint = Paint();
    this._blackShadowMaskPaint = Paint()..blendMode = BlendMode.dstOut;
    this._whiteBorderPaint = Paint();
    this._whiteBorderMaskPaint = Paint()..blendMode = BlendMode.dstOut;
    this._blackBorderPaint = Paint();
    this._blackBorderMaskPaint = Paint()..blendMode = BlendMode.dstOut;
    this._surfaceGradientPaint = Paint();

    this._borderPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.bevel
      ..style = PaintingStyle.stroke;
  }

  final bool isPaintSurfaceGradient;
  final bool isPaintShadow;
  final bool isPaintBackground;
  final bool isRenderByPath;
  
  /// 浮雕
  /// 
  /// [isPaintSurfaceGradient] 是否绘制表面凸出或凹陷的渐变效果，可以在 [getSurfaceGradientShader] 中自定义渐变颜色
  /// [isPaintShadow] 是否绘制阴影，为false则没有拟物效果
  /// [isPaintBackground] 是否绘制decoration的背景色，一般只在次decoration做为背景时才需要绘制背景色
  NeumorphicEmbossDecorationPainter({
    required this.style,
    required this.shape,
    required this.isPaintSurfaceGradient,
    required this.isPaintShadow,
    required this.isPaintBackground,
    required VoidCallback onChanged,
    this.isRenderByPath = true,
  }) : super(onChanged) {
    generatePainters();
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    _updateCache(offset, configuration);
    
    if (isPaintShadow) {
      for (var subPath in _cache.subPaths) {
        _paintShadow(offset: offset, canvas: canvas, path: subPath);
      }
    }

    if (isRenderByPath) {
      for (var subPath in _cache.subPaths) {
        _drawElement(offset: offset, canvas: canvas, path: subPath);
      }
    } else {
      _drawElement(offset: offset, canvas: canvas, path: _cache.path);
    }
  }

  void _updateCache(Offset offset, ImageConfiguration configuration) {
    bool invalidSize = false;
    if (configuration.size != null) {
      invalidSize = this._cache.updateSize(newOffset: offset, newSize: configuration.size!);
      if (invalidSize) {
        _cache.updatePath(newPath: shape.customShapePathProvider.getPath(configuration.size!));
      }
    }

    bool invalidLightSource = false;
    if (style.color != null) {
      invalidLightSource = this._cache.updateLightSource(style.lightSource, style.oppositeShadowLightSource);
    }

    bool invalidColor = false;
    if (style.color != null) {
      invalidColor = this._cache.updateStyleColor(style.color!);
      if (invalidColor) {
        _backgroundPaint..color = _cache.backgroundColor;
      }
    }

    bool invalidDepth = false;
    if (style.depth != null) {
      invalidDepth = this._cache.updateStyleDepth(style.depth!, 3);
      if (invalidDepth) {
        _blackShadowPaint..maskFilter = _cache.maskFilter;
        _whiteShadowPaint..maskFilter = _cache.maskFilter;
      }
    }

    bool invalidBorderDepth = false;
    if (style.borderDepth != null) {
      invalidBorderDepth = this._cache.updateBorderStyleDepth(style.borderDepth!, 3);
      if (invalidBorderDepth) {
        _blackBorderMaskPaint..maskFilter = _cache.borderMaskFilter;
        _whiteBorderMaskPaint..maskFilter = _cache.borderMaskFilter;
      }
    }

    bool invalidShadowColors = false;
    if (style.shadowWhiteColorEmboss != null && style.shadowBlackColorEmboss != null && style.intensity != null) {
      invalidShadowColors = this._cache.updateShadowColor(
        newShadowLightColor: style.shadowWhiteColorEmboss!,
        newShadowDarkColor: style.shadowBlackColorEmboss!,
        newIntensity: style.intensity!,
      );
      if (invalidShadowColors) {
        if (_cache.shadowLightColor != null) {
          _whiteShadowPaint..color = _cache.shadowLightColor!;
        }
        if (_cache.shadowDarkColor != null) {
          _blackShadowPaint..color = _cache.shadowDarkColor!;
        }
      }
    }

    bool invalidBorderShadowColors = false;
    if (style.shadowWhiteColorEmboss != null && style.shadowBlackColorEmboss != null && style.borderIntensity != null) {
      invalidBorderShadowColors = this._cache.updateBorderShadowColor(
        newShadowLightColor: style.shadowWhiteColorEmboss!,
        newShadowDarkColor: style.shadowBlackColorEmboss!,
        newIntensity: style.borderIntensity!,
      );
      if (invalidBorderShadowColors) {
        if (_cache.borderShadowLightColor != null) {
          _whiteBorderPaint..color = _cache.borderShadowLightColor!;
        }
        if (_cache.borderShadowDarkColor != null) {
          _blackBorderPaint..color = _cache.borderShadowDarkColor!;
        }
      }
    }

    if (invalidDepth || invalidLightSource) {
      _cache.updateDepthOffset();
    }

    if (invalidLightSource || invalidDepth || invalidSize) {
      _cache.updateTranslations();
    }

    if (invalidLightSource || invalidBorderDepth || invalidSize) {
      _cache.updateBorderTranslations();
    }
  }

  void _paintShadow({required Canvas canvas, required Offset offset, required Path path}) {
    if (style.depth != null && style.depth!.abs() >= 0.1) {
      canvas
        ..saveLayer(_cache.layerRect, Paint())
        ..translate(offset.dx + _cache.depthOffset.dx, offset.dy + _cache.depthOffset.dy)
        ..drawPath(path, _whiteShadowPaint)
        ..translate(-_cache.depthOffset.dx, -_cache.depthOffset.dy)
        ..drawPath(path, _whiteShadowMaskPaint)
        ..restore();

      canvas
        ..saveLayer(_cache.layerRect, Paint())
        ..translate(offset.dx - _cache.depthOffset.dx, offset.dy - _cache.depthOffset.dy)
        ..drawPath(path, _blackShadowPaint)
        ..translate(_cache.depthOffset.dx, _cache.depthOffset.dy)
        ..drawPath(path, _blackShadowMaskPaint)
        ..restore();
    }
  }

  void _drawElement({required Canvas canvas, required Offset offset, required Path path}) {
    if (isPaintBackground) {
      _paintBackground(offset: offset, canvas: canvas, path: path);
    }
    if (this.isPaintSurfaceGradient) {
      _paintSurfaceGradient(offset: offset, canvas: canvas, path: path);
    }
    if (style.border.isEnabled) {
      _drawBorder(canvas: canvas, offset: offset, path: path);
    } else {
      _paintBorder(canvas: canvas, offset: offset, path: path);
    }
  }

  void _paintBackground({required Canvas canvas, required Offset offset, required Path path}) {
    canvas
      ..save()
      ..translate(offset.dx, offset.dy)
      ..drawPath(path, _backgroundPaint)
      ..restore();
  }

  /// 绘制表面效果
  /// [NeumorphicSurfaceType.concave] 凹入
  /// [NeumorphicSurfaceType.convex] 凸出
  void _paintSurfaceGradient({required Canvas canvas, required Offset offset, required Path path}) {
    if (style.shape == NeumorphicSurfaceType.concave || style.shape == NeumorphicSurfaceType.convex) {
      final pathRect = path.getBounds();

      _surfaceGradientPaint
        ..shader = getSurfaceGradientShader(
          gradientRect: pathRect,
          intensity: style.surfaceIntensity,
          source: style.shape == NeumorphicSurfaceType.concave ? this.style.lightSource : this.style.lightSource.invert(),
        );

      canvas
        ..saveLayer(pathRect.translate(offset.dx, offset.dy), _surfaceGradientPaint)
        ..translate(offset.dx, offset.dy)
        ..drawPath(path, _surfaceGradientPaint)
        ..restore();
    }
  }

  /// 画简单的单一颜色边框
  void _drawBorder({required Canvas canvas, required Offset offset, required Path path}) {
    if (style.border.width != null && style.border.width! > 0) {
      canvas
        ..save()
        ..translate(offset.dx, offset.dy)
        ..drawPath(
          path,
          _borderPaint
            ..color = style.border.color ?? Color(0x00000000)
            ..strokeWidth = style.border.width ?? 0,
        )
        ..restore();
    }
  }

  /// 画拟物边框，包含边框的亮部和暗部
  void _paintBorder({required Canvas canvas, required Offset offset, required Path path}){
    final Matrix4 matrix4 = Matrix4.identity()..scaleByDouble(_cache.borderScaleX, _cache.borderScaleY, 1.0, 1.0);
    canvas
      ..saveLayer(_cache.layerRect, Paint())
      ..translate(_cache.originOffset.dx, _cache.originOffset.dy)
      ..drawPath(path, _whiteBorderPaint)
      ..translate(_cache.borderBlackShadowLeftTranslation, _cache.borderBlackShadowTopTranslation)
      ..drawPath(path.transform(matrix4.storage), _whiteBorderMaskPaint)
      ..restore();

    canvas
      ..saveLayer(_cache.layerRect, Paint())
      ..translate(_cache.originOffset.dx, _cache.originOffset.dy)
      ..drawPath(path, _blackBorderPaint)
      ..translate(_cache.borderWhiteShadowLeftTranslation, _cache.borderWhiteShadowTopTranslation)
      ..drawPath(path.transform(matrix4.storage), _blackBorderMaskPaint)
      ..restore();
  }
}
