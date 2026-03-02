import 'package:flutter/widgets.dart';
import 'package:my_neumorphic/src/neumorphic_icons.dart';
import 'package:my_neumorphic/src/widget/container.dart';

import 'button.dart';

typedef void NeumorphicCheckboxListener<T>(T value);

/// A Style used to customize a NeumorphicCheckbox
///
/// selectedDepth : the depth when checked
/// unselectedDepth : the depth when unchecked (default : theme.depth)
/// selectedColor : the color when checked (default: theme.accent)
///
class NeumorphicCheckboxStyle {
  final double? selectedDepth;
  final double? unselectedDepth;
  final bool? disableDepth;
  final double? selectedIntensity;
  final double unselectedIntensity;
  final Color? selectedColor;
  final Color? disabledColor;
  final LightSource? lightSource;
  final NeumorphicBorder border;
  final NeumorphicBoxShape? boxShape;

  const NeumorphicCheckboxStyle({
    this.selectedDepth,
    this.border = const NeumorphicBorder.none(),
    this.selectedColor,
    this.unselectedDepth,
    this.disableDepth,
    this.lightSource,
    this.disabledColor,
    this.boxShape,
    this.selectedIntensity = 1,
    this.unselectedIntensity = 0.7,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NeumorphicCheckboxStyle &&
          runtimeType == other.runtimeType &&
          selectedDepth == other.selectedDepth &&
          border == other.border &&
          unselectedDepth == other.unselectedDepth &&
          disableDepth == other.disableDepth &&
          selectedIntensity == other.selectedIntensity &&
          lightSource == other.lightSource &&
          unselectedIntensity == other.unselectedIntensity &&
          boxShape == other.boxShape &&
          selectedColor == other.selectedColor &&
          disabledColor == other.disabledColor;

  @override
  int get hashCode =>
      selectedDepth.hashCode ^
      unselectedDepth.hashCode ^
      border.hashCode ^
      lightSource.hashCode ^
      disableDepth.hashCode ^
      selectedIntensity.hashCode ^
      unselectedIntensity.hashCode ^
      boxShape.hashCode ^
      selectedColor.hashCode ^
      disabledColor.hashCode;
}

/// A Neumorphic Checkbox
///
/// takes a NeumorphicCheckboxStyle as `style`
/// takes the current checked state as `value`
///
/// notifies the parent when user interact with this widget with `onChanged`
///
/// ```
///  bool check1 = false;
///  bool check2 = false;
///  bool check3 = false;
///
///  Widget _buildChecks() {
///    return Row(
///      children: <Widget>[
///
///        NeumorphicCheckbox(
///          value: check1,
///          onChanged: (value) {
///            setState(() {
///              check1 = value;
///            });
///          },
///        ),
///
///        NeumorphicCheckbox(
///          value: check2,
///          onChanged: (value) {
///            setState(() {
///              check2 = value;
///            });
///          },
///        ),
///
///        NeumorphicCheckbox(
///          value: check3,
///          onChanged: (value) {
///            setState(() {
///              check3 = value;
///            });
///          },
///        ),
///
///      ],
///    );
///  }
/// ```
///
@immutable
class NeumorphicCheckbox extends StatelessWidget {
  final bool value;
  final NeumorphicCheckboxStyle style;
  final NeumorphicCheckboxListener onChanged;
  final isEnabled;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Duration duration;
  final Curve curve;

  NeumorphicCheckbox({
    this.style = const NeumorphicCheckboxStyle(),
    required this.value,
    required this.onChanged,
    this.curve = NeumorphicContainer.DEFAULT_CURVE,
    this.duration = NeumorphicContainer.DEFAULT_DURATION,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.margin = const EdgeInsets.all(0),
    this.isEnabled = true,
  });

  bool get isSelected => value;

  void _onClick() {
    this.onChanged(!value);
  }

  @override
  Widget build(BuildContext context) {
    final NeumorphicThemeData theme = NeumorphicTheme.currentTheme(context);
    final selectedColor = style.selectedColor ?? theme.accentColor;

    final double selectedDepth = -1 * (style.selectedDepth ?? theme.depth).abs();
    final double unselectedDepth = (style.unselectedDepth ?? theme.depth).abs();
    final double selectedIntensity = (style.selectedIntensity ?? theme.intensity).abs().clamp(NeumorphicContainer.MIN_INTENSITY, NeumorphicContainer.MAX_INTENSITY);
    final double unselectedIntensity = style.unselectedIntensity.clamp(NeumorphicContainer.MIN_INTENSITY, NeumorphicContainer.MAX_INTENSITY);

    double depth = isSelected ? selectedDepth : unselectedDepth;
    if (!isEnabled) {
      depth = 0;
    }

    Color? color = isSelected ? selectedColor : null;
    if (!isEnabled) {
      color = null;
    }

    Color iconColor = isSelected ? theme.baseColor : selectedColor;
    if (!isEnabled) {
      iconColor = theme.disabledColor;
    }

    return NeumorphicButton(
      padding: padding,
      pressed: isSelected,
      margin: margin,
      duration: duration,
      curve: curve,
      onPressed: () {
        if (isEnabled) {
          _onClick();
        }
      },
      drawSurfaceAboveChild: true,
      minDistance: selectedDepth.abs(),
      child: Icon(
        NeumorphicIcons.check,
        color: iconColor,
        size: 20.0,
      ),
      style: NeumorphicStyle(
        boxShape: style.boxShape,
        border: style.border,
        color: color,
        depth: depth,
        lightSource: style.lightSource ?? theme.lightSource,
        disableDepth: style.disableDepth,
        intensity: isSelected ? selectedIntensity : unselectedIntensity,
        shape: NeumorphicSurfaceType.flat,
      ),
    );
  }
}
