import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  static SharedPreferences? _prefs;
  
  // Keys for SharedPreferences
  static const String _firstTimeKey = 'is_first_time_user';
  static const String _totalSessionsKey = 'total_sessions';
  static const String _totalMinutesKey = 'total_minutes';
  static const String _currentStreakKey = 'current_streak';
  static const String _lastSessionDateKey = 'last_session_date';
  static const String _favoritePatternsKey = 'favorite_patterns';
  static const String _userNameKey = 'user_name';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _hapticsEnabledKey = 'haptics_enabled';
  static const String _darkModeKey = 'dark_mode';

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // First time user check
  static Future<bool> isFirstTimeUser() async {
    return _prefs?.getBool(_firstTimeKey) ?? true;
  }

  static Future<void> setFirstTimeUser(bool isFirstTime) async {
    await _prefs?.setBool(_firstTimeKey, isFirstTime);
  }

  // Session tracking
  static Future<int> getTotalSessions() async {
    return _prefs?.getInt(_totalSessionsKey) ?? 0;
  }

  static Future<void> incrementTotalSessions() async {
    final current = await getTotalSessions();
    await _prefs?.setInt(_totalSessionsKey, current + 1);
  }

  static Future<int> getTotalMinutes() async {
    return _prefs?.getInt(_totalMinutesKey) ?? 0;
  }

  static Future<void> addSessionMinutes(int minutes) async {
    final current = await getTotalMinutes();
    await _prefs?.setInt(_totalMinutesKey, current + minutes);
  }

  // Streak tracking
  static Future<int> getCurrentStreak() async {
    return _prefs?.getInt(_currentStreakKey) ?? 0;
  }

  static Future<void> updateStreak() async {
    final today = DateTime.now();
    final lastSession = _prefs?.getString(_lastSessionDateKey);
    
    if (lastSession != null) {
      final lastDate = DateTime.parse(lastSession);
      final difference = today.difference(lastDate).inDays;
      
      if (difference == 1) {
        // Consecutive day
        final currentStreak = await getCurrentStreak();
        await _prefs?.setInt(_currentStreakKey, currentStreak + 1);
      } else if (difference > 1) {
        // Streak broken
        await _prefs?.setInt(_currentStreakKey, 1);
      }
    } else {
      // First session
      await _prefs?.setInt(_currentStreakKey, 1);
    }
    
    await _prefs?.setString(_lastSessionDateKey, today.toIso8601String());
  }

  // Favorites
  static Future<List<String>> getFavoritePatterns() async {
    return _prefs?.getStringList(_favoritePatternsKey) ?? [];
  }

  static Future<void> addFavoritePattern(String patternName) async {
    final favorites = await getFavoritePatterns();
    if (!favorites.contains(patternName)) {
      favorites.add(patternName);
      await _prefs?.setStringList(_favoritePatternsKey, favorites);
    }
  }

  static Future<void> removeFavoritePattern(String patternName) async {
    final favorites = await getFavoritePatterns();
    favorites.remove(patternName);
    await _prefs?.setStringList(_favoritePatternsKey, favorites);
  }

  // User preferences
  static Future<String?> getUserName() async {
    return _prefs?.getString(_userNameKey);
  }

  static Future<void> setUserName(String name) async {
    await _prefs?.setString(_userNameKey, name);
  }

  static Future<bool> isSoundEnabled() async {
    return _prefs?.getBool(_soundEnabledKey) ?? true;
  }

  static Future<void> setSoundEnabled(bool enabled) async {
    await _prefs?.setBool(_soundEnabledKey, enabled);
  }

  static Future<bool> isHapticsEnabled() async {
    return _prefs?.getBool(_hapticsEnabledKey) ?? true;
  }

  static Future<void> setHapticsEnabled(bool enabled) async {
    await _prefs?.setBool(_hapticsEnabledKey, enabled);
  }

  static Future<bool> isDarkMode() async {
    return _prefs?.getBool(_darkModeKey) ?? false;
  }

  static Future<void> setDarkMode(bool enabled) async {
    await _prefs?.setBool(_darkModeKey, enabled);
  }

  // Session completion
  static Future<void> completeSession({
    required String patternName,
    required int durationMinutes,
  }) async {
    await incrementTotalSessions();
    await addSessionMinutes(durationMinutes);
    await updateStreak();
  }

  // Statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    return {
      'totalSessions': await getTotalSessions(),
      'totalMinutes': await getTotalMinutes(),
      'currentStreak': await getCurrentStreak(),
      'favoritePatterns': await getFavoritePatterns(),
      'userName': await getUserName(),
    };
  }

  // Reset all data (for testing or user request)
  static Future<void> resetAllData() async {
    await _prefs?.clear();
  }
} 