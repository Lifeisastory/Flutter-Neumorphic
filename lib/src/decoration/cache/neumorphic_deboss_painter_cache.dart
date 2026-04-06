import 'package:flutter/material.dart';

import '../../../flutter_neumorphic.dart';
import 'abstract_neumorphic_painter_cache.dart';

class NeumorphicDebossPainterCache extends AbstractNeumorphicPainterCache {
  @override
  Color generateShadowDarkColor({required Color color, required double intensity}) {
    return NeumorphicColors.dmbossBlackColor(color, intensity: intensity);
  }

  @override
  Color generateShadowLightColor({required Color color, required double intensity}) {
    return NeumorphicColors.dmbossWhiteColor(color, intensity: intensity);
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
  late double secondaryXDepth;
  late double secondaryYDepth;
  late double secondaryXPadding;
  late double secondaryYPadding;
  late double secondaryBlackShadowLeftTranslation;
  late double secondaryBlackShadowTopTranslation;
  late double secondaryWhiteShadowLeftTranslation;
  late double secondaryWhiteShadowTopTranslation;
  late double secondaryScaledWidth;
  late double secondaryScaledHeight;
  late double secondaryScaleX;
  late double secondaryScaleY;

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
  void updateSecondaryTranslations() {
    this.secondaryXDepth = this.lightSource.dx * this.secondaryDepth;
    this.secondaryYDepth = this.lightSource.dy * this.secondaryDepth;
    this.secondaryXPadding = 2 * (1 - this.lightSource.dx.abs()) * this.secondaryDepth;
    this.secondaryYPadding = 2 * (1 - this.lightSource.dy.abs()) * this.secondaryDepth;

    this.secondaryWhiteShadowLeftTranslation = secondaryXDepth - secondaryXPadding;
    this.secondaryWhiteShadowTopTranslation = secondaryYDepth - secondaryYPadding;

    this.secondaryBlackShadowLeftTranslation = -(secondaryXDepth + secondaryXPadding);
    this.secondaryBlackShadowTopTranslation = -(secondaryYDepth + secondaryYPadding);

    this.secondaryScaledWidth = this.width + 2 * secondaryXPadding;
    this.secondaryScaledHeight = this.height + 2 * secondaryYPadding;

    this.secondaryScaleX = this.secondaryScaledWidth / this.width;
    this.secondaryScaleY = this.secondaryScaledHeight / this.height;
  }
}
