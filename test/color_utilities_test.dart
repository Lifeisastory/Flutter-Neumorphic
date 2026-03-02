import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_neumorphic/flutter_neumorphic.dart';

void main() {
  group('NeumorphicColors', () {
    test('decorationWhiteColor creates valid colors', () {
      const baseColor = Color(0xFF808080);
      final result = NeumorphicColors.embossWhiteColor(baseColor, intensity: 0.5);
      
      expect(result, isA<Color>());
      expect(result.alpha, lessThanOrEqualTo(baseColor.alpha));
    });

    test('decorationDarkColor creates valid colors', () {
      const baseColor = Color(0xFF808080);
      final result = NeumorphicColors.embossBlackColor(baseColor, intensity: 0.5);
      
      expect(result, isA<Color>());
      expect(result.alpha, lessThanOrEqualTo(baseColor.alpha));
    });

    test('embossWhiteColor creates valid colors', () {
      const baseColor = Color(0xFF808080);
      final result = NeumorphicColors.dmbossWhiteColor(baseColor, intensity: 0.5);
      
      expect(result, isA<Color>());
      expect(result.alpha, lessThanOrEqualTo(baseColor.alpha));
    });

    test('embossDarkColor creates valid colors', () {
      const baseColor = Color(0xFF808080);
      final result = NeumorphicColors.dmbossBlackColor(baseColor, intensity: 0.5);
      
      expect(result, isA<Color>());
      expect(result.alpha, lessThanOrEqualTo(baseColor.alpha));
    });

    test('gradientShaderWhiteColor creates valid colors', () {
      final result = NeumorphicColors.gradientShaderWhiteColor(intensity: 0.5);
      
      expect(result, isA<Color>());
      expect(result.alpha, lessThanOrEqualTo(255));
    });

    test('gradientShaderDarkColor creates valid colors', () {
      final result = NeumorphicColors.gradientShaderBlackColor(intensity: 0.5);
      
      expect(result, isA<Color>());
      expect(result.alpha, lessThanOrEqualTo(255));
    });

    test('color constants exist and are valid', () {
      expect(NeumorphicColors.background, isA<Color>());
      expect(NeumorphicColors.accent, isA<Color>());
      expect(NeumorphicColors.variant, isA<Color>());
      expect(NeumorphicColors.disabled, isA<Color>());
      expect(NeumorphicColors.darkBackground, isA<Color>());
      expect(NeumorphicColors.darkAccent, isA<Color>());
      expect(NeumorphicColors.darkVariant, isA<Color>());
      expect(NeumorphicColors.darkDisabled, isA<Color>());
    });

    test('intensity parameter affects opacity', () {
      const baseColor = Color(0xFF808080);
      
      final lowIntensity = NeumorphicColors.embossWhiteColor(baseColor, intensity: 0.1);
      final highIntensity = NeumorphicColors.embossWhiteColor(baseColor, intensity: 0.9);
      
      expect(lowIntensity.alpha, lessThan(highIntensity.alpha));
    });

    test('handles edge intensity values', () {
      const baseColor = Color(0xFF808080);
      
      final minIntensity = NeumorphicColors.embossWhiteColor(baseColor, intensity: 0.0);
      final maxIntensity = NeumorphicColors.embossWhiteColor(baseColor, intensity: 1.0);
      
      expect(minIntensity.alpha, equals(0));
      expect(maxIntensity.alpha, greaterThan(0));
    });
  });

  group('Color edge cases', () {
    test('handles pure colors', () {
      const colors = [
        Color(0xFFFF0000), // Red
        Color(0xFF00FF00), // Green
        Color(0xFF0000FF), // Blue
        Color(0xFFFFFF00), // Yellow
        Color(0xFFFF00FF), // Magenta
        Color(0xFF00FFFF), // Cyan
      ];

      for (final color in colors) {
        final whiteColor = NeumorphicColors.embossWhiteColor(color, intensity: 0.5);
        final darkColor = NeumorphicColors.embossBlackColor(color, intensity: 0.5);
        final embossWhite = NeumorphicColors.dmbossWhiteColor(color, intensity: 0.5);
        final embossDark = NeumorphicColors.dmbossBlackColor(color, intensity: 0.5);

        expect(whiteColor, isA<Color>());
        expect(darkColor, isA<Color>());
        expect(embossWhite, isA<Color>());
        expect(embossDark, isA<Color>());
      }
    });

    test('handles transparent colors', () {
      const transparentColor = Color(0x00000000);
      
      final whiteColor = NeumorphicColors.embossWhiteColor(transparentColor, intensity: 0.5);
      final darkColor = NeumorphicColors.embossBlackColor(transparentColor, intensity: 0.5);
      
      expect(whiteColor, isA<Color>());
      expect(darkColor, isA<Color>());
    });
  });
}