import 'package:flutter/material.dart';

import '../../flutter_neumorphic.dart';

export 'neumorphic_theme_inherited.dart';
export 'themes.dart';
export 'theme_wrapper.dart';

/// The NeumorphicTheme (provider)
/// 1. Defines the used neumorphic theme used in child widgets
///
///   @see NeumorphicThemeData
///
///   NeumorphicTheme(
///     theme: NeumorphicThemeData(...),
///     darkTheme: NeumorphicThemeData(...),
///     currentTheme: CurrentTheme.LIGHT,
///     child: ...
///
/// 2. Provide by static methods the current theme
///
///   NeumorphicThemeData theme = NeumorphicTheme.getCurrentTheme(context);
///
/// 3. Provide by static methods the current theme's colors
///
///   Color baseColor = NeumorphicTheme.baseColor(context);
///   Color accent = NeumorphicTheme.accentColor(context);
///   Color variant = NeumorphicTheme.variantColor(context);
///
/// 4. Tells if the current theme is dark
///
///   bool dark = NeumorphicTheme.isUsingDark(context);
///
/// 5. Provides a way to update the current theme
///
///   NeumorphicTheme.of(context).updateCurrentTheme(
///     NeumorphicThemeData(
///       /* new values */
///     )
///   )
///
class NeumorphicTheme extends StatefulWidget {
  static NeumorphicThemeData _globalTheme = neumorphicDefaultTheme;
  static NeumorphicThemeData _globalDarkTheme = neumorphicDefaultDarkTheme;
  static bool _syncWithAppTheme = false;

  /// 使用这个函数来同步app和此包的主题，避免直接侵入地在组件树顶部包裹NeumorphicTheme
  /// 如果调用过这个函数，又包裹了NeumorphicTheme，仍会优先使用app的主题模式
  static void initializeNeumorphicTheme({NeumorphicThemeData? theme, NeumorphicThemeData? darkTheme, bool syncWithAppTheme = false}) {
    _globalTheme = theme ?? _globalTheme;
    _globalDarkTheme = darkTheme ?? _globalDarkTheme;
    _syncWithAppTheme = syncWithAppTheme;
  }

  final NeumorphicThemeData theme;
  final NeumorphicThemeData darkTheme;
  final Widget child;
  final ThemeMode themeMode;

  NeumorphicTheme({
    Key? key,
    required this.child,
    this.theme = neumorphicDefaultTheme,
    this.darkTheme = neumorphicDefaultDarkTheme,
    this.themeMode = ThemeMode.system,
  });

  @override
  _NeumorphicThemeState createState() => _NeumorphicThemeState();

  static NeumorphicThemeInherited? of(BuildContext context) {
    try {
      return context.dependOnInheritedWidgetOfExactType<NeumorphicThemeInherited>();
    } catch (t) {
      return null;
    }
  }

  static void update(BuildContext context, NeumorphicThemeUpdater updater) {
    final theme = of(context);
    if (theme == null) return;
    return theme.update(updater);
  }

  /// 先判断是否初始化为与app主题同步，再判断是否包裹NeumorphicTheme
  static bool isUsingDark(BuildContext context) {
    if (_syncWithAppTheme) {
      return Theme.of(context).brightness == Brightness.dark ? true : false;
    }
    final theme = of(context);
    if (theme != null) {
      return theme.isUsingDark;
    }
    return false;
  }

  static Color accentColor(BuildContext context) {
    return currentTheme(context).accentColor;
  }

  static Color baseColor(BuildContext context) {
    return currentTheme(context).baseColor;
  }

  static Color variantColor(BuildContext context) {
    return currentTheme(context).variantColor;
  }

  static Color disabledColor(BuildContext context) {
    return currentTheme(context).disabledColor;
  }

  static double? intensity(BuildContext context) {
    return currentTheme(context).intensity;
  }

  static double? embossDepth(BuildContext context) {
    return currentTheme(context).depth;
  }

  static double? debossDepth(BuildContext context) {
    // if (currentTheme(context).depth == null) return null;
    return -currentTheme(context).depth.abs();
  }

  static Color defaultTextColor(BuildContext context) {
    return currentTheme(context).defaultTextColor;
  }

  static NeumorphicThemeData currentTheme(BuildContext context) {
    if (_syncWithAppTheme) {
      return Theme.of(context).brightness == Brightness.dark ? _globalDarkTheme : _globalTheme;
    }
    final provider = of(context);
    if (provider != null) {
      return provider.current;
    }
    return _globalTheme;
  }
}

double applyThemeDepthEnable({required BuildContext context, required bool styleEnableDepth, required double depth}) {
  final NeumorphicThemeData theme = NeumorphicTheme.currentTheme(context);
  return wrapDepthWithThemeData(themeData: theme, styleEnableDepth: styleEnableDepth, depth: depth);
}

double wrapDepthWithThemeData({required NeumorphicThemeData themeData, required bool styleEnableDepth, required double depth}) {
  if (themeData.disableDepth) {
    return 0;
  } else {
    return depth;
  }
}

class _NeumorphicThemeState extends State<NeumorphicTheme> {
  late ThemeWrapper _themeHost;

  @override
  void initState() {
    super.initState();
    _themeHost = ThemeWrapper(theme: widget.theme, themeMode: widget.themeMode, darkTheme: widget.darkTheme);
  }

  @override
  void didUpdateWidget(NeumorphicTheme oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _themeHost = ThemeWrapper(theme: widget.theme, themeMode: widget.themeMode, darkTheme: widget.darkTheme);
    });
  }

  @override
  Widget build(BuildContext context) {
    /// 当调用NeumorphicThemeInherited里的update相关方法时，会调用这里传入的onChanged()，这时触发setState()，build()
    /// 会重建NeumorphicThemeInherited，theme也就被更新了
    return NeumorphicThemeInherited(
      theme: _themeHost,
      onChanged: (value) {
        setState(() => _themeHost = value);
      },
      child: widget.child,
    );
  }
}
