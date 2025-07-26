import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic> _stats = {};
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  bool _darkMode = false;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final stats = await AppState.getStatistics();
    final soundEnabled = await AppState.isSoundEnabled();
    final hapticsEnabled = await AppState.isHapticsEnabled();
    final darkMode = await AppState.isDarkMode();
    final userName = await AppState.getUserName();

    setState(() {
      _stats = stats;
      _soundEnabled = soundEnabled;
      _hapticsEnabled = hapticsEnabled;
      _darkMode = darkMode;
      _userName = userName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User Profile Section
            _buildSection(
              title: 'Profile',
              children: [
                _buildTextField(
                  label: 'Name',
                  value: _userName ?? '',
                  placeholder: 'Enter your name',
                  onChanged: (value) async {
                    await AppState.setUserName(value);
                    setState(() {
                      _userName = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Statistics Section
            _buildSection(
              title: 'Your Progress',
              children: [
                _buildStatCard(
                  title: 'Total Sessions',
                  value: '${_stats['totalSessions'] ?? 0}',
                  icon: CupertinoIcons.heart_fill,
                  color: Colors.red,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  title: 'Total Minutes',
                  value: '${_stats['totalMinutes'] ?? 0}',
                  icon: CupertinoIcons.clock_fill,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  title: 'Current Streak',
                  value: '${_stats['currentStreak'] ?? 0} days',
                  icon: CupertinoIcons.flame_fill,
                  color: Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Preferences Section
            _buildSection(
              title: 'Preferences',
              children: [
                _buildSwitchTile(
                  title: 'Sound Effects',
                  value: _soundEnabled,
                  onChanged: (value) async {
                    await AppState.setSoundEnabled(value);
                    setState(() {
                      _soundEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Haptic Feedback',
                  value: _hapticsEnabled,
                  onChanged: (value) async {
                    await AppState.setHapticsEnabled(value);
                    setState(() {
                      _hapticsEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Dark Mode',
                  value: _darkMode,
                  onChanged: (value) async {
                    await AppState.setDarkMode(value);
                    setState(() {
                      _darkMode = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Favorites Section
            _buildSection(
              title: 'Favorite Patterns',
              children: [
                if (_stats['favoritePatterns'] != null)
                  ...(_stats['favoritePatterns'] as List<String>).map(
                    (pattern) => _buildFavoriteTile(pattern),
                  )
                else
                  const Text(
                    'No favorite patterns yet',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // App Info Section
            _buildSection(
              title: 'App Information',
              children: [
                _buildInfoTile(
                  title: 'Version',
                  value: '1.0.0',
                ),
                _buildInfoTile(
                  title: 'Build',
                  value: '1',
                ),
                _buildInfoTile(
                  title: 'Developer',
                  value: 'Breath5 Team',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Actions Section
            _buildSection(
              title: 'Actions',
              children: [
                CupertinoButton(
                  onPressed: _showResetDialog,
                  child: const Text(
                    'Reset All Data',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                CupertinoButton(
                  onPressed: _showAboutDialog,
                  child: const Text('About Breath5'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required String placeholder,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          value: value,
          placeholder: placeholder,
          onChanged: onChanged,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteTile(String patternName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.heart_fill,
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              patternName,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              await AppState.removeFavoritePattern(patternName);
              _loadSettings();
            },
            child: const Icon(
              CupertinoIcons.xmark_circle_fill,
              color: Colors.grey,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
          'This will permanently delete all your progress, statistics, and preferences. This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Reset'),
            onPressed: () async {
              await AppState.resetAllData();
              Navigator.pop(context);
              _loadSettings();
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('About Breath5'),
        content: const Text(
          'Breath5 is a comprehensive breathing app that brings together ancient wisdom from around the world. '
          'From mindfulness practices to energy cultivation, discover the power of conscious breathing for '
          'stress relief, focus, and spiritual growth.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
} 