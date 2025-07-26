import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

enum Phase { inhale, hold, exhale, rest }

class BreathStep {
  final Phase phase;
  final int ms;
  final String? audioCue; // Optional audio file path
  final bool hapticFeedback; // Whether to trigger haptic feedback
  
  const BreathStep(
    this.phase, 
    this.ms, {
    this.audioCue,
    this.hapticFeedback = true,
  });
}

class BreathTimerConfig {
  final bool enableAudio;
  final bool enableHaptics;
  final bool enableTicks;
  final double audioVolume;
  final double tickVolume;
  final String? ambientAudio;
  
  // Precise timing configuration
  final int hapticWarningMs; // When to trigger haptic warning (default: 500ms before end)
  final int tickWarningMs;   // When to trigger tick warning (default: 200ms before end)

  const BreathTimerConfig({
    this.enableAudio = true,
    this.enableHaptics = true,
    this.enableTicks = false,
    this.audioVolume = 1.0,
    this.tickVolume = 0.3,
    this.ambientAudio,
    this.hapticWarningMs = 500,
    this.tickWarningMs = 200,
  });

  // Convenience constructors
  const BreathTimerConfig.silent() : this(
    enableAudio: false,
    enableHaptics: false,
    enableTicks: false,
  );

  const BreathTimerConfig.full() : this(
    enableAudio: true,
    enableHaptics: true,
    enableTicks: true,
    ambientAudio: 'bamboo_wind.mp3',
  );

  const BreathTimerConfig.hapticOnly() : this(
    enableAudio: false,
    enableHaptics: true,
    enableTicks: false,
  );

  /// Create a copy of this config with some values replaced
  BreathTimerConfig copyWith({
    bool? enableAudio,
    bool? enableHaptics,
    bool? enableTicks,
    double? audioVolume,
    double? tickVolume,
    String? ambientAudio,
    int? hapticWarningMs,
    int? tickWarningMs,
  }) {
    return BreathTimerConfig(
      enableAudio: enableAudio ?? this.enableAudio,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      enableTicks: enableTicks ?? this.enableTicks,
      audioVolume: audioVolume ?? this.audioVolume,
      tickVolume: tickVolume ?? this.tickVolume,
      ambientAudio: ambientAudio ?? this.ambientAudio,
      hapticWarningMs: hapticWarningMs ?? this.hapticWarningMs,
      tickWarningMs: tickWarningMs ?? this.tickWarningMs,
    );
  }
}

class AudioService {
  static AudioPlayer? _player;
  static AudioPlayer? _ambience;

  static AudioPlayer get _playerInstance => _player ??= AudioPlayer();
  static AudioPlayer get _ambienceInstance => _ambience ??= AudioPlayer();

  /// Play a short tick once
  static Future<void> tick() async {
    try {
      await _playerInstance.play(AssetSource('audio/tick.mp3'), volume: 0.3);
    } catch (e) {
      print('Error playing tick: $e');
    }
  }

  /// Loop ambience for a section
  static Future<void> playAmbience(String file) async {
    try {
      await _ambienceInstance.stop();
      await _ambienceInstance.play(AssetSource('audio/$file'), volume: 0.5);
      _ambienceInstance.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print('Error playing ambience: $e');
    }
  }

  static Future<void> stopAmbience() async {
    try {
      await _ambienceInstance.stop();
    } catch (e) {
      print('Error stopping ambience: $e');
    }
  }
}

class HapticService {
  static bool _canVibrate = false;

  static Future<void> init() async {
    _canVibrate = await Vibrate.canVibrate;
  }

  static void light() {
    if (_canVibrate) Vibrate.feedback(FeedbackType.light);
  }

  static void medium() {
    if (_canVibrate) Vibrate.feedback(FeedbackType.medium);
  }

  static void pattern(List<int> durations) {
    if (_canVibrate) {
      final durationList = durations.map((ms) => Duration(milliseconds: ms)).toList();
      Vibrate.vibrateWithPauses(durationList);
    }
  }
}

class BreathTimer {
  final List<BreathStep> pattern;
  final int cycles;
  final void Function(Phase, int remainingMs)? onTick;
  final void Function()? onCycleEnd;
  final void Function()? onComplete;
  final BreathTimerConfig config;

  // Backward compatibility - these getters use the config
  bool get enableAudio => config.enableAudio;
  bool get enableHaptics => config.enableHaptics;
  bool get enableTicks => config.enableTicks;

  Timer? _timer;
  int _cycle = 0;
  int _index = 0;
  int _remaining = 0;
  AudioPlayer? _audioPlayer;

  final _phase$ = BehaviorSubject<Phase>.seeded(Phase.inhale);
  final _cycle$ = BehaviorSubject<int>.seeded(0);

  Stream<Phase> get phaseStream => _phase$.stream;
  Stream<int> get cycleStream => _cycle$.stream;

  BreathTimer({
    required this.pattern,
    required this.cycles,
    this.onTick,
    this.onCycleEnd,
    this.onComplete,
    this.config = const BreathTimerConfig(),
  }) {
    if (config.enableAudio) {
      _audioPlayer = AudioPlayer();
    }
  }

  // Backward compatibility constructor
  BreathTimer.legacy({
    required this.pattern,
    required this.cycles,
    this.onTick,
    this.onCycleEnd,
    this.onComplete,
    bool enableAudio = true,
    bool enableHaptics = true,
    bool enableTicks = false,
  }) : config = BreathTimerConfig(
    enableAudio: enableAudio,
    enableHaptics: enableHaptics,
    enableTicks: enableTicks,
  ) {
    if (config.enableAudio) {
      _audioPlayer = AudioPlayer();
    }
  }

  void start() {
    stop(); // Ensure no previous timer is running
    _cycle = 0;
    _index = 0;
    _cycle$.add(_cycle);
    
    // Start ambient audio if configured
    if (config.ambientAudio != null) {
      AudioService.playAmbience(config.ambientAudio!);
    }
    
    _runStep();
  }

  void stop() {
    _timer?.cancel();
    _audioPlayer?.stop();
    AudioService.stopAmbience();
  }

  void dispose() {
    _timer?.cancel();
    _audioPlayer?.dispose();
    _phase$.close();
    _cycle$.close();
  }

  Future<void> _playAudioCue(String? audioPath) async {
    if (!config.enableAudio || audioPath == null || _audioPlayer == null) return;
    
    try {
      await _audioPlayer!.play(AssetSource(audioPath), volume: config.audioVolume);
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _triggerHapticFeedback() {
    if (!config.enableHaptics) return;
    HapticService.light();
  }

  Future<void> _playTick() async {
    if (!config.enableTicks) return;
    
    try {
      await AudioService.tick();
    } catch (e) {
      print('Error playing tick: $e');
    }
  }

  void _runStep() {
    if (_cycle >= cycles) {
      onComplete?.call();
      return;
    }
    
    final step = pattern[_index];
    _remaining = step.ms;
    _phase$.add(step.phase);
    
    // Play audio cue and trigger haptic feedback for phase transition
    _playAudioCue(step.audioCue);
    _triggerHapticFeedback();
    
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _remaining -= 100;
      onTick?.call(step.phase, _remaining);
      
      // Precise timing triggers
      if (config.enableHaptics && _remaining <= config.hapticWarningMs && _remaining > config.hapticWarningMs - 100) {
        HapticService.light();
      }
      
      if (config.enableTicks && _remaining <= config.tickWarningMs && _remaining > config.tickWarningMs - 100) {
        _playTick();
      }
      
      // Play tick sound every second if enabled (legacy behavior)
      if (config.enableTicks && _remaining % 1000 == 0 && _remaining > 0) {
        _playTick();
      }
      
      if (_remaining <= 0) {
        _timer?.cancel();
        _index++;
        if (_index >= pattern.length) {
          _index = 0;
          _cycle++;
          _cycle$.add(_cycle);
          onCycleEnd?.call();
        }
        _runStep();
      }
    });
  }
} 