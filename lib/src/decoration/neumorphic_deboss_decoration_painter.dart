import 'package:flutter/material.dart';

import '../neumorphic_box_shape.dart';
import '../theme/themes.dart';
import 'cache/neumorphic_deboss_painter_cache.dart';

export '../theme/themes.dart';


class NeumorphicDebossDecorationPainter extends BoxPainter {
  NeumorphicDebossPainterCache _cache;

  final NeumorphicStyle style;
  final NeumorphicBoxShape shape;

  late Paint _backgroundPaint;
  late Paint _whiteShadowPaint;
  late Paint _whiteShadowMaskPaint;
  late Paint _blackShadowPaint;
  late Paint _blackShadowMaskPaint;
  late Paint _whiteBorderPaint;
  late Paint _whiteBorderMaskPaint;
  late Paint _blackBorderPaint;
  late Paint _blackBorderMaskPaint;
  
  late Paint _borderPaint;

  final bool isPaintShadow;
  final bool isPaintBackground;

  /// 压印
  NeumorphicDebossDecorationPainter({
    required this.style,
    required this.isPaintBackground,
    required this.isPaintShadow,
    required VoidCallback onChanged,
    NeumorphicBoxShape? shape,
  }) : this.shape = shape ?? NeumorphicBoxShape.rect(),
       _cache = NeumorphicDebossPainterCache(),
       super(onChanged) {
    _generatePainters();
  }

  void _generatePainters() {
    this._backgroundPaint = Paint();
    this._whiteShadowPaint = Paint();
    this._whiteShadowMaskPaint = Paint()..blendMode = BlendMode.dstOut;
    this._blackShadowPaint = Paint();
    this._blackShadowMaskPaint = Paint()..blendMode = BlendMode.dstOut;
    this._whiteBorderPaint = Paint();
    this._whiteBorderMaskPaint = Paint()..blendMode = BlendMode.dstOut;
    this._blackBorderPaint = Paint();
    this._blackBorderMaskPaint = Paint()..blendMode = BlendMode.dstOut;

    this._borderPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.bevel
      ..style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    _updateCache(offset: offset, configuration: configuration, newStyle: this.style);

    for (var subPath in _cache.subPaths) {
      if (isPaintBackground) {
        _paintBackground(canvas, subPath);
      }

      if (isPaintShadow) {
        _paintShadows(canvas, subPath);
      }

      if (style.border.isEnabled) {
        _drawBorder(canvas: canvas, offset: offset, path: subPath);
      } else {
        _paintBorder(canvas, subPath);
      }
    }
  }

  void _updateCache({required Offset offset, required ImageConfiguration configuration, required NeumorphicStyle newStyle}) {
    bool invalidSize = false;
    if (configuration.size != null) {
      invalidSize = this._cache.updateSize(newOffset: offset, newSize: configuration.size!);
      if (invalidSize) {
        _cache.updatePath(newPath: shape.customShapePathProvider.getPath(configuration.size!));
      }
    }

    bool invalidLightSource = false;
    invalidLightSource = this._cache.updateLightSource(style.lightSource, style.oppositeShadowLightSource);

    bool invalidColor = false;
    if (style.color != null) {
      invalidColor = this._cache.updateStyleColor(style.color!);
      if (invalidColor) {
        _backgroundPaint..color = _cache.backgroundColor;
      }
    }

    bool invalidDepth = false;
    if (style.depth != null) {
      invalidDepth = this._cache.updateStyleDepth(style.depth!, 5);
      if (invalidDepth) {
        _blackShadowMaskPaint..maskFilter = _cache.maskFilter;
        _whiteShadowMaskPaint..maskFilter = _cache.maskFilter;
      }
    }

    bool invalidBorderDepth = false;
    if (style.borderDepth != null) {
      invalidBorderDepth = this._cache.updateBorderStyleDepth(style.borderDepth!, 5);
      if (invalidBorderDepth) {
        _blackBorderPaint..maskFilter = _cache.borderMaskFilter;
        _whiteBorderPaint..maskFilter = _cache.borderMaskFilter;
      }
    }

    final bool invalidShadowColors = this._cache.updateShadowColor(
      newShadowLightColor: style.shadowWhiteColorDeboss ?? Color(0xFFFFFFFF),
      newShadowDarkColor: style.shadowBlackColorDeboss ?? Color(0xFF000000),
      newIntensity: style.intensity ?? 0.25,
    );
    if (invalidShadowColors) {
      if (_cache.shadowLightColor != null) {
        _whiteShadowPaint..color = _cache.shadowLightColor!;
      }
      if (_cache.shadowDarkColor != null) {
        _blackShadowPaint..color = _cache.shadowDarkColor!;
      }
    }

    final bool invalidBorderShadowColors = this._cache.updateBorderShadowColor(
      newShadowLightColor: style.shadowWhiteColorDeboss ?? Color(0xFFFFFFFF),
      newShadowDarkColor: style.shadowBlackColorDeboss ?? Color(0xFF000000),
      newIntensity: style.borderIntensity ?? 0.5,
    );
    if (invalidBorderShadowColors) {
      if (_cache.borderShadowLightColor != null) {
        _whiteBorderPaint..color = _cache.borderShadowLightColor!;
      }
      if (_cache.borderShadowDarkColor != null) {
        _blackBorderPaint..color = _cache.borderShadowDarkColor!;
      }
    }

    if (invalidLightSource || invalidDepth) {
      _cache.updateDepthOffset();
    }

    if (invalidLightSource || invalidBorderDepth) {
      _cache.updateBorderDepthOffset();
    }

    if (invalidLightSource || invalidDepth || invalidSize) {
      _cache.updateTranslations();
    }
  }

  void _paintBackground(Canvas canvas, Path path) {
    canvas
      ..save()
      ..translate(_cache.originOffset.dx, _cache.originOffset.dy)
      ..drawPath(path, _backgroundPaint)
      ..restore();
  }

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

  void _paintBorder(Canvas canvas, Path path) {
    if (style.borderDepth != null && style.borderDepth!.abs() >= 0.1) {
      canvas
        ..saveLayer(_cache.layerRect, Paint())
        ..translate(_cache.originOffset.dx + _cache.borderDepthOffset.dx, _cache.originOffset.dy + _cache.borderDepthOffset.dy)
        ..drawPath(path, _blackBorderPaint)
        ..translate(-_cache.borderDepthOffset.dx, -_cache.borderDepthOffset.dy)
        ..drawPath(path, _blackBorderMaskPaint)
        ..restore();

      canvas
        ..saveLayer(_cache.layerRect, Paint())
        ..translate(_cache.originOffset.dx - _cache.borderDepthOffset.dx, _cache.originOffset.dy - _cache.borderDepthOffset.dy)
        ..drawPath(path, _whiteBorderPaint)
        ..translate(_cache.borderDepthOffset.dx, _cache.borderDepthOffset.dy)
        ..drawPath(path, _whiteBorderMaskPaint)
        ..restore();
    }
  }

  void _paintShadows(Canvas canvas, Path path) {
    final Matrix4 matrix4 = Matrix4.identity()..scaleByDouble(_cache.scaleX, _cache.scaleY, 1.0, 1.0);

    canvas
      ..saveLayer(_cache.layerRect, Paint())
      ..translate(_cache.originOffset.dx, _cache.originOffset.dy)
      ..drawPath(path, _whiteShadowPaint)
      ..translate(_cache.whiteShadowLeftTranslation, _cache.whiteShadowTopTranslation)
      ..drawPath(path.transform(matrix4.storage), _whiteShadowMaskPaint)
      ..restore();

    canvas
      ..saveLayer(_cache.layerRect, Paint())
      ..translate(_cache.originOffset.dx, _cache.originOffset.dy)
      ..drawPath(path, _blackShadowPaint)
      ..translate(_cache.blackShadowLeftTranslation, _cache.blackShadowTopTranslation)
      ..drawPath(path.transform(matrix4.storage), _blackShadowMaskPaint)
      ..restore();
  }
}
