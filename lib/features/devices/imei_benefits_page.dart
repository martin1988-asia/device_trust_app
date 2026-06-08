import 'package:flutter/material.dart';

class ImeiBenefitsPage extends StatelessWidget {
  const ImeiBenefitsPage({super.key});

  // =====================================================
  // ✅ INFO BLOCK (PREMIUM)
  // =====================================================

  Widget _infoBlock({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent.withValues(alpha: 0.15),
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
    );
  }

  // =====================================================
  // ✅ BULLET TIP
  // =====================================================

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Colors.white54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxWidth = width > 700 ? 600.0 : width;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        // ✅ FIXED VISIBILITY
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

            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ================= HEADER =================

                  const Text(
                    "Protect Your Device & Stay Secure",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Register your phone to unlock protection, verification, and safe transactions.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ================= BENEFITS =================

                  _infoBlock(
                    icon: Icons.security,
                    title: "Theft Protection",
                    description:
                        "Your device is linked to your identity, helping prove ownership in case of loss or theft.",
                  ),

                  _infoBlock(
                    icon: Icons.verified,
                    title: "IMEI Verification",
                    description:
                        "Check if a phone is clean, blacklisted, or previously reported before buying or selling.",
                  ),

                  _infoBlock(
                    icon: Icons.storefront,
                    title: "Trusted Marketplace",
                    description:
                        "Only verified devices can be listed, protecting buyers and sellers from fraud.",
                  ),

                  _infoBlock(
                    icon: Icons.receipt_long,
                    title: "Proof of Ownership",
                    description:
                        "Generate a digital record that confirms you are the rightful owner of the device.",
                  ),

                  _infoBlock(
                    icon: Icons.sell,
                    title: "Sell Faster",
                    description:
                        "Verified devices gain trust and sell quicker at better prices.",
                  ),

                  const SizedBox(height: 28),

                  // ================= IMEI SECTION =================

                  const Text(
                    "How to Find Your IMEI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _tip("Dial *#06# on your phone to instantly see your IMEI."),
                  _tip("Android: Settings → About Phone → Status → IMEI."),
                  _tip("iPhone: Settings → General → About → IMEI."),
                  _tip("Check the phone box or SIM tray if needed."),

                  const SizedBox(height: 28),

                  // ================= WARNING =================

                  _infoBlock(
                    icon: Icons.warning_amber,
                    title: "Important Tip",
                    description:
                        "Always verify the IMEI before buying a used phone. Blacklisted devices may not work on mobile networks.",
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

                  // ================= BUTTON =================

                  Center(
                    child: SizedBox(
                      width: 260,
                      height: 52,

                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/add-device');
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),

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
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
