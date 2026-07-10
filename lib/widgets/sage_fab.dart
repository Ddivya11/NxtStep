import 'dart:async';

import 'package:flutter/material.dart';
import '../screens/sage_chat_screen.dart';

class SageFAB extends StatefulWidget {
  const SageFAB({super.key});

  @override
  State<SageFAB> createState() => _SageFABState();
}

class _SageFABState extends State<SageFAB> with SingleTickerProviderStateMixin {
  bool _showBubble = false;

  late final AnimationController _controller;
  late final Animation<double> _rotation;

  Timer? _wiggleTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _rotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.03), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.03, end: 0.03), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.03, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Show the speech bubble ONLY ONCE after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      setState(() {
        _showBubble = true;
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;

        setState(() {
          _showBubble = false;
        });
      });
    });

    // Robot wiggle every 8 seconds
    _wiggleTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      if (!mounted) return;

      await _controller.forward();
      await _controller.reverse();
    });
  }

  @override
  void dispose() {
    _wiggleTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedOpacity(
          opacity: _showBubble ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8),
              ],
            ),
            child: const Text(
              "💬 Chat with Sage!",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        RotationTransition(
          turns: _rotation,
          child: FloatingActionButton(
            heroTag: "sage",
            backgroundColor: const Color(0xFFC8A8E9),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, animation, __) => const SageChatScreen(),
                  transitionsBuilder: (_, animation, __, child) {
                    return SlideTransition(
                      position:
                          Tween(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 350),
                ),
              );
            },
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }
}
