import 'package:flutter/material.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2D30),
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 250, end: 300),
          duration: const Duration(seconds: 3),
          onEnd: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => login()));
          },
          builder: (context, value, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(value / 2),
              child: Image.asset(
                "assets/images/logo.jpeg",
                width: value,
                height: value,
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
    );
  }
}
