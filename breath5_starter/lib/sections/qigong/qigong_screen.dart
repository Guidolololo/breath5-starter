import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'breath_timer.dart';
import 'breathing_pattern.dart';

class QigongScreen extends StatefulWidget {
  const QigongScreen({super.key});

  @override
  State<QigongScreen> createState() => _QigongScreenState();
}

class _QigongScreenState extends State<QigongScreen> {
  late BreathTimer _timer;
  Phase _phase = Phase.inhale;
  late final StreamSubscription<Phase> _phaseSub;
  late final BreathingPattern _pattern;

  @override
  void initState() {
    super.initState();
    
    // Use the Dan Tian Reverse pattern
    _pattern = BreathingPatterns.danTianReverse;
    
    // Create timer from pattern
    _timer = _pattern.createTimer(
      onComplete: () => setState(() => _phase = Phase.rest),
      config: const BreathTimerConfig.full().copyWith(
        hapticWarningMs: 500, // Haptic warning 500ms before phase ends
        tickWarningMs: 200,   // Tick warning 200ms before phase ends
      ),
    );
    
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
              _pattern.name,
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Duration: ${_pattern.formattedDuration}',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                fontSize: 16,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Phase: ${_phase.name}',
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              onPressed: _startBreathing,
              child: Text('Start ${_pattern.name}'),
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