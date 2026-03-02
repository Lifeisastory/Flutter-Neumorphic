import 'package:flutter/material.dart';

import '../../../flutter_neumorphic.dart';
import 'abstract_neumorphic_painter_cache.dart';

class NeumorphicEmbossPainterCache extends AbstractNeumorphicPainterCache {
  @override
  Color generateShadowDarkColor({required Color color, required double intensity}) {
    return NeumorphicColors.embossBlackColor(color, intensity: intensity);
  }

  @override
  Color generateShadowLightColor({required Color color, required double intensity}) {
    return NeumorphicColors.embossWhiteColor(color, intensity: intensity);
  }

  @override
  void updateTranslations() {
    //no-op, used only for deboss
  }

  @override
  Rect updateLayerRect({required Offset newOffset, required Size newSize}) {
    return Rect.fromLTRB(
      originOffset.dx - newSize.width,
      originOffset.dy - newSize.height,
      originOffset.dx + 2 * newSize.width,
      originOffset.dy + 2 * newSize.height,
    );
  }
}
