import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../models/device_model.dart';
import 'fullscreen_image_viewer.dart';
import '../chat/chat_page.dart';

class DeviceDetailPage extends StatefulWidget {
  final DeviceModel device;

  const DeviceDetailPage({super.key, required this.device});

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    final width = MediaQuery.of(context).size.width;
    final maxWidth = width > 750 ? 620.0 : width;

    final images = [
      if (device.frontImage != null &&
          device.frontImage!.isNotEmpty)
        device.frontImage!,
      if (device.backImage != null &&
          device.backImage!.isNotEmpty)
        device.backImage!,
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Stack(
        children: [

          // ✅ BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF020617), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),

                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),

                  child: Column(
                    children: [

                      // ================= HEADER =================
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Device Details",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              // ================= IMAGES =================
                              if (images.isNotEmpty)
                                Column(
                                  children: [

                                    SizedBox(
                                      height:
                                          width < 400 ? 220 : 280,

                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(16),

                                        child: PageView.builder(
                                          controller: _controller,
                                          itemCount: images.length,
                                          onPageChanged: (i) =>
                                              setState(
                                                  () => _currentIndex = i),

                                          itemBuilder: (_, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        FullscreenImageViewer(
                                                      images: images,
                                                      initialIndex:
                                                          index,
                                                    ),
                                                  ),
                                                );
                                              },

                                              child: _buildImage(
                                                  images[index]),
                                            );
                                          },
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    if (images.length > 1)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        children: List.generate(
                                          images.length,
                                          (i) => Container(
                                            margin: const EdgeInsets
                                                .symmetric(
                                                horizontal: 4),
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              shape:
                                                  BoxShape.circle,
                                              color: _currentIndex ==
                                                      i
                                                  ? Colors.blueAccent
                                                  : Colors
                                                      .white54,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                )
                              else
                                Container(
                                  height: 220,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    color: Colors.white
                                        .withValues(alpha: 0.05),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.phone_android,
                                        size: 60,
                                        color: Colors.white54),
                                  ),
                                ),

                              const SizedBox(height: 16),

                              // ================= TITLE =================
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      device.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),

                                  if (device.status == "Clean")
                                    _badge("Clean",
                                        Colors.greenAccent),

                                  if (device.status == "Stolen")
                                    _badge(
                                        "Stolen", Colors.redAccent),
                                ],
                              ),

                              const SizedBox(height: 4),

                              Text(
                                device.model,
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),

                              const SizedBox(height: 14),

                              // ================= TRUST =================
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  color: Colors.green
                                      .withValues(alpha: 0.12),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Trust Score: ${device.trustScore.toInt()}",
                                      style: const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        color:
                                            Colors.greenAccent,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: device
                                          .getTrustBadges()
                                          .map((badge) => Chip(
                                                label: Text(
                                                  badge,
                                                  style: const TextStyle(
                                                      color:
                                                          Colors.black),
                                                ),
                                                backgroundColor:
                                                    Colors
                                                        .white70,
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // ================= PRICE =================
                              if (device.price != null)
                                Text(
                                  "N\$${device.price!.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        Colors.greenAccent,
                                  ),
                                ),

                              const SizedBox(height: 10),

                              // ================= LOCATION =================
                              if (device.location != null)
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 16,
                                        color: Colors.white70),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        device.location!,
                                        style: const TextStyle(
                                            color:
                                                Colors.white70),
                                      ),
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 14),

                              // ================= DESCRIPTION =================
                              if (device.description != null &&
                                  device.description!
                                      .trim()
                                      .isNotEmpty)
                                Text(
                                  device.description!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    height: 1.5,
                                  ),
                                ),

                              const SizedBox(height: 20),

                              // ================= ACTIONS =================
                              if (device.contact != null) ...[

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.chat),
                                    label: const Text("Chat with Seller"),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ChatPage(
                                                  device: device),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 10),

                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.phone),
                                    label: const Text(
                                        "Call / WhatsApp"),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= IMAGE =================
  Widget _buildImage(String path) {
    if (kIsWeb) {
      return const Center(
        child: Icon(Icons.image, size: 70, color: Colors.white70),
      );
    }

    try {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } catch (_) {
      return const Center(
        child: Icon(Icons.broken_image,
            size: 70, color: Colors.white54),
      );
    }
  }

  // ================= BADGE =================
  Widget _badge(String text, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
