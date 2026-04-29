import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../flutter_neumorphic.dart';


/// Defines default colors used in Neumorphic theme & shadows generators
@immutable
class NeumorphicColors {
  static const background = Color(0xFFDDE6E8);
  static const accent = Color(0xFF2196F3);
  static const variant = Color(0xFF00BCD4);
  static const disabled = Color(0xFF9E9E9E);

  static const darkBackground = Color(0xFF2D2F2F);
  static const darkAccent = Color(0xFF4CAF50);
  static const darkVariant = Color(0xFF607D8B);
  static const darkDisabled = Color(0xB3FFFFFF);
  static const darkDefaultTextColor = Color(0xB3FFFFFF);

  static const Color defaultBorder = Color(0x33000000);
  static const Color darkDefaultBorder = Color(0x33FFFFFF);

  static const Color defaultEmbossWhiteColor = Color(0xffe9e9e9);
  static const Color defaultEmbossBlackColor = Color(0xffbdbdbd);
  static const Color defaultDebossWhiteColor = Color(0xffe8e8e8);
  static const Color defaultDebossBlackColor = Color(0xffbebebe);

  static const Color darkDefaultEmbossWhiteColor = Color(0xff2f323b);
  static const Color darkDefaultEmbossBlackColor = Color(0xff24262b);
  static const Color darkDefaultDebossWhiteColor = Color(0xff2f323b);
  static const Color darkDefaultDebossBlackColor = Color(0xff25262b);

  static const Color _gradientShaderBlackColor = Color(0x8A000000);
  static const Color _gradientShaderWhiteColor = Color(0xFFFFFFFF);

  static const Color defaultTextColor = Color(0xFF000000);

  NeumorphicColors._();

  static Color embossWhiteColor(Color color, {required double intensity}) {
    // intensity act on opacity;
    return _applyPercentageOnOpacity(maxColor: color, percent: intensity);
  }

  static Color embossBlackColor(Color color, {required double intensity}) {
    // intensity act on opacity;
    return _applyPercentageOnOpacity(maxColor: color, percent: intensity);
  }

  static Color debossWhiteColor(Color color, {required double intensity}) {
    // intensity act on opacity;
    return _applyPercentageOnOpacity(maxColor: color, percent: intensity);
  }

  static Color debossBlackColor(Color color, {required double intensity}) {
    // intensity act on opacity;
    return _applyPercentageOnOpacity(maxColor: color, percent: intensity);
  }

  static Color gradientShaderBlackColor({required double intensity}) {
    // intensity act on opacity;
    return _applyPercentageOnOpacity(maxColor: NeumorphicColors._gradientShaderBlackColor, percent: intensity);
  }

  static Color gradientShaderWhiteColor({required double intensity}) {
    // intensity act on opacity;
    return _applyPercentageOnOpacity(maxColor: NeumorphicColors._gradientShaderWhiteColor, percent: intensity);
  }

  static Color _applyPercentageOnOpacity({required Color maxColor, required double percent}) {
    final maxOpacity = maxColor.a;
    final maxIntensity = NeumorphicContainer.MAX_INTENSITY;
    final newOpacity = percent * maxOpacity / maxIntensity;
    final newColor = maxColor.withValues(alpha: newOpacity); //<-- intensity act on opacity;
    return newColor;
  }
}
