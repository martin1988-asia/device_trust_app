import 'package:flutter/material.dart';

class ImeiBenefitsPage extends StatefulWidget {
  const ImeiBenefitsPage({super.key});

  @override
  State<ImeiBenefitsPage> createState() => _ImeiBenefitsPageState();
}

class _ImeiBenefitsPageState extends State<ImeiBenefitsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fade;
  late Animation<double> _slide;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _fade = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // =====================================================
  // ✅ PREMIUM INFO BLOCK
  // =====================================================
  Widget _infoBlock({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Transform.translate(
      offset: Offset(0, _slide.value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.04),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ ICON CONTAINER
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.15),
              ),
              child: Icon(icon, color: Colors.blueAccent, size: 20),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // ✅ BULLET TIP (REFINED)
  // =====================================================
  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Colors.white54),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxWidth = width > 700 ? 620.0 : width;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Why Register Your Device",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: FadeTransition(
              opacity: _fade,
              child: Transform.translate(
                offset: Offset(0, _slide.value),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= HEADER =================
                      const Text(
                        "Protect Your Device & Stay Secure",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Register your phone to unlock protection, verification, and safe transactions.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ================= BENEFITS =================
                      _infoBlock(
                        icon: Icons.security,
                        title: "Theft Protection",
                        description:
                            "Link your device to your identity and prove ownership when needed.",
                      ),

                      _infoBlock(
                        icon: Icons.verified,
                        title: "IMEI Verification",
                        description:
                            "Check if a phone is clean or blacklisted before buying or selling.",
                      ),

                      _infoBlock(
                        icon: Icons.storefront,
                        title: "Trusted Marketplace",
                        description:
                            "Only verified devices are listed, reducing fraud risks.",
                      ),

                      _infoBlock(
                        icon: Icons.receipt_long,
                        title: "Proof of Ownership",
                        description:
                            "Generate a secure digital record confirming device ownership.",
                      ),

                      _infoBlock(
                        icon: Icons.sell,
                        title: "Sell Faster",
                        description:
                            "Verified devices gain trust and sell quicker at better value.",
                      ),

                      const SizedBox(height: 28),

                      // ================= IMEI =================
                      const Text(
                        "How to Find Your IMEI",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _tip("Dial *#06# to instantly display your IMEI."),
                      _tip("Android: Settings → About Phone → Status."),
                      _tip("iPhone: Settings → General → About."),
                      _tip("Check device box or SIM tray."),

                      const SizedBox(height: 28),

                      // ================= WARNING =================
                      _infoBlock(
                        icon: Icons.warning_amber,
                        title: "Important Tip",
                        description:
                            "Always verify IMEI before buying used devices. Blacklisted phones may not work.",
                      ),

                      const SizedBox(height: 24),

                      // ================= PRICE =================
                      const Center(
                        child: Text(
                          "Only N\$10 • One-time • Lifetime protection",
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ================= CTA =================
                      Center(
                        child: SizedBox(
                          width: 260,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/add-device');
                            },
                            child: const Text(
                              "Register Device",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Center(
                        child: Text(
                          "Secure • Trusted • Verified",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
