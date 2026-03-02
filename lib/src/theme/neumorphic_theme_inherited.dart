import 'package:flutter/material.dart';

import '../../flutter_neumorphic.dart';

export 'themes.dart';
export 'theme_wrapper.dart';

typedef NeumorphicThemeUpdater = NeumorphicThemeData Function(NeumorphicThemeData? current);

class NeumorphicThemeInherited extends InheritedWidget {
  final Widget child;
  final ThemeWrapper theme;
  final ValueChanged<ThemeWrapper> onChanged;

  NeumorphicThemeInherited({Key? key, required this.child, required this.theme, required this.onChanged}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(NeumorphicThemeInherited old) => theme != old.theme;

  NeumorphicThemeData get current {
    return theme.current;
  }

  bool get isUsingDark {
    return theme.useDark;
  }

  ThemeMode get themeMode => theme.themeMode;

  set themeMode(ThemeMode currentTheme) {
    onChanged(theme.copyWith(currentTheme: currentTheme));
  }

  void updateCurrentTheme(NeumorphicThemeData update) {
    if (theme.useDark) {
      final newTheme = theme.copyWith(darkTheme: update);
      // theme = newTheme;
      onChanged(newTheme);
    } else {
      final newTheme = theme.copyWith(theme: update);
      // theme = newTheme;
      onChanged(newTheme);
    }
  }

  void update(NeumorphicThemeUpdater themeUpdater) {
    final update = themeUpdater(theme.current);
    if (theme.useDark) {
      final newTheme = theme.copyWith(darkTheme: update);
      // theme = newTheme;
      onChanged(newTheme);
    } else {
      final newTheme = theme.copyWith(theme: update);
      // theme = newTheme;
      onChanged(newTheme);
    }
  }
}
