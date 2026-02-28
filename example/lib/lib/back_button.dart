import 'package:my_neumorphic/flutter_neumorphic.dart';

class NeumorphicBack extends StatelessWidget {
  const NeumorphicBack({super.key});

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      padding: const EdgeInsets.all(18),
      style: const NeumorphicStyle(boxShape: NeumorphicBoxShape.circle(), shape: NeumorphicSurfaceType.flat),
      child: Icon(Icons.arrow_back, color: NeumorphicTheme.isUsingDark(context) ? Colors.white70 : Colors.black87),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
