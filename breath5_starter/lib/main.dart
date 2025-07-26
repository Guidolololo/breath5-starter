import 'package:flutter/cupertino.dart';
import 'sections/qigong/qigong_screen.dart';
import 'sections/pranayama/pranayama_screen.dart';
import 'sections/tummo/tummo_screen.dart';
import 'sections/anapanasati/anapanasati_screen.dart';
import 'sections/sufi/sufi_screen.dart';

void main() => runApp(const BreathApp());

class BreathApp extends StatelessWidget {
  const BreathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Breath5',
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: HomeScaffold(),
    );
  }
}

class HomeScaffold extends StatelessWidget {
  const HomeScaffold({super.key});

  static const tabs = [
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.circle), label: 'Qigong'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.heart),   label: 'Pranayama'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.flame),  label: 'Tummo'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.leaf_arrow_circlepath),   label: 'Anapanasati'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.star),   label: 'Sufi'),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(items: tabs),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (_) => const QigongScreen());
          case 1:
            return CupertinoTabView(builder: (_) => const PranayamaScreen());
          case 2:
            return CupertinoTabView(builder: (_) => const TummoScreen());
          case 3:
            return CupertinoTabView(builder: (_) => const AnapanasatiScreen());
          case 4:
            return CupertinoTabView(builder: (_) => const SufiScreen());
          default:
            throw Error();
        }
      },
    );
  }
}
