import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

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
      theme: NeumorphicThemeData(
        baseColor: Color(0xffd9d9d9),
        shadowLightColor: Color(0xffe9e9e9),
        shadowDarkColor: Color(0xffbdbdbd),
        shadowLightColorEmboss: Color(0xffe8e8e8),
        shadowDarkColorEmboss: Color(0xffbebebe),
        lightSource: LightSource.topLeft,
        depth: 10,
      ),
      darkTheme: NeumorphicThemeData(
        baseColor: Color(0xff292c31),
        shadowLightColor: Color(0xff2f323b),
        shadowDarkColor: Color(0xff24262b),
        shadowLightColorEmboss: Color(0xff2f323b),
        shadowDarkColorEmboss: Color(0xff25262b),
        lightSource: LightSource.topLeft,
        depth: 6,
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
              margin: const EdgeInsets.only(top: 12),
              onPressed: () {
                NeumorphicTheme.of(context)!.themeMode = NeumorphicTheme.isUsingDark(context) ? ThemeMode.light : ThemeMode.dark;
              },
              style: NeumorphicStyle(shape: NeumorphicSurfaceType.flat, boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8))),
              padding: const EdgeInsets.all(12.0),
              child: Text('Toggle Theme', style: TextStyle(color: _textColor(context))),
            ),
            NeumorphicButton(
              margin: const EdgeInsets.only(top: 12),
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
      return theme.current!.accentColor;
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
