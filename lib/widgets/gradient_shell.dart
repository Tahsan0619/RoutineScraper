import 'package:flutter/material.dart';

/// Gradient shell wrapper for consistent app background
class GradientShell extends StatelessWidget {
  final Widget child;
  final String title;

  const GradientShell({
    super.key,
    required this.child,
    this.title = 'SmartRoutine',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          title: Text(title),
          centerTitle: true,
        ),
        body: SafeArea(child: child),
      ),
    );
  }
}
