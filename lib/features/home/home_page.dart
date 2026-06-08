import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // ✅ prevent stretching on large screens
    final maxWidth = width > 650 ? 600.0 : width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Trust"),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ================= HEADER =================

                const Text(
                  "Welcome 👋",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Manage your devices and stay safe",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 24),

                // ================= GRID =================

                GridView.count(
                  crossAxisCount: width > 500 ? 3 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.1,

                  children: [

                    _card(
                      context,
                      icon: Icons.devices,
                      title: "My Devices",
                      subtitle: "Track & manage",
                      route: '/devices',
                    ),

                    _card(
                      context,
                      icon: Icons.chat_bubble_outline,
                      title: "Chats",
                      subtitle: "Messages",
                      route: '/conversations',
                    ),

                    _card(
                      context,
                      icon: Icons.storefront,
                      title: "Marketplace",
                      subtitle: "Buy & sell",
                      route: '/marketplace',
                    ),

                    _card(
                      context,
                      icon: Icons.security,
                      title: "IMEI Protection",
                      subtitle: "Stay protected",
                      route: '/imei-benefits',
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ================= FEATURE CARD =================

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.blueAccent.withOpacity(0.08),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shield,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Stay Safe",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Always verify IMEI before buying devices.",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // ✅ DASHBOARD CARD
  // =====================================================

  Widget _card(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },

      borderRadius: BorderRadius.circular(16),

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 26, color: Colors.blueAccent),

            const Spacer(),

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
