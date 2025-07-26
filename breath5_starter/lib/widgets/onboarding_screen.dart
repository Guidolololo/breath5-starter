import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _userName = '';
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Breath5',
      subtitle: 'Your journey to mindful breathing begins here',
      description: 'Discover ancient breathing techniques from around the world, designed to reduce stress, improve focus, and enhance your well-being.',
      icon: CupertinoIcons.heart_fill,
      color: Colors.teal,
    ),
    OnboardingPage(
      title: 'Mindful Breathing',
      subtitle: 'Anapanasati & Pranayama',
      description: 'Learn traditional mindfulness breathing techniques that have been practiced for thousands of years to cultivate awareness and inner peace.',
      icon: CupertinoIcons.leaf_arrow_circlepath,
      color: Colors.green,
    ),
    OnboardingPage(
      title: 'Energy Practices',
      subtitle: 'Qigong & Tummo',
      description: 'Explore powerful energy cultivation practices that build vitality, generate inner heat, and strengthen your life force.',
      icon: CupertinoIcons.flame,
      color: Colors.orange,
    ),
    OnboardingPage(
      title: 'Sacred Traditions',
      subtitle: 'Sufi Zikr & Purification',
      description: 'Experience the mystical breathing practices of Sufism, designed to purify the soul and connect with the divine.',
      icon: CupertinoIcons.star,
      color: Colors.purple,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    // Save user preferences
    await AppState.setFirstTimeUser(false);
    if (_userName.isNotEmpty) {
      await AppState.setUserName(_userName);
    }
    await AppState.setSoundEnabled(_soundEnabled);
    await AppState.setHapticsEnabled(_hapticsEnabled);

    // Navigate to main app
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: List.generate(
                  _pages.length,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? _pages[_currentPage].color
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPage(page, index);
                },
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  if (_currentPage > 0)
                    CupertinoButton(
                      onPressed: _previousPage,
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox(width: 80),
                  
                  // Next/Get Started button
                  CupertinoButton.filled(
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  page.color.withOpacity(0.2),
                  page.color.withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            page.subtitle,
            style: TextStyle(
              fontSize: 18,
              color: page.color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Settings form (only on last page)
          if (index == _pages.length - 1) ...[
            _buildSettingsForm(),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsForm() {
    return Column(
      children: [
        // Name input
        CupertinoTextField(
          placeholder: 'Your name (optional)',
          value: _userName,
          onChanged: (value) {
            setState(() {
              _userName = value;
            });
          },
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Sound toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Sound effects',
              style: TextStyle(fontSize: 16),
            ),
            CupertinoSwitch(
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Haptics toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Haptic feedback',
              style: TextStyle(fontSize: 16),
            ),
            CupertinoSwitch(
              value: _hapticsEnabled,
              onChanged: (value) {
                setState(() {
                  _hapticsEnabled = value;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
} 