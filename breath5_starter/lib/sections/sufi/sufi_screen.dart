import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../qigong/breath_timer.dart';
import '../../widgets/tasbih_counter.dart';
import '../../services/app_state.dart';

Future<Map<String, dynamic>> loadPreset(String path) async {
  final data = await rootBundle.loadString(path);
  return json.decode(data) as Map<String, dynamic>;
}

class SufiScreen extends StatefulWidget {
  const SufiScreen({super.key});

  @override
  State<SufiScreen> createState() => _SufiScreenState();
}

class _SufiScreenState extends State<SufiScreen> {
  Map<String, dynamic>? preset;
  final ValueNotifier<int> cycle = ValueNotifier(0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load('la_illaha_zikr.json');
  }

  Future<void> _load(String file) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      preset = await loadPreset('assets/patterns/$file');
      AudioService.playAmbience(preset!['ambience']);
      cycle.value = 0;
    } catch (e) {
      // Handle error gracefully
      preset = {
        'name': 'Default Zikr',
        'steps': [
          {'phase': 'inhale', 'ms': 4000},
          {'phase': 'exhale', 'ms': 4000},
        ],
        'cycles': 33,
        'ambience': 'daf_drum.mp3',
      };
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    AudioService.stopAmbience();
    super.dispose();
  }

  void _startBreathing() {
    if (preset == null) return;
    
    final steps = (preset!['steps'] as List);
    final breathSteps = steps.map((e) => 
      BreathStep(Phase.values.byName(e['phase']), e['ms'])
    ).toList();
    
    final timer = BreathTimer(
      pattern: breathSteps,
      cycles: preset!['cycles'],
      config: const BreathTimerConfig(
        enableHaptics: true,
        enableTicks: false,
      ),
      onCycleEnd: () {
        cycle.value++;
        // Track session completion
        AppState.completeSession(
          patternName: preset!['name'],
          durationMinutes: (preset!['cycles'] * breathSteps.fold<int>(0, (sum, step) => sum + step.ms)) ~/ 60000,
        );
      },
      onComplete: () {
        _showCompletionDialog();
      },
    );
    
    timer.start();
  }

  void _showCompletionDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Zikr Complete'),
        content: const Text('You have completed your sacred practice. May peace be with you.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Alhamdulillah'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || preset == null) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(preset!['name']),
        trailing: CupertinoSegmentedControl<String>(
          children: const {
            'zikr': Text('Zikr'),
            'nafs': Text('7-Nafs')
          },
          onValueChanged: (k) => _load(k == 'zikr' ? 'la_illaha_zikr.json' : '7_nafs_purification.json'),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade50,
              Colors.purple.shade100,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sacred geometry decoration
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.purple.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        CupertinoIcons.star_fill,
                        color: Colors.purple,
                        size: 60,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Cycle counter
                ValueListenableBuilder<int>(
                  valueListenable: cycle,
                  builder: (_, c, __) => Text(
                    'Cycle $c / ${preset!['cycles']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Tasbih counter
                TasbihCounter(
                  maxBeads: preset!['cycles'],
                  onComplete: _showCompletionDialog,
                ),
                
                const SizedBox(height: 40),
                
                // Start button
                CupertinoButton.filled(
                  onPressed: _startBreathing,
                  child: const Text('Begin Sacred Practice'),
                ),
                
                const SizedBox(height: 20),
                
                // Practice description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    _getPracticeDescription(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPracticeDescription() {
    final patternName = preset!['name'] as String;
    if (patternName.contains('La-illaha')) {
      return 'The sacred remembrance of "There is no god but God" - a practice of divine unity and spiritual purification.';
    } else if (patternName.contains('7-Nafs')) {
      return 'The purification of the seven levels of the soul through conscious breathing and divine remembrance.';
    }
    return 'A sacred breathing practice for spiritual elevation and inner peace.';
  }
} 