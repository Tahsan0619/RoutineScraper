import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated illustration widget for empty states
class AnimatedIllustration extends StatefulWidget {
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final double size;

  const AnimatedIllustration({
    super.key,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    this.size = 250,
  });

  @override
  State<AnimatedIllustration> createState() => _AnimatedIllustrationState();
}

class _AnimatedIllustrationState extends State<AnimatedIllustration>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Floating animation
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotate animation for decorative elements
    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      _rotateController,
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _pulseController, _rotateController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle with rotation
                Transform.rotate(
                  angle: _rotateAnimation.value,
                  child: Container(
                    width: widget.size * 0.8,
                    height: widget.size * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.primaryColor.withOpacity(0.1),
                          widget.secondaryColor.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),

                // Decorative circles
                ..._buildDecorativeCircles(),

                // Main icon with pulse
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: widget.size * 0.45,
                    height: widget.size * 0.45,
                    decoration: BoxDecoration(
                      color: widget.primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      size: widget.size * 0.25,
                      color: widget.primaryColor,
                    ),
                  ),
                ),

                // Animated paper/document elements for student
                if (widget.icon == Icons.school) ..._buildStudentElements(),

                // Animated book elements for teacher
                if (widget.icon == Icons.person) ..._buildTeacherElements(),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDecorativeCircles() {
    return [
      Positioned(
        top: widget.size * 0.1,
        right: widget.size * 0.15,
        child: Transform.rotate(
          angle: _rotateAnimation.value * 0.5,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.primaryColor.withOpacity(0.3),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: widget.size * 0.12,
        left: widget.size * 0.1,
        child: Transform.rotate(
          angle: -_rotateAnimation.value * 0.3,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.secondaryColor.withOpacity(0.3),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildStudentElements() {
    return [
      // Calendar icon
      Positioned(
        top: widget.size * 0.15,
        left: widget.size * 0.2,
        child: Transform.rotate(
          angle: math.sin(_floatAnimation.value / 5) * 0.1,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today,
              size: 24,
              color: widget.primaryColor.withOpacity(0.6),
            ),
          ),
        ),
      ),
      // Clock icon
      Positioned(
        bottom: widget.size * 0.2,
        right: widget.size * 0.15,
        child: Transform.rotate(
          angle: _rotateAnimation.value * 0.1,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.access_time,
              size: 24,
              color: widget.secondaryColor.withOpacity(0.6),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildTeacherElements() {
    return [
      // Book icon
      Positioned(
        top: widget.size * 0.2,
        right: widget.size * 0.15,
        child: Transform.rotate(
          angle: math.sin(_floatAnimation.value / 5) * 0.1,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.menu_book,
              size: 24,
              color: widget.primaryColor.withOpacity(0.6),
            ),
          ),
        ),
      ),
      // Assignment icon
      Positioned(
        bottom: widget.size * 0.18,
        left: widget.size * 0.18,
        child: Transform.rotate(
          angle: -math.sin(_floatAnimation.value / 5) * 0.1,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.assignment,
              size: 24,
              color: widget.secondaryColor.withOpacity(0.6),
            ),
          ),
        ),
      ),
    ];
  }
}
