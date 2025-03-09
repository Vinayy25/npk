import 'package:flutter/material.dart';
import 'package:npkapp/utils/colors.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  // Define gradient color sets that will shift subtly
  final List<List<Color>> _colorSets = [
    [
      Color(0xFFF7FAFC),
      Color(0xFFF0F4F8),
    ],
    [
      Color(0xFFF0F7FF),
      Color(0xFFEBF5FF),
    ],
    [
      Color(0xFFF2FCFA),
      Color(0xFFEAF8F5),
    ],
  ];

  int _currentColorSet = 0;
  int _nextColorSet = 1;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    // Listen to animation to change color sets
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        setState(() {
          _currentColorSet = _nextColorSet;
          _nextColorSet = (_nextColorSet + 1) % _colorSets.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  _colorSets[_currentColorSet][0],
                  _colorSets[_nextColorSet][0],
                  _controller.value,
                )!,
                Color.lerp(
                  _colorSets[_currentColorSet][1],
                  _colorSets[_nextColorSet][1],
                  _controller.value,
                )!,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative elements
              Positioned(
                top: -50,
                right: -50,
                child: _buildDecorativeCircle(
                    200, AppColors.nitrogen.withOpacity(0.05)),
              ),
              Positioned(
                bottom: 100,
                left: -80,
                child: _buildDecorativeCircle(
                    180, AppColors.phosphorus.withOpacity(0.04)),
              ),
              Positioned(
                bottom: -80,
                right: 50,
                child: _buildDecorativeCircle(
                    150, AppColors.potassium.withOpacity(0.05)),
              ),

              // Main content
              child!,
            ],
          ),
        );
      },
      child: widget.child,
    );
  }

  Widget _buildDecorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
