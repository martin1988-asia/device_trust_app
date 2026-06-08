import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

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
    return MaterialApp(
      title: 'Device Trust',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,
      darkTheme: AppTheme.light,
      themeMode: ThemeMode.system,

      // ✅ ✅ ✅ PRODUCTION BUILDER (FULL FIX)
      builder: (context, child) {
        // ✅ GLOBAL ERROR HANDLER
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Scaffold(
            body: Container(
              color: const Color(0xFF020617),
              child: const Center(
                child: Text(
                  "Something went wrong.\nPlease restart the app.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        };

        return LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth =
                constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;

            return Container(
              // ✅ ✅ THIS FIXES THE WHITE SIDES
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF020617),
                    Color(0xFF0F172A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),

                  // ✅ Slight padding for better aesthetics
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),

                      // ✅ Keeps your screens clean and contained
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },

      initialRoute: '/login',

      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
        '/devices': (_) => const DevicesPage(),
        '/add-device': (_) => const AddDevicePage(),
        '/marketplace': (_) => const MarketplacePage(),
        '/imei-benefits': (_) => const ImeiBenefitsPage(),
      },

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
      appBar: AppBar(title: const Text("Page Not Found")),

      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          },
          child: const Text("Go to Login"),
        ),
      ),
    );
  }
}
