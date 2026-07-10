import 'package:flutter/material.dart';

class GradientBackground extends StatefulWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<List<Color>> _gradients = [
    [const Color(0xFF0D0B1E), const Color(0xFF1A1035), const Color(0xFF0D0D0D)],
    [const Color(0xFF0D1628), const Color(0xFF0D0D0D), const Color(0xFF1A1035)],
    [const Color(0xFF0A0F20), const Color(0xFF0D1628), const Color(0xFF0D0B1E)],
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % _gradients.length;
          });
          _controller.forward(from: 0);
        }
      });
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final next = (_currentIndex + 1) % _gradients.length;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: List.generate(
                3,
                (i) => Color.lerp(
                  _gradients[_currentIndex][i],
                  _gradients[next][i],
                  _animation.value,
                )!,
              ),
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}