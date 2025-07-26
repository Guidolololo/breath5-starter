import 'dart:convert';
import 'breath_timer.dart';

/// Represents a complete breathing pattern configuration
class BreathingPattern {
  final String name;
  final List<BreathStep> steps;
  final int cycles;
  final String? ambience;

  const BreathingPattern({
    required this.name,
    required this.steps,
    required this.cycles,
    this.ambience,
  });

  /// Create a breathing pattern from JSON
  factory BreathingPattern.fromJson(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    
    final List<BreathStep> steps = (data['steps'] as List).map((step) {
      return BreathStep(
        _parsePhase(step['phase']),
        step['ms'],
        audioCue: _getAudioCueForPhase(_parsePhase(step['phase'])),
        hapticFeedback: step['phase'] != 'rest', // No haptic for rest
      );
    }).toList();

    return BreathingPattern(
      name: data['name'],
      steps: steps,
      cycles: data['cycles'],
      ambience: data['ambience'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'steps': steps.map((step) => {
        'phase': step.phase.name,
        'ms': step.ms,
      }).toList(),
      'cycles': cycles,
      'ambience': ambience,
    };
  }

  /// Create a BreathTimer from this pattern
  BreathTimer createTimer({
    void Function(Phase, int)? onTick,
    void Function()? onCycleEnd,
    void Function()? onComplete,
    BreathTimerConfig? config,
  }) {
    return BreathTimer(
      pattern: steps,
      cycles: cycles,
      onTick: onTick,
      onCycleEnd: onCycleEnd,
      onComplete: onComplete,
      config: config ?? BreathTimerConfig.full().copyWith(
        ambientAudio: ambience,
      ),
    );
  }

  /// Parse phase string to Phase enum
  static Phase _parsePhase(String phase) {
    switch (phase.toLowerCase()) {
      case 'inhale':
        return Phase.inhale;
      case 'hold':
        return Phase.hold;
      case 'exhale':
        return Phase.exhale;
      case 'rest':
        return Phase.rest;
      default:
        throw ArgumentError('Unknown phase: $phase');
    }
  }

  /// Get appropriate audio cue for each phase
  static String? _getAudioCueForPhase(Phase phase) {
    switch (phase) {
      case Phase.inhale:
        return 'audio/inhale.mp3';
      case Phase.hold:
        return 'audio/hold.mp3';
      case Phase.exhale:
        return 'audio/exhale.mp3';
      case Phase.rest:
        return 'audio/rest.mp3';
    }
  }

  /// Get total duration of one cycle in milliseconds
  int get cycleDurationMs {
    return steps.fold(0, (total, step) => total + step.ms);
  }

  /// Get total duration of all cycles in milliseconds
  int get totalDurationMs {
    return cycleDurationMs * cycles;
  }

  /// Get formatted duration string
  String get formattedDuration {
    final totalSeconds = totalDurationMs ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Predefined breathing patterns
class BreathingPatterns {
  static const danTianReverse = BreathingPattern(
    name: 'Dan Tian Reverse 4-1-6-1',
    steps: [
      BreathStep(Phase.inhale, 4000, audioCue: 'audio/inhale.mp3', hapticFeedback: true),
      BreathStep(Phase.hold, 1000, audioCue: 'audio/hold.mp3', hapticFeedback: true),
      BreathStep(Phase.exhale, 6000, audioCue: 'audio/exhale.mp3', hapticFeedback: true),
      BreathStep(Phase.rest, 1000, audioCue: 'audio/rest.mp3', hapticFeedback: false),
    ],
    cycles: 8,
    ambience: 'bamboo_wind.mp3',
  );

  static const boxBreathing = BreathingPattern(
    name: 'Box Breathing 4-4-4-4',
    steps: [
      BreathStep(Phase.inhale, 4000, audioCue: 'audio/inhale.mp3', hapticFeedback: true),
      BreathStep(Phase.hold, 4000, audioCue: 'audio/hold.mp3', hapticFeedback: true),
      BreathStep(Phase.exhale, 4000, audioCue: 'audio/exhale.mp3', hapticFeedback: true),
      BreathStep(Phase.rest, 4000, audioCue: 'audio/rest.mp3', hapticFeedback: false),
    ],
    cycles: 5,
    ambience: 'bamboo_wind.mp3',
  );

  static const wimHof = BreathingPattern(
    name: 'Wim Hof Method',
    steps: [
      BreathStep(Phase.inhale, 2000, audioCue: 'audio/inhale.mp3', hapticFeedback: true),
      BreathStep(Phase.exhale, 2000, audioCue: 'audio/exhale.mp3', hapticFeedback: true),
    ],
    cycles: 30,
    ambience: 'bamboo_wind.mp3',
  );

  /// Get all available patterns
  static List<BreathingPattern> get all => [
    danTianReverse,
    boxBreathing,
    wimHof,
  ];

  /// Find pattern by name
  static BreathingPattern? findByName(String name) {
    try {
      return all.firstWhere((pattern) => pattern.name == name);
    } catch (e) {
      return null;
    }
  }
} 