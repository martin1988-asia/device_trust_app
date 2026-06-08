import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'device_detail_page.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'fullscreen_image_viewer.dart';

import '../../models/device_model.dart';
import '../../services/cloud_service.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  // ✅ IMPORTANT FIX: separate controller per rebuild safety
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// ✅ OPEN CONTACT (UNCHANGED)
  Future<void> _openContact(String contact) async {
    final phone = contact.trim();

    final Uri whatsappUri = Uri.parse("https://wa.me/$phone");
    final Uri phoneUri = Uri.parse("tel:$phone");

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
      } else if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Cannot open contact")));
    }
  }

  @override
  void dispose() {
    _pageController.dispose(); // ✅ memory safety
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ✅ HEADER (UNCHANGED)
                    Row(
                      children: [
                        const Icon(
                          Icons.store,
                          color: Color(0xFF38BDF8),
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Marketplace",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white70,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// ✅ CLOUD DATA (ONLY CHANGE)
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: CloudService.getAllDevices(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text(
                                "No devices for sale",
                                style: TextStyle(color: Colors.white70),
                              ),
                            );
                          }

                          final devices = snapshot.data!.docs
                              .map((doc) {
                                return DeviceModel.fromJson(
                                  doc.data() as Map<String, dynamic>,
                                );
                              })
                              .where((d) => d.forSale)
                              .toList();

                          return ListView.builder(
                            itemCount: devices.length,
                            itemBuilder: (context, index) {
                              final device = devices[index];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DeviceDetailPage(device: device),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),

                                    /// ✅ PREMIUM GLOW (UNCHANGED)
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0.04),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),

                                    borderRadius: BorderRadius.circular(16),

                                    /// ✅ STRONGER EDGE
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.12,
                                      ),
                                    ),

                                    /// ✅ PREMIUM SHADOW
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.45,
                                        ),
                                        blurRadius: 25,
                                        spreadRadius: -5,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // =====================================================
                                      // ✅ IMAGE SECTION (UNCHANGED ✅)
                                      // =====================================================
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 180,
                                            child: PageView(
                                              controller: _pageController,
                                              onPageChanged: (i) {
                                                setState(() {
                                                  _currentPage = i;
                                                });
                                              },
                                              children: [
                                                if (device.frontImage != null)
                                                  _buildImage(
                                                    context,
                                                    device,
                                                    0,
                                                  ),
                                                if (device.backImage != null)
                                                  _buildImage(
                                                    context,
                                                    device,
                                                    1,
                                                  ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 8),

                                          /// DOTS
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: List.generate(
                                              (device.frontImage != null &&
                                                      device.backImage != null)
                                                  ? 2
                                                  : 1,
                                              (i) => Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 4,
                                                ),
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _currentPage == i
                                                      ? Colors.blueAccent
                                                      : Colors.white.withValues(
                                                          alpha: 0.3,
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 12),
                                        ],
                                      ),

                                      // =====================================================
                                      // ✅ TITLE ROW (RESTORED ✅)
                                      // =====================================================
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              device.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),

                                          /// ✅ ORIGINAL CLEAN BADGE RESTORED
                                          if (device.status == "Clean")
                                            _buildStatusBadge(
                                              "Clean",
                                              Colors.green,
                                            ),

                                          if (device.status == "Stolen")
                                            _buildStatusBadge(
                                              "Stolen",
                                              Colors.red,
                                            ),
                                        ],
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        device.model,
                                        style: const TextStyle(
                                          color: Colors.white60,
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // =====================================================
                                      // ✅ TRUST SYSTEM (ADDED ✅)
                                      // =====================================================
                                      Text(
                                        "Trust Score: ${device.trustScore.toInt()}",
                                        style: const TextStyle(
                                          color: Colors.greenAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          if (device.isClean)
                                            const Chip(
                                              label: Text("Clean"),
                                            ),
                                          if (device.isStolen)
                                            const Chip(
                                              label: Text("Stolen"),
                                            ),
                                          if (device.isVerified)
                                            const Chip(
                                              label: Text("Verified"),
                                            ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // =====================================================
                                      // ✅ PRICE (UNCHANGED)
                                      // =====================================================
                                      if (device.price != null)
                                        Text(
                                          "N\$${device.price!.toStringAsFixed(0)}",
                                          style: const TextStyle(
                                            color: Colors.greenAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),

                                      const SizedBox(height: 10),

                                      // =====================================================
                                      // ✅ LOCATION (RESTORED ✅)
                                      // =====================================================
                                      if (device.location != null) ...[
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              color: Colors.orangeAccent,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              device.location!,
                                              style: const TextStyle(
                                                color: Colors.orangeAccent,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                      ],

                                      // =====================================================
                                      // ✅ DESCRIPTION (RESTORED ✅)
                                      // =====================================================
                                      if (device.description != null &&
                                          device.description!.trim().isNotEmpty)
                                        Text(
                                          device.description!,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            height: 1.4,
                                          ),
                                        ),

                                      const SizedBox(height: 10),

                                      /// ✅ DIVIDER (RESTORED ✅)
                                      Divider(
                                        color: Colors.white.withValues(
                                          alpha: 0.05,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      // =====================================================
                                      // ✅ CONTACT (RESTORED PREMIUM ✅)
                                      // =====================================================
                                      if (device.contact != null &&
                                          device.contact!.trim().isNotEmpty)
                                        InkWell(
                                          onTap: () =>
                                              _openContact(device.contact!),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6,
                                              horizontal: 6,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.phone,
                                                  color: Colors.blueAccent,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  device.contact!,
                                                  style: const TextStyle(
                                                    color: Colors.blueAccent,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ), // ✅ closes Container
                              ); // ✅ closes GestureDetector
                            },
                          );
                        },
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
  }

  // =====================================================
  // ✅ HELPERS (CLEANER + SAME UI)
  // =====================================================

  Widget _buildImage(BuildContext context, DeviceModel device, int index) {
    final images = [
      if (device.frontImage != null) device.frontImage!,
      if (device.backImage != null) device.backImage!,
    ];

    final imagePath = images[index];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                FullscreenImageViewer(images: images, initialIndex: index),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),

        // ✅ ✅ FIX FOR WEB + MOBILE
        child: kIsWeb
            ? Image.network(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported),
              )
            : Image.file(File(imagePath), fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
