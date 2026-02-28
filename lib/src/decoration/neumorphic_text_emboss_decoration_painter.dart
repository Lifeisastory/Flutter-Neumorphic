import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../theme/theme.dart';
import 'cache/neumorphic_emboss_painter_cache.dart';
import 'neumorphic_box_decoration_helper.dart';
import 'neumorphic_deboss_decoration_painter.dart';

class NeumorphicEmptyTextPainter extends BoxPainter {
  NeumorphicEmptyTextPainter({required VoidCallback onChanged}) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    //does nothing
  }
}

/// 凸出
/// 通过叠加一段文本的多层[Paragraph]达到阴影效果
/// [Paragraph]本质上是“同一段文本的多份可绘制缓存”，每份绑定不同[Paint]，用于分层渲染
/// 在创建[Paint]时，核心是指定混合模式为[BlendMode.dstOut]达到抠除原图保留阴影的效果
/// 这个类的核心为以下三步：
/// _updateCache()：更新尺寸/光源/depth/阴影色，并重建各 Paragraph
/// _drawShadow()：先画白黑阴影，再用 `dstOut` 的 mask 文本抠除中心
/// _drawElement()：画正文 + 可选渐变 + 可选描边

class NeumorphicEmbossDecorationTextPainter extends BoxPainter {
  final NeumorphicStyle style;
  final String text;
  final TextStyle textStyle;
  final TextAlign textAlign;

  NeumorphicEmbossPainterCache _cache;

  late Paint _borderPaint;
  late Paint _backgroundPaint;
  late Paint _whiteShadowPaint;
  late Paint _whiteShadowMaskPaint;
  late Paint _blackShadowPaint;
  late Paint _blackShadowMaskPaint;
  late Paint _gradientPaint;

  late ui.Paragraph _textParagraph;
  late ui.Paragraph _innerTextParagraph;
  late ui.Paragraph _whiteShadowParagraph;
  late ui.Paragraph _whiteShadowMaskParagraph;
  late ui.Paragraph _blackShadowTextParagraph;
  late ui.Paragraph _blackShadowTextMaskParagraph;
  late ui.Paragraph _gradientParagraph;

  void generatePainters() {
    this._backgroundPaint = Paint();
    this._whiteShadowPaint = Paint();
    this._whiteShadowMaskPaint = Paint()..blendMode = BlendMode.dstOut;
    this._blackShadowPaint = Paint();
    this._blackShadowMaskPaint = Paint()..blendMode = BlendMode.dstOut;
    this._gradientPaint = Paint();

    this._borderPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.bevel
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.border.width ?? 0.0
      ..color = style.border.color ?? Color(0xFFFFFFFF);
  }

  final bool drawGradient;
  final bool drawShadow;
  final bool drawBackground;
  final bool renderingByPath;

  NeumorphicEmbossDecorationTextPainter(
      {required this.style,
      required this.textStyle,
      required this.text,
      required this.drawGradient,
      required this.drawShadow,
      required this.drawBackground,
      required VoidCallback onChanged,
      required this.textAlign,
      this.renderingByPath = true})
      : _cache = NeumorphicEmbossPainterCache(),
        super(onChanged) {
    generatePainters();
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    _updateCache(offset, configuration);

    _drawShadow(offset: offset, canvas: canvas, path: _cache.path);

    _drawElement(offset: offset, canvas: canvas, path: _cache.path);
  }

  void _updateCache(Offset offset, ImageConfiguration configuration) {
    bool invalidateSize = false;
    if (configuration.size != null) {
      invalidateSize = this._cache.updateSize(newOffset: offset, newSize: configuration.size!);
    }

    final bool invalidateLightSource = this._cache.updateLightSource(style.lightSource, style.oppositeShadowLightSource);

    bool invalidateColor = false;
    if (style.color != null) {
      invalidateColor = this._cache.updateStyleColor(style.color!);
      if (invalidateColor) {
        _backgroundPaint..color = _cache.backgroundColor;
      }
    }

    /// 指定深度（即改变阴影的偏移量）的同时，还会指定[Paint.maskFilter]来柔化阴影边缘
    bool invalidateDepth = false;
    if (style.depth != null) {
      invalidateDepth = this._cache.updateStyleDepth(style.depth!, 3);
      if (invalidateDepth) {
        _blackShadowPaint..maskFilter = _cache.maskFilterBlur;
        _whiteShadowPaint..maskFilter = _cache.maskFilterBlur;
      }
    }

    bool invalidateShadowColors = false;
    if (style.shadowLightColorEmboss != null && style.shadowDarkColorEmboss != null && style.intensity != null) {
      invalidateShadowColors = this._cache.updateShadowColor(
            newShadowLightColor: style.shadowLightColorEmboss!,
            newShadowDarkColor: style.shadowDarkColorEmboss!,
            newIntensity: style.intensity ?? neumorphicDefaultTheme.intensity,
          );
      if (invalidateShadowColors) {
        if (_cache.shadowLightColor != null) {
          _whiteShadowPaint..color = _cache.shadowLightColor!;
        }
        if (_cache.shadowDarkColor != null) {
          _blackShadowPaint..color = _cache.shadowDarkColor!;
        }
      }
    }

    final constraints = ui.ParagraphConstraints(width: _cache.width);
    final paragraphStyle = textStyle.getParagraphStyle(textDirection: TextDirection.ltr, textAlign: this.textAlign);

    final textParagraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(ui.TextStyle(foreground: _borderPaint))
      ..addText(text);

    final innerTextParagraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(ui.TextStyle(foreground: _backgroundPaint))
      ..addText(text);

    final whiteShadowParagraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(ui.TextStyle(foreground: _whiteShadowPaint))
      ..addText(text);

    final whiteShadowMaskParagraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(ui.TextStyle(foreground: _whiteShadowMaskPaint))
      ..addText(text);

    final blackShadowParagraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(ui.TextStyle(foreground: _blackShadowPaint))
      ..addText(text);

    final blackShadowMaskParagraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(ui.TextStyle(foreground: _blackShadowMaskPaint))
      ..addText(text);

    _textParagraph = textParagraphBuilder.build()..layout(constraints);
    _innerTextParagraph = innerTextParagraphBuilder.build()..layout(constraints);
    _whiteShadowParagraph = whiteShadowParagraphBuilder.build()..layout(constraints);
    _whiteShadowMaskParagraph = whiteShadowMaskParagraphBuilder.build()..layout(constraints);
    _blackShadowTextParagraph = blackShadowParagraphBuilder.build()..layout(constraints);
    _blackShadowTextMaskParagraph = blackShadowMaskParagraphBuilder.build()..layout(constraints);

    //region gradient
    final gradientParagraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(ui.TextStyle(
        foreground: _gradientPaint
          ..shader = getGradientShader(
            gradientRect: Rect.fromLTRB(0, 0, _cache.width, _cache.height),
            intensity: style.surfaceIntensity,
            source: style.shape == NeumorphicSurfaceType.concave ? this.style.lightSource : this.style.lightSource.invert(),
          ),
      ))
      ..addText(text);

    _gradientParagraph = gradientParagraphBuilder.build()..layout(ui.ParagraphConstraints(width: _cache.width));
    //endregion

    if (invalidateDepth || invalidateLightSource) {
      _cache.updateDepthOffset();
    }

    if (invalidateLightSource || invalidateDepth || invalidateSize) {
      _cache.updateTranslations();
    }
  }

  void _drawShadow({required Canvas canvas, required Offset offset, required Path path}) {
    if (style.depth != null && style.depth!.abs() >= 0.1) {
      canvas
        ..saveLayer(_cache.layerRect, _whiteShadowPaint)
        ..translate(offset.dx + _cache.depthOffset.dx, offset.dy + _cache.depthOffset.dy)
        ..drawParagraph(_whiteShadowParagraph, Offset.zero)
        ..translate(-_cache.depthOffset.dx, -_cache.depthOffset.dy)
        ..drawParagraph(_whiteShadowMaskParagraph, Offset.zero)
        ..restore();

      canvas
        ..saveLayer(_cache.layerRect, _blackShadowPaint)
        ..translate(offset.dx - _cache.depthOffset.dx, offset.dy - _cache.depthOffset.dy)
        ..drawParagraph(_blackShadowTextParagraph, Offset.zero)
        ..translate(_cache.depthOffset.dx, _cache.depthOffset.dy)
        ..drawParagraph(_blackShadowTextMaskParagraph, Offset.zero)
        ..restore();
    }
  }

  void _drawElement({required Canvas canvas, required Offset offset, required Path path}) {
    if (true) {
      _drawBackground(offset: offset, canvas: canvas, path: path);
    }
    if (this.drawGradient) {
      _drawGradient(offset: offset, canvas: canvas, path: path);
    }
    if (style.border.isEnabled) {
      _drawBorder(canvas: canvas, offset: offset, path: path);
    }
  }

  void _drawBackground({required Canvas canvas, required Offset offset, required Path path}) {
    canvas
      ..save()
      ..translate(offset.dx, offset.dy)
      ..drawParagraph(_innerTextParagraph, Offset.zero)
      ..restore();
  }

  void _drawGradient({required Canvas canvas, required Offset offset, required Path path}) {
    if (style.shape == NeumorphicSurfaceType.concave || style.shape == NeumorphicSurfaceType.convex) {
      canvas
        ..saveLayer(_cache.layerRect, _gradientPaint)
        ..translate(offset.dx, offset.dy)
        ..drawParagraph(_gradientParagraph, Offset.zero)
        ..restore();
    }
  }

  void _drawBorder({required Canvas canvas, required Offset offset, required Path path}) {
    if (style.border.width != null && style.border.width! > 0) {
      canvas
        ..save()
        ..translate(offset.dx, offset.dy)
        ..drawParagraph(_textParagraph, Offset.zero)
        ..restore();
    }
  }
}
