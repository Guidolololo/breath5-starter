import 'package:flutter_test/flutter_test.dart';
import 'package:breath5_starter/sections/qigong/breathing_pattern.dart';
import 'package:breath5_starter/sections/qigong/breath_timer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BreathingPattern', () {
    test('creates pattern from JSON', () {
      const json = '''
      {
        "name": "Dan Tian Reverse 4-1-6-1",
        "steps": [
          {"phase":"inhale","ms":4000},
          {"phase":"hold","ms":1000},
          {"phase":"exhale","ms":6000},
          {"phase":"rest","ms":1000}
        ],
        "cycles": 8,
        "ambience": "bamboo_wind.mp3"
      }
      ''';

      final pattern = BreathingPattern.fromJson(json);

      expect(pattern.name, 'Dan Tian Reverse 4-1-6-1');
      expect(pattern.steps.length, 4);
      expect(pattern.cycles, 8);
      expect(pattern.ambience, 'bamboo_wind.mp3');
      expect(pattern.steps[0].phase.name, 'inhale');
      expect(pattern.steps[0].ms, 4000);
    });

    test('calculates duration correctly', () {
      const pattern = BreathingPatterns.danTianReverse;
      
      expect(pattern.cycleDurationMs, 12000); // 4+1+6+1 = 12 seconds
      expect(pattern.totalDurationMs, 96000); // 12 * 8 cycles = 96 seconds
      expect(pattern.formattedDuration, '1:36'); // 1 minute 36 seconds
    });

    test('creates timer from pattern', () {
      const pattern = BreathingPatterns.danTianReverse;
      final timer = pattern.createTimer(
        config: const BreathTimerConfig.silent(),
      );
      
      expect(timer, isA<BreathTimer>());
    });

    test('converts to JSON', () {
      const pattern = BreathingPatterns.danTianReverse;
      final json = pattern.toJson();
      
      expect(json['name'], 'Dan Tian Reverse 4-1-6-1');
      expect(json['cycles'], 8);
      expect(json['ambience'], 'bamboo_wind.mp3');
      expect(json['steps'], isA<List>());
    });
  });

  group('BreathingPatterns', () {
    test('has predefined patterns', () {
      expect(BreathingPatterns.all.length, 3);
      expect(BreathingPatterns.danTianReverse.name, 'Dan Tian Reverse 4-1-6-1');
      expect(BreathingPatterns.boxBreathing.name, 'Box Breathing 4-4-4-4');
      expect(BreathingPatterns.wimHof.name, 'Wim Hof Method');
    });

    test('finds pattern by name', () {
      final pattern = BreathingPatterns.findByName('Dan Tian Reverse 4-1-6-1');
      expect(pattern, isNotNull);
      expect(pattern!.name, 'Dan Tian Reverse 4-1-6-1');
    });

    test('returns null for unknown pattern', () {
      final pattern = BreathingPatterns.findByName('Unknown Pattern');
      expect(pattern, isNull);
    });
  });
} 