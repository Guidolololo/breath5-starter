import 'package:flutter_test/flutter_test.dart';
import 'package:breath5_starter/sections/qigong/breath_timer.dart';

void main() {
  test('completes correct cycle count', () async {
    int complete = 0;
    final timer = BreathTimer(
      pattern: [BreathStep(Phase.inhale, 100), BreathStep(Phase.exhale, 100)],
      cycles: 2,
      onComplete: () => complete++,
    );
    timer.start();
    await Future.delayed(const Duration(milliseconds: 600));
    timer.stop();
    timer.dispose(); // Clean up streams
    expect(complete, 1);
  });
} 