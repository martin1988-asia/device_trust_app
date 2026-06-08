import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class FullscreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullscreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullscreenImageViewer> createState() =>
      _FullscreenImageViewerState();
}

class _FullscreenImageViewerState
    extends State<FullscreenImageViewer> {
  late PageController _controller;

  int _currentIndex = 0;
  bool _showUI = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _controller = PageController(
      initialPage: _currentIndex,
      keepPage: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // =====================================================
  // ✅ TOGGLE UI (HIDE/SHOW CONTROLS)
  // =====================================================

  void _toggleUI() {
    setState(() => _showUI = !_showUI);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.images.length;

    return Scaffold(
      backgroundColor: Colors.black,

      body: GestureDetector(
        onTap: _toggleUI,

        child: Stack(
          children: [

            // ================= IMAGE VIEW =================

            PageView.builder(
              controller: _controller,
              itemCount: total,
              onPageChanged: (i) {
                setState(() => _currentIndex = i);
              },
              itemBuilder: (_, index) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,

                  child: Center(
                    child: _buildImage(widget.images[index]),
                  ),
                );
              },
            ),

            // ================= TOP BAR =================

            if (_showUI)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [

                      // ✅ BACK
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),

                      const Spacer(),

                      // ✅ INDEX COUNTER
                      Text(
                        "${_currentIndex + 1} / $total",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),

            // ================= DOT INDICATOR =================

            if (_showUI && total > 1)
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    total,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin:
                          const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentIndex == index ? 10 : 8,
                      height: _currentIndex == index ? 10 : 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? Colors.white
                            : Colors.white30,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // ✅ IMAGE BUILDER (WEB + MOBILE SAFE)
  // =====================================================

  Widget _buildImage(String path) {
    if (kIsWeb) {
      return const Center(
        child: Icon(
          Icons.image,
          color: Colors.white,
          size: 80,
        ),
      );
      // 🔥 You can later add NetworkImage here if needed
    }

    return Image.file(
      File(path),
      fit: BoxFit.contain,
      width: double.infinity,
    );
  }
}
