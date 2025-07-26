import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../qigong/breath_timer.dart';
import 'dart:async';

class BreathCircle extends StatelessWidget {
  final double scale; // from 0.8 → 1.2 using camera or manual slider
  const BreathCircle({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 100 * scale,
      height: 100 * scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.teal, width: 3),
      ),
    );
  }
}

class StageTimer {
  final List<Map<String, dynamic>> stages;
  final void Function(int stageIndex) onStageStart;
  final void Function() onBell;
  final void Function()? onComplete;

  StageTimer(
    this.stages,
    this.onStageStart,
    this.onBell, {
    this.onComplete,
  });

  Timer? _timer;
  int _current = 0;
  bool _isRunning = false;

  void start() {
    _isRunning = true;
    _current = 0;
    _runStage();
  }

  void _runStage() {
    if (!_isRunning || _current >= stages.length) {
      _isRunning = false;
      onComplete?.call();
      return;
    }
    final stage = stages[_current];
    onStageStart(_current);
    if (stage['bell'] == true) onBell();
    _timer = Timer(Duration(milliseconds: stage['duration']), () {
      _current++;
      _runStage();
    });
  }

  void stop() {
    _isRunning = false;
    _timer?.cancel();
  }
}

Future<Map<String, dynamic>> loadPreset(String path) async {
  final data = await rootBundle.loadString(path);
  return json.decode(data) as Map<String, dynamic>;
}

class AnapanasatiScreen extends StatefulWidget {
  const AnapanasatiScreen({super.key});

  @override
  State<AnapanasatiScreen> createState() => _AnapanasatiScreenState();
}

class _AnapanasatiScreenState extends State<AnapanasatiScreen> {
  late Map<String, dynamic> preset;
  int _stage = 0;
  bool _silent = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    preset = await loadPreset('assets/patterns/anapanasati_16step.json');
    _silent = preset['silent'] ?? true;
    AudioService.playAmbience(preset['ambience']);
  }

  void _start() {
    StageTimer(
      List<Map<String, dynamic>>.from(preset['stages']),
      (i) => setState(() => _stage = i),
      () => AudioService.tick(), // bell
    ).start();
  }

  @override
  Widget build(BuildContext context) {
    final stage = preset['stages'][_stage];
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Anapanasati ${_stage + 1}/4'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_silent)
              BreathCircle(scale: 1.0 + 0.2 * sin(DateTime.now().millisecond / 500))
            else
              const Text('Watch your breath'),
            const SizedBox(height: 24),
            Text(stage['title'], style: CupertinoTheme.of(context).textTheme.textStyle),
            const SizedBox(height: 24),
            CupertinoButton.filled(onPressed: _start, child: const Text('Start Stages')),
          ],
        ),
      ),
    );
  }
} 