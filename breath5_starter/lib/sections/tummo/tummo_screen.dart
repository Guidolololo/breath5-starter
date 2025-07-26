import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../qigong/breath_timer.dart';

Future<bool> showTummoGate(BuildContext context) async {
  return await showCupertinoDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => CupertinoAlertDialog(
      title: const Text('Tummo Practice'),
      content: const Text(
          'This involves breath holds. Only proceed if you are ≥18 and in good health.'),
      actions: [
        CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false)),
        CupertinoDialogAction(
            child: const Text('I Agree'),
            onPressed: () => Navigator.pop(context, true)),
      ],
    ),
  ) ?? false;
}

Future<Map<String, dynamic>> loadPreset(String path) async {
  final data = await rootBundle.loadString(path);
  return json.decode(data) as Map<String, dynamic>;
}

class FireCore extends StatelessWidget {
  final double progress; // 0 → 1 in hold phase
  const FireCore({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return RadialGradient(
          colors: [
            Colors.red.withOpacity(0.1 + 0.9 * progress),
            Colors.orange.withOpacity(0.1 + 0.9 * progress),
            Colors.deepPurple.withOpacity(0.1),
          ],
          stops: const [0.4, 0.7, 1],
          radius: 0.7 + 0.3 * progress,
        ).createShader(bounds);
      },
      child: Container(
        width: 200,
        height: 200,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
  }
}

class TummoScreen extends StatefulWidget {
  const TummoScreen({super.key});

  @override
  State<TummoScreen> createState() => _TummoScreenState();
}

class _TummoScreenState extends State<TummoScreen> {
  static const _kTummoGate = 'tummo_gate_accepted';
  late BreathTimer _timer;
  late Map<String, dynamic> preset;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _checkGate();
  }

  Future<void> _checkGate() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool(_kTummoGate) ?? false;
    if (!accepted && mounted) {
      final ok = await showTummoGate(context);
      if (ok) await prefs.setBool(_kTummoGate, true);
      else return;
    }
    _loadPreset();
  }

  Future<void> _loadPreset() async {
    preset = await loadPreset('assets/patterns/tummo_classic_3cycle.json');
    final steps = (preset['steps'] as List)
        .map((e) => BreathStep(Phase.values.byName(e['phase']), e['ms']))
        .toList();
    _timer = BreathTimer(
      pattern: steps,
      cycles: preset['cycles'],
      config: const BreathTimerConfig(
        enableHaptics: true,
        enableTicks: false,
      ),
      onTick: (phase, remaining) {
        final step = steps.firstWhere((s) => s.phase == phase);
        setState(() {
          _progress = (phase == Phase.hold)
              ? 1 - (remaining / step.ms)
              : 0.0;
        });
        if (phase == Phase.hold && remaining == step.ms) {
          HapticService.medium();
        }
      },
      onComplete: () => setState(() {}),
    );
    AudioService.playAmbience(preset['ambience']);
  }

  @override
  void dispose() {
    _timer.stop();
    AudioService.stopAmbience();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          middle: Text(preset['name'] ?? 'Tummo')),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FireCore(progress: _progress),
            const SizedBox(height: 24),
            Text(_progress > 0 ? 'Hold 🔥' : 'Breathe'),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              onPressed: _timer.start,
              child: const Text('Start 3 Cycles'),
            ),
          ],
        ),
      ),
    );
  }
} 