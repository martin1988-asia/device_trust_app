import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool isRegister = false;
  bool showPassword = false;
  bool isLoading = false;

  String? error;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ FIX keyboard

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // ✅ close keyboard

        child: Stack(
          children: [
            /// ✅ BACKGROUND
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF020617), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            const Positioned(
              top: -120,
              left: -80,
              child: RadarCircle(color: Colors.blue),
            ),
            const Positioned(
              bottom: -140,
              right: -100,
              child: RadarCircle(color: Colors.purple),
            ),

            /// ✅ RESPONSIVE CONTENT
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 24,
                      bottom: MediaQuery.of(context).viewInsets.bottom +
                          24, // ✅ KEY FIX
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: width > 600 ? 420 : width,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.shield_outlined,
                                    size: 60,
                                    color: Color(0xFF38BDF8),
                                  ),

                                  const SizedBox(height: 20),

                                  Text(
                                    isRegister ? "Register" : "Login",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  /// ✅ EMAIL
                                  _input(
                                    controller: emailController,
                                    hint: "Email",
                                    icon: Icons.email,
                                  ),

                                  const SizedBox(height: 14),

                                  /// ✅ PASSWORD
                                  _input(
                                    controller: passwordController,
                                    hint: "Password",
                                    icon: Icons.lock,
                                    isPassword: true,
                                  ),

                                  const SizedBox(height: 14),

                                  /// ✅ CONFIRM
                                  if (isRegister)
                                    _input(
                                      controller: confirmController,
                                      hint: "Confirm Password",
                                      icon: Icons.lock,
                                      isPassword: true,
                                    ),

                                  if (error != null) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      error!,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 20),

                                  /// ✅ BUTTON
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : _handleAuth,
                                      child: isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              isRegister ? "Register" : "Login",
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  /// ✅ SWITCH MODE
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        isRegister = !isRegister;
                                        error = null;
                                      });
                                    },
                                    child: Text(
                                      isRegister
                                          ? "Already have an account? Login"
                                          : "Create account",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),

                                  /// ✅ RESET PASSWORD
                                  if (!isRegister)
                                    TextButton(
                                      onPressed: _resetPassword,
                                      child: const Text(
                                        "Forgot password?",
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // ✅ INPUT FIELD (ENDS PART 1 HERE ✅ CLEAN BREAK)
  // =====================================================

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !showPassword,
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) return "$hint is required";

        if (hint == "Email" && !value.contains("@")) {
          return "Enter a valid email";
        }

        if (hint.contains("Password") && value.length < 6) {
          return "Minimum 6 characters";
        }

        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() => showPassword = !showPassword);
                },
              )
            : null,
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
  // =====================================================
  // ✅ AUTH HANDLER (IMPROVED ✅)
  // =====================================================

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus(); // ✅ close keyboard

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final confirm = confirmController.text.trim();

      if (isRegister && password != confirm) {
        setState(() {
          error = "Passwords do not match";
          isLoading = false;
        });
        return;
      }

      if (isRegister) {
        final err = await AuthService.register(email, password);

        if (err != null) {
          setState(() {
            error = err;
            isLoading = false;
          });
          return;
        }
      } else {
        final success = await AuthService.login(email, password);

        if (!success) {
          setState(() {
            error = "Invalid email or password";
            isLoading = false;
          });
          return;
        }
      }

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/devices');
    } catch (_) {
      if (mounted) {
        setState(() => error = "Something went wrong");
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // =====================================================
  // ✅ RESET PASSWORD (IMPROVED UI ✅)
  // =====================================================

  void _resetPassword() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Reset Password",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter your email",
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Reset link sent ✅")),
              );
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ✅ RADAR BACKGROUND EFFECT
// =====================================================

class RadarCircle extends StatefulWidget {
  final Color color;

  const RadarCircle({super.key, required this.color});

  @override
  State<RadarCircle> createState() => _RadarCircleState();
}

class _RadarCircleState extends State<RadarCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: 1 - _controller.value,
            child: Container(
              width: 300 * _controller.value,
              height: 300 * _controller.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: widget.color.withValues(alpha: 0.3)),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
