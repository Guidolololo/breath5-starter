import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../sections/qigong/breath_timer.dart';

class TasbihCounter extends StatefulWidget {
  final int maxBeads;
  final VoidCallback onComplete;
  const TasbihCounter({
    super.key,
    this.maxBeads = 33,
    required this.onComplete,
  });

  @override
  State<TasbihCounter> createState() => _TasbihCounterState();
}

class _TasbihCounterState extends State<TasbihCounter>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void increment() {
    if (_count >= widget.maxBeads) return;
    
    setState(() => _count++);
    _controller.forward().then((_) => _controller.reverse());
    
    // Haptic feedback every 11 counts (traditional tasbih pattern)
    if (_count % 11 == 0 && _count != 0) {
      HapticService.light();
    }
    
    if (_count >= widget.maxBeads) {
      HapticService.medium();
      widget.onComplete();
    }
  }

  void reset() {
    setState(() => _count = 0);
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _count >= widget.maxBeads;
    final progress = _count / widget.maxBeads;
    
    return Column(
      children: [
        // Progress ring
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 8,
                  ),
                ),
              ),
              // Progress circle
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? Colors.green : Colors.teal,
                  ),
                ),
              ),
              // Count text
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Text(
                      '$_count',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isComplete ? Colors.green : Colors.teal,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Progress text
        Text(
          '$_count / ${widget.maxBeads}',
          style: TextStyle(
            fontSize: 18,
            color: isComplete ? Colors.green : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Count button
        CupertinoButton.filled(
          onPressed: isComplete ? null : increment,
          child: Text(
            isComplete ? 'Complete' : 'Count',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        
        if (isComplete) ...[
          const SizedBox(height: 16),
          CupertinoButton(
            onPressed: reset,
            child: const Text('Reset'),
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Traditional tasbih info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Traditional 33-bead tasbih for sacred remembrance',
            style: TextStyle(
              fontSize: 12,
              color: Colors.teal,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
} 