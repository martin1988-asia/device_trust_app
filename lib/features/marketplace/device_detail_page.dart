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

class _DeviceDetailPageState extends State<DeviceDetailPage>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<double> _slide;

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _fade = CurvedAnimation(
      parent: _anim,
      curve: Curves.easeOut,
    );

    _slide = Tween<double>(begin: 25, end: 0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    final width = MediaQuery.of(context).size.width;
    final maxWidth = width > 750 ? 640.0 : width;

    final images = [
      if (device.frontImage?.isNotEmpty ?? false) device.frontImage!,
      if (device.backImage?.isNotEmpty ?? false) device.backImage!,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          // ✅ BACKGROUND
          const DecoratedBox(
            decoration: BoxDecoration(
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
                child: FadeTransition(
                  opacity: _fade,
                  child: Transform.translate(
                    offset: Offset(0, _slide.value),
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white.withValues(alpha: 0.04),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _imageSection(images, width),
                                  const SizedBox(height: 20),
                                  _titleSection(device),
                                  const SizedBox(height: 16),
                                  _trustSection(device),
                                  const SizedBox(height: 16),
                                  _priceSection(device),
                                  const SizedBox(height: 14),
                                  _locationSection(device),
                                  const SizedBox(height: 16),
                                  _descriptionSection(device),
                                  const SizedBox(height: 22),
                                  _actionSection(device),
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
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ✅ IMAGE SECTION
  // =====================================================

  Widget _imageSection(List<String> images, double width) {
    if (images.isEmpty) {
      return Container(
        height: 220,
        decoration: _glassBox(),
        child: const Center(
          child: Icon(Icons.phone_android, size: 60, color: Colors.white54),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: width < 400 ? 220 : 280,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: _controller,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (_, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullscreenImageViewer(
                          images: images,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: _buildImage(images[index]),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (i) {
              final active = i == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 12 : 8,
                height: active ? 12 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? Colors.white : Colors.white30,
                ),
              );
            }),
          ),
      ],
    );
  }

  // =====================================================
  // ✅ TITLE
  // =====================================================

  Widget _titleSection(DeviceModel d) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            d.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        if (d.isClean) _badge("Clean", Colors.greenAccent),
        if (d.isStolen) _badge("Stolen", Colors.redAccent),
      ],
    );
  }

  // =====================================================
  // ✅ TRUST
  // =====================================================

  Widget _trustSection(DeviceModel d) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ TRUST SCORE HEADER
          Text(
            "Trust Score: ${d.trustScore.toInt()}",
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 10),

          // ✅ TRUST BADGES (CLEAN + SAFE ✅)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (d.isClean)
                Chip(
                  label: const Text("Clean"),
                  backgroundColor: Colors.greenAccent.withValues(alpha: 0.2),
                  labelStyle: const TextStyle(color: Colors.greenAccent),
                ),
              if (d.isStolen)
                Chip(
                  label: const Text("Stolen"),
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                  labelStyle: const TextStyle(color: Colors.redAccent),
                ),
              if (d.isVerified)
                Chip(
                  label: const Text("Verified"),
                  backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                  labelStyle: const TextStyle(color: Colors.blueAccent),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ✅ PRICE
  // =====================================================

  Widget _priceSection(DeviceModel d) {
    if (d.price == null) return const SizedBox();

    return Text(
      "N\$${d.price!.toStringAsFixed(0)}",
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.greenAccent,
      ),
    );
  }

  // =====================================================
  // ✅ LOCATION
  // =====================================================

  Widget _locationSection(DeviceModel d) {
    if (d.location == null) return const SizedBox();

    return Row(
      children: [
        const Icon(Icons.location_on, size: 18, color: Colors.white70),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            d.location!,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // ✅ DESCRIPTION
  // =====================================================

  Widget _descriptionSection(DeviceModel d) {
    if (d.description == null || d.description!.trim().isEmpty) {
      return const SizedBox();
    }

    return Text(
      d.description!,
      style: const TextStyle(
        color: Colors.white70,
        height: 1.5,
      ),
    );
  }

  // =====================================================
  // ✅ ACTIONS (UPGRADED ✅)
  // =====================================================

  Widget _actionSection(DeviceModel d) {
    if (d.contact == null) return const SizedBox();

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.chat),
            label: const Text("Chat with Seller"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(device: d),
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
            label: const Text("Call / WhatsApp"),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  // =====================================================
  // ✅ IMAGE BUILDER
  // =====================================================

  Widget _buildImage(String path) {
    if (kIsWeb) {
      return const Icon(Icons.image, size: 70, color: Colors.white70);
    }

    try {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } catch (_) {
      return const Icon(Icons.broken_image, size: 70, color: Colors.white54);
    }
  }

  // =====================================================
  // ✅ GLASS BOX HELPER
  // =====================================================

  BoxDecoration _glassBox() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white.withValues(alpha: 0.05),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
