import 'package:flutter/material.dart';

/// Gradient shell wrapper for consistent app background
class GradientShell extends StatelessWidget {
  final Widget child;
  final String title;
  final bool useDarkBackground;

  const GradientShell({
    super.key,
    required this.child,
    this.title = 'SmartRoutine',
    this.useDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: useDarkBackground
          ? const BoxDecoration(color: Colors.black)
          : const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: useDarkBackground ? Colors.black : Colors.white,
          foregroundColor: useDarkBackground ? Colors.white : Colors.black,
          elevation: useDarkBackground ? 0 : 2,
          title: Text(
            title,
            style: TextStyle(
              color: useDarkBackground ? Colors.white : Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(child: child),
      ),
    );
  }
}
