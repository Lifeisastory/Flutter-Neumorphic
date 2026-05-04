import 'package:flutter/material.dart';
import 'package:my_neumorphic/flutter_neumorphic.dart';

import 'main_home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const NeumorphicApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      themeMode: ThemeMode.light,
      theme: NeumorphicThemeData(baseColor: Color(0xffd9d9d9), depth: 6),
      darkTheme: NeumorphicThemeData.dark(
        baseColor: Color(0xff25292e),
        depth: 6,
        // shadowWhiteColorEmboss: Color(0xff202328),
        // shadowBlackColorEmboss: Color(0xff151819),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: NeumorphicFloatingActionButton(child: const Icon(Icons.add, size: 30), onPressed: () {}),
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: <Widget>[
            NeumorphicButton(
              onPressed: () {
                print('onClick');
              },
              style: const NeumorphicStyle(shape: NeumorphicSurfaceType.flat, boxShape: NeumorphicBoxShape.circle()),
              padding: const EdgeInsets.all(12.0),
              child: Icon(Icons.favorite_border, color: _iconsColor(context)),
            ),
            NeumorphicButton(
              onPressed: () {
                NeumorphicTheme.of(context)!.themeMode = NeumorphicTheme.isUsingDark(context) ? ThemeMode.light : ThemeMode.dark;
              },
              style: NeumorphicStyle(
                color: Colors.transparent,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                depth: 5,
                intensity: 0.6,
                borderDepth: 0.8,
                borderIntensity: 1,
              ),
              padding: const EdgeInsets.all(100.0),
              child: Text('Toggle Theme', style: TextStyle(color: _textColor(context))),
            ),
            NeumorphicButton(
              onPressed: () {
                NeumorphicTheme.of(context)!.themeMode = NeumorphicTheme.isUsingDark(context) ? ThemeMode.light : ThemeMode.dark;
              },
              style: NeumorphicStyle(
                color: Colors.transparent,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                depth: 4,
                intensity: 0.4,
                borderDepth: 0.4,
                borderIntensity: 1,
              ),
              padding: const EdgeInsets.all(12.0),
              child: Text('Toggle Theme', style: TextStyle(color: _textColor(context))),
            ),
            NeumorphicButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) {
                      return const FullSampleHomePage();
                    },
                  ),
                );
              },
              style: NeumorphicStyle(
                shape: NeumorphicSurfaceType.flat,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                //border: NeumorphicBorder()
              ),
              padding: const EdgeInsets.all(12.0),
              child: Text('Go to full sample', style: TextStyle(color: _textColor(context))),
            ),
          ],
        ),
      ),
    );
  }

  Color? _iconsColor(BuildContext context) {
    final theme = NeumorphicTheme.of(context);
    if (theme!.isUsingDark) {
      return theme.current.accentColor;
    } else {
      return null;
    }
  }

  Color _textColor(BuildContext context) {
    if (NeumorphicTheme.isUsingDark(context)) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }
}
