import 'package:flutter_test/flutter_test.dart';
import 'package:breath5_starter/sections/qigong/breath_timer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('completes correct cycle count', () async {
    int complete = 0;
    final timer = BreathTimer(
      pattern: [
        BreathStep(Phase.inhale, 100),
        BreathStep(Phase.exhale, 100),
      ],
      cycles: 2,
      onComplete: () => complete++,
      config: const BreathTimerConfig.silent(), // Disable all audio/haptics for testing
    );
    timer.start();
    await Future.delayed(const Duration(milliseconds: 600));
    timer.stop();
    timer.dispose(); // Clean up streams
    expect(complete, 1);
  });

  test('creates breath step with audio and haptic options', () {
    final step = BreathStep(
      Phase.inhale,
      4000,
      audioCue: 'audio/inhale.mp3',
      hapticFeedback: true,
    );
    
    expect(step.phase, Phase.inhale);
    expect(step.ms, 4000);
    expect(step.audioCue, 'audio/inhale.mp3');
    expect(step.hapticFeedback, true);
  });

  test('breath timer configuration options', () {
    final timer = BreathTimer(
      pattern: [BreathStep(Phase.inhale, 1000)],
      cycles: 1,
      config: const BreathTimerConfig.silent(),
    );
    
    expect(timer.enableTicks, false);
    expect(timer.enableAudio, false);
    expect(timer.enableHaptics, false);
    timer.dispose(); // Clean up
  });

  test('breath timer config convenience constructors', () {
    const silentConfig = BreathTimerConfig.silent();
    const fullConfig = BreathTimerConfig.full();
    const hapticOnlyConfig = BreathTimerConfig.hapticOnly();
    
    expect(silentConfig.enableAudio, false);
    expect(silentConfig.enableHaptics, false);
    expect(silentConfig.enableTicks, false);
    
    expect(fullConfig.enableAudio, true);
    expect(fullConfig.enableHaptics, true);
    expect(fullConfig.enableTicks, true);
    expect(fullConfig.ambientAudio, 'bamboo_wind.mp3');
    
    expect(hapticOnlyConfig.enableAudio, false);
    expect(hapticOnlyConfig.enableHaptics, true);
    expect(hapticOnlyConfig.enableTicks, false);
  });

  test('breath timer config timing options', () {
    const customConfig = BreathTimerConfig(
      enableHaptics: true,
      enableTicks: true,
      hapticWarningMs: 1000,
      tickWarningMs: 300,
    );
    
    expect(customConfig.hapticWarningMs, 1000);
    expect(customConfig.tickWarningMs, 300);
    expect(customConfig.enableHaptics, true);
    expect(customConfig.enableTicks, true);
  });

  test('breath timer config copyWith method', () {
    const baseConfig = BreathTimerConfig.full();
    final modifiedConfig = baseConfig.copyWith(
      hapticWarningMs: 800,
      tickWarningMs: 150,
    );
    
    expect(modifiedConfig.enableAudio, true); // Kept from full()
    expect(modifiedConfig.enableHaptics, true); // Kept from full()
    expect(modifiedConfig.enableTicks, true); // Kept from full()
    expect(modifiedConfig.ambientAudio, 'bamboo_wind.mp3'); // Kept from full()
    expect(modifiedConfig.hapticWarningMs, 800); // Modified
    expect(modifiedConfig.tickWarningMs, 150); // Modified
  });
} 