import 'package:flutter/material.dart';

import '../../../flutter_neumorphic.dart';
import 'abstract_neumorphic_painter_cache.dart';

class NeumorphicDebossPainterCache extends AbstractNeumorphicPainterCache {
  @override
  Color generateShadowDarkColor({required Color color, required double intensity}) {
    return NeumorphicColors.debossBlackColor(color, intensity: intensity);
  }

  @override
  Color generateShadowLightColor({required Color color, required double intensity}) {
    return NeumorphicColors.debossWhiteColor(color, intensity: intensity);
  }

  @override
  Rect updateLayerRect({required Offset newOffset, required Size newSize}) {
    return Rect.fromLTRB(
      newOffset.dx - newSize.width,
      newOffset.dy - newSize.height,
      newOffset.dx + 2 * newSize.width,
      newOffset.dy + 2 * newSize.height,
    );
  }

  late double xDepth;
  late double yDepth;
  late double xPadding;
  late double yPadding;
  late double blackShadowLeftTranslation;
  late double blackShadowTopTranslation;
  late double whiteShadowLeftTranslation;
  late double whiteShadowTopTranslation;
  late double scaledWidth;
  late double scaledHeight;

  late double scaleX;
  late double scaleY;
  late double borderXDepth;
  late double borderYDepth;
  late double borderXPadding;
  late double borderYPadding;
  late double borderBlackShadowLeftTranslation;
  late double borderBlackShadowTopTranslation;
  late double borderWhiteShadowLeftTranslation;
  late double borderWhiteShadowTopTranslation;
  late double borderScaledWidth;
  late double borderScaledHeight;
  late double borderScaleX;
  late double borderScaleY;

  //call after _cacheWidth & _cacheHeight set
  @override
  void updateTranslations() {
    this.xDepth = this.lightSource.dx * this.depth;
    this.yDepth = this.lightSource.dy * this.depth;
    this.xPadding = 2 * (1 - this.lightSource.dx.abs()) * this.depth;
    this.yPadding = 2 * (1 - this.lightSource.dy.abs()) * this.depth;

    this.whiteShadowLeftTranslation = xDepth - xPadding;
    this.whiteShadowTopTranslation = yDepth - yPadding;

    this.blackShadowLeftTranslation = -(xDepth + xPadding);
    this.blackShadowTopTranslation = -(yDepth + yPadding);

    this.scaledWidth = this.width + 2 * xPadding;
    this.scaledHeight = this.height + 2 * yPadding;

    this.scaleX = this.scaledWidth / this.width;
    this.scaleY = this.scaledHeight / this.height;
  }

  @override
  void updateBorderTranslations() {
    this.borderXDepth = this.lightSource.dx * this.borderDepth;
    this.borderYDepth = this.lightSource.dy * this.borderDepth;
    this.borderXPadding = 2 * (1 - this.lightSource.dx.abs()) * this.borderDepth;
    this.borderYPadding = 2 * (1 - this.lightSource.dy.abs()) * this.borderDepth;

    this.borderWhiteShadowLeftTranslation = borderXDepth - borderXPadding;
    this.borderWhiteShadowTopTranslation = borderYDepth - borderYPadding;

    this.borderBlackShadowLeftTranslation = -(borderXDepth + borderXPadding);
    this.borderBlackShadowTopTranslation = -(borderYDepth + borderYPadding);

    this.borderScaledWidth = this.width + 2 * borderXPadding;
    this.borderScaledHeight = this.height + 2 * borderYPadding;

    this.borderScaleX = this.borderScaledWidth / this.width;
    this.borderScaleY = this.borderScaledHeight / this.height;
  }
}
