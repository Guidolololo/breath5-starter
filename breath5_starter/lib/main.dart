import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'sections/anapanasati/anapanasati_screen.dart';
import 'sections/pranayama/pranayama_screen.dart';
import 'sections/qigong/qigong_screen.dart';
import 'sections/sufi/sufi_screen.dart';
import 'sections/tummo/tummo_screen.dart';
import 'services/app_state.dart';
import 'widgets/splash_screen.dart';
import 'widgets/onboarding_screen.dart';
import 'widgets/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize app state
  await AppState.initialize();
  
  runApp(const BreathApp());
}

class BreathApp extends StatelessWidget {
  const BreathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Breath5',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
      ),
      home: const AppWrapper(),
      routes: {
        '/home': (context) => const MainApp(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _showSplash = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash for minimum 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    // Check if first time user
    final isFirstTime = await AppState.isFirstTimeUser();
    
    if (mounted) {
      setState(() {
        _showSplash = false;
        _showOnboarding = isFirstTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }
    
    if (_showOnboarding) {
      return const OnboardingScreen();
    }
    
    return const MainApp();
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const AnapanasatiScreen(),
    const PranayamaScreen(),
    const QigongScreen(),
    const SufiScreen(),
    const TummoScreen(),
  ];

  final List<String> _titles = [
    'Anapanasati',
    'Pranayama',
    'Qigong',
    'Sufi',
    'Tummo',
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_titles[_selectedIndex]),
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.8),
        border: null,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
          child: const Icon(CupertinoIcons.settings),
        ),
      ),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.heart),
              label: 'Mindfulness',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.wind),
              label: 'Pranayama',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.circle),
              label: 'Qigong',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.star),
              label: 'Sufi',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.flame),
              label: 'Tummo',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          return CupertinoTabView(
            builder: (context) => _screens[index],
          );
        },
      ),
    );
  }
}
