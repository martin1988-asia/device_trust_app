import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

// ✅ SCREENS
import 'features/splash/splash_screen.dart';
import 'features/auth/login_page.dart';
import 'features/home/home_page.dart';
import 'features/devices/devices_page.dart';
import 'features/devices/add_device_page.dart';
import 'features/marketplace/marketplace_page.dart';
import 'features/devices/imei_benefits_page.dart';

class DeviceTrustApp extends StatelessWidget {
  const DeviceTrustApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ GLOBAL ERROR HANDLING
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: const Center(
          child: Text(
            "Something went wrong.\nPlease restart the app.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    };

    return MaterialApp(
      title: 'Device Trust',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,
      darkTheme: AppTheme.light,
      themeMode: ThemeMode.system,

      home: const SplashScreen(),

      // =====================================================
      // ✅ 🎬 CINEMATIC ROUTING ENGINE (FINAL ✅)
      // =====================================================
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case '/login':
            page = const LoginPage();
            break;
          case '/home':
            page = const HomePage();
            break;
          case '/devices':
            page = const DevicesPage();
            break;
          case '/add-device':
            page = const AddDevicePage();
            break;
          case '/marketplace':
            page = const MarketplacePage();
            break;
          case '/imei-benefits':
            page = const ImeiBenefitsPage();
            break;
          default:
            page = const UnknownRoutePage();
        }

        return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // ✅ main animation curve
            final curve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            // ✅ fade
            final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curve);

            // ✅ slide (very subtle)
            final slide = Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(curve);

            // ✅ slight cinematic zoom
            final scale = Tween<double>(
              begin: 0.97,
              end: 1.0,
            ).animate(curve);

            return FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: slide,
                child: ScaleTransition(
                  scale: scale,
                  child: child,
                ),
              ),
            );
          },
        );
      },

      // =====================================================
      // ✅ 🎨 GLOBAL BACKGROUND + ADAPTIVE LAYOUT
      // =====================================================
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 700;

            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF020617),
                    Color(0xFF0F172A),
                    Color(0xFF020617),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              // =====================================================
              // ✅ DESKTOP MODE
              // =====================================================
              child: isDesktop
                  ? Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 650),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),

                            // ✅ refined glass effect
                            color: Colors.black.withValues(alpha: 0.25),

                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: child ?? const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    )

                  // =====================================================
                  // ✅ MOBILE MODE (CRITICAL FIX ✅)
                  // =====================================================
                  : SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: child ?? const SizedBox.shrink(),
                    ),
            );
          },
        );
      },

      // =====================================================
      // ✅ SAFE FALLBACK
      // =====================================================
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const UnknownRoutePage(),
        );
      },
    );
  }
}

// =====================================================
// ✅ UNKNOWN ROUTE PAGE
// =====================================================

class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text("Page Not Found"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              "This page does not exist.",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: const Text("Go to Login"),
            ),
          ],
        ),
      ),
    );
  }
}
