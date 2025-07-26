import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'breath_timer.dart';

class QigongScreen extends StatefulWidget {
  const QigongScreen({super.key});

  @override
  State<QigongScreen> createState() => _QigongScreenState();
}

class _QigongScreenState extends State<QigongScreen> {
  late BreathTimer _timer;
  Phase _phase = Phase.inhale;
  late final StreamSubscription<Phase> _phaseSub;

  @override
  void initState() {
    super.initState();
    
    // Modern approach using BreathTimerConfig
    _timer = BreathTimer(
      pattern: [
        BreathStep(
          Phase.inhale,
          4000,
          audioCue: 'audio/inhale.mp3',
          hapticFeedback: true,
        ),
        BreathStep(
          Phase.hold,
          1000,
          audioCue: 'audio/hold.mp3',
          hapticFeedback: true,
        ),
        BreathStep(
          Phase.exhale,
          6000,
          audioCue: 'audio/exhale.mp3',
          hapticFeedback: true,
        ),
        BreathStep(
          Phase.rest,
          1000,
          audioCue: 'audio/rest.mp3',
          hapticFeedback: false, // No haptic for rest phase
        ),
      ],
      cycles: 8,
      onComplete: () => setState(() => _phase = Phase.rest),
      config: const BreathTimerConfig.full().copyWith(
        hapticWarningMs: 500, // Haptic warning 500ms before phase ends
        tickWarningMs: 200,   // Tick warning 200ms before phase ends
      ),
    );
    
    // Alternative legacy approach (not recommended):
    // _timer = BreathTimer.legacy(
    //   pattern: [...],
    //   cycles: 8,
    //   onComplete: () => setState(() => _phase = Phase.rest),
    //   enableHaptics: true,
    //   enableTicks: true,
    // );
    
    _phaseSub = _timer.phaseStream.listen((p) {
      setState(() => _phase = p);
    });
  }

  @override
  void dispose() {
    _phaseSub.cancel();
    _timer.dispose();
    super.dispose();
  }

  void _startBreathing() {
    // Start the breathing timer (ambient audio is handled by config)
    _timer.start();
  }

  void _stopBreathing() {
    _timer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Qigong')),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Phase: ${_phase.name}',
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              onPressed: _startBreathing,
              child: const Text('Start 4-1-6-1'),
            ),
            const SizedBox(height: 10),
            CupertinoButton(
              onPressed: _stopBreathing,
              child: const Text('Stop'),
            ),
          ],
        ),
      ),
    );
  }
} 