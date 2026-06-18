import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/device_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _rotationController;
  late AnimationController _focusController;

  @override
  void initState() {
    super.initState();

    // ✅ fade in
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    // ✅ rotation continuity
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _rotationController.value = 0.35;
    _rotationController.repeat();

    // ✅ subtle pre-exit tension
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 900));

    try {
      await DeviceService.loadDevices();
    } catch (e) {
      debugPrint("❌ preload error: $e");
    }

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    // ✅ engage exit animation
    await _focusController.forward();

    // ✅ 동시에 fade OUT slightly during hero flight
    _fadeController.reverse();

    await Future.delayed(const Duration(milliseconds: 120));

    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/devices');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _rotationController.dispose();
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _rotationController,
          _focusController,
        ]),
        builder: (context, child) {
          final angle = _rotationController.value * 6.28;

          // ✅ subtle tightening
          final focusScale = 1.0 - (_focusController.value * 0.04);

          return Center(
            child: FadeTransition(
              opacity: _fadeController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: focusScale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // ✅ BACKGROUND SYSTEM (NOT part of hero)
                        Transform.rotate(
                          angle: angle,
                          child: Container(
                            width: 260,
                            height: 260,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blueAccent.withValues(alpha: 0.18),
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        Transform.rotate(
                          angle: -angle,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.purpleAccent.withValues(alpha: 0.12),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        // ✅ subtle glow layer
                        Container(
                          width: 210,
                          height: 210,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueAccent.withValues(alpha: 0.04),
                          ),
                        ),

                        // ✅ ✅ HERO OBJECT (isolated + refined)
                        Hero(
                          tag: "appLogo",
                          flightShuttleBuilder:
                              (context, animation, direction, from, to) {
                            final curved = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOutCubic,
                            );

                            return AnimatedBuilder(
                              animation: curved,
                              builder: (context, child) {
                                final scale = 1.0 + (0.04 * (1 - curved.value));

                                return Transform.scale(
                                  scale: scale,
                                  child: child,
                                );
                              },
                              child: to.widget,
                            );
                          },
                          child: Container(
                            width: 160,
                            height: 160,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: Image.asset(
                              "assets/images/device_trust_logo.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _fadeController,
                    child: const Text(
                      "Device Trust",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
