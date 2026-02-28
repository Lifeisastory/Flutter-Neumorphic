import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'cache/neumorphic_deboss_painter_cache.dart';

/// 凹入

class NeumorphicDebossDecorationTextPainter extends BoxPainter {
  final NeumorphicStyle style;
  final String text;
  final TextStyle textStyle;
  final TextAlign textAlign;

  final bool drawShadow;
  final bool drawBackground;

  final NeumorphicDebossPainterCache _cache = NeumorphicDebossPainterCache();

  late Paint _borderPaint;
  late Paint _backgroundPaint;
  late Paint _whiteShadowPaint;
  late Paint _whiteShadowMaskPaint;
  late Paint _blackShadowPaint;
  late Paint _blackShadowMaskPaint;

  late ui.Paragraph _textParagraph;
  late ui.Paragraph _innerTextParagraph;
  late ui.Paragraph _whiteShadowParagraph;
  late ui.Paragraph _whiteShadowMaskParagraph;
  late ui.Paragraph _blackShadowTextParagraph;
  late ui.Paragraph _blackShadowTextMaskParagraph;

  NeumorphicDebossDecorationTextPainter({
    required this.style,
    required this.text,
    required this.textStyle,
    required this.textAlign,
    required this.drawBackground,
    required this.drawShadow,
    required VoidCallback onChanged,
  }) : super(onChanged) {
    _generatePainters();
  }

  void _generatePainters() {
    _backgroundPaint = Paint();
    _whiteShadowPaint = Paint();
    _whiteShadowMaskPaint = Paint()..blendMode = BlendMode.dstOut;
    _blackShadowPaint = Paint();
    _blackShadowMaskPaint = Paint()..blendMode = BlendMode.dstOut;

    _borderPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.bevel
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.border.width ?? 0.0
      ..color = style.border.color ?? const Color(0xFFFFFFFF);
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    _updateCache(offset: offset, configuration: configuration);

    if (drawBackground) {
      _drawBackground(canvas: canvas);
    }

    if (style.border.isEnabled) {
      _drawBorder(canvas: canvas);
    }

    if (drawShadow) {
      _drawShadows(canvas: canvas);
    }
  }

  void _updateCache({required Offset offset, required ImageConfiguration configuration}) {
    bool invalidateSize = false;
    if (configuration.size != null) {
      invalidateSize = _cache.updateSize(newOffset: offset, newSize: configuration.size!);
    }

    final bool invalidateLightSource = _cache.updateLightSource(style.lightSource, style.oppositeShadowLightSource);

    if (style.color != null) {
      final invalidateColor = _cache.updateStyleColor(style.color!);
      if (invalidateColor) {
        _backgroundPaint..color = _cache.backgroundColor;
      }
    }

    bool invalidateDepth = false;
    if (style.depth != null) {
      invalidateDepth = _cache.updateStyleDepth(style.depth!, 5);
      if (invalidateDepth) {
        _blackShadowMaskPaint..maskFilter = _cache.maskFilterBlur;
        _whiteShadowMaskPaint..maskFilter = _cache.maskFilterBlur;
      }
    }

    final invalidateShadowColors = _cache.updateShadowColor(
      newShadowLightColor: style.shadowLightColorDeboss ?? Colors.white,
      newShadowDarkColor: style.shadowDarkColorDeboss ?? Colors.black,
      newIntensity: style.intensity ?? 0.25,
    );

    if (invalidateShadowColors) {
      if (_cache.shadowLightColor != null) {
        _whiteShadowPaint..color = _cache.shadowLightColor!;
      }
      if (_cache.shadowDarkColor != null) {
        _blackShadowPaint..color = _cache.shadowDarkColor!;
      }
    }

    final constraints = ui.ParagraphConstraints(width: _cache.width);
    final paragraphStyle = textStyle.getParagraphStyle(textDirection: TextDirection.ltr, textAlign: textAlign);

    _textParagraph = (ui.ParagraphBuilder(paragraphStyle)
          ..pushStyle(ui.TextStyle(foreground: _borderPaint))
          ..addText(text))
        .build()
      ..layout(constraints);

    _innerTextParagraph = (ui.ParagraphBuilder(paragraphStyle)
          ..pushStyle(ui.TextStyle(foreground: _backgroundPaint))
          ..addText(text))
        .build()
      ..layout(constraints);

    _whiteShadowParagraph = (ui.ParagraphBuilder(paragraphStyle)
          ..pushStyle(ui.TextStyle(foreground: _whiteShadowPaint))
          ..addText(text))
        .build()
      ..layout(constraints);

    _whiteShadowMaskParagraph = (ui.ParagraphBuilder(paragraphStyle)
          ..pushStyle(ui.TextStyle(foreground: _whiteShadowMaskPaint))
          ..addText(text))
        .build()
      ..layout(constraints);

    _blackShadowTextParagraph = (ui.ParagraphBuilder(paragraphStyle)
          ..pushStyle(ui.TextStyle(foreground: _blackShadowPaint))
          ..addText(text))
        .build()
      ..layout(constraints);

    _blackShadowTextMaskParagraph = (ui.ParagraphBuilder(paragraphStyle)
          ..pushStyle(ui.TextStyle(foreground: _blackShadowMaskPaint))
          ..addText(text))
        .build()
      ..layout(constraints);

    if (invalidateLightSource || invalidateDepth || invalidateSize) {
      _cache.updateTranslations();
    }
  }

  void _drawBackground({required Canvas canvas}) {
    canvas
      ..save()
      ..translate(_cache.originOffset.dx, _cache.originOffset.dy)
      ..drawParagraph(_innerTextParagraph, Offset.zero)
      ..restore();
  }

  void _drawBorder({required Canvas canvas}) {
    if (style.border.width != null && style.border.width! > 0) {
      canvas
        ..save()
        ..translate(_cache.originOffset.dx, _cache.originOffset.dy)
        ..drawParagraph(_textParagraph, Offset.zero)
        ..restore();
    }
  }

  void _drawShadows({required Canvas canvas}) {
    canvas
      ..saveLayer(_cache.layerRect, _whiteShadowPaint)
      ..translate(_cache.originOffset.dx, _cache.originOffset.dy)
      ..drawParagraph(_whiteShadowParagraph, Offset.zero)
      ..translate(_cache.witheShadowLeftTranslation, _cache.witheShadowTopTranslation)
      ..drawParagraph(_whiteShadowMaskParagraph, Offset.zero)
      ..restore();

    canvas
      ..saveLayer(_cache.layerRect, _blackShadowPaint)
      ..translate(_cache.originOffset.dx, _cache.originOffset.dy)
      ..drawParagraph(_blackShadowTextParagraph, Offset.zero)
      ..translate(_cache.blackShadowLeftTranslation, _cache.blackShadowTopTranslation)
      ..drawParagraph(_blackShadowTextMaskParagraph, Offset.zero)
      ..restore();
  }
}
