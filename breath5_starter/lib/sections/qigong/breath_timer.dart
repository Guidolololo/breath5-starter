import 'dart:async';
import 'package:rxdart/rxdart.dart';

enum Phase { inhale, hold, exhale, rest }

class BreathStep {
  final Phase phase;
  final int ms;
  BreathStep(this.phase, this.ms);
}

class BreathTimer {
  final List<BreathStep> pattern;
  final int cycles;
  final void Function(Phase, int remainingMs)? onTick;
  final void Function()? onCycleEnd;
  final void Function()? onComplete;

  Timer? _timer;
  int _cycle = 0;
  int _index = 0;
  int _remaining = 0;

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
  });

  void start() {
    stop(); // Ensure no previous timer is running
    _cycle = 0;
    _index = 0;
    _cycle$.add(_cycle);
    _runStep();
  }

  void stop() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
    _phase$.close();
    _cycle$.close();
  }

  void _runStep() {
    if (_cycle >= cycles) {
      onComplete?.call();
      return;
    }
    final step = pattern[_index];
    _remaining = step.ms;
    _phase$.add(step.phase);
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _remaining -= 100;
      onTick?.call(step.phase, _remaining);
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