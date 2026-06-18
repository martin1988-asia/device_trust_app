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
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer>
    with SingleTickerProviderStateMixin {
  late PageController _controller;
  late AnimationController _uiController;
  late Animation<double> _fade;

  int _currentIndex = 0;
  bool _showUI = true;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: _currentIndex);

    // ✅ cinematic fade
    _uiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();

    _fade = CurvedAnimation(
      parent: _uiController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _uiController.dispose();
    super.dispose();
  }

  // =====================================================
  // ✅ TOGGLE UI (SMOOTH)
  // =====================================================
  void _toggleUI() {
    setState(() => _showUI = !_showUI);

    if (_showUI) {
      _uiController.forward();
    } else {
      _uiController.reverse();
    }
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
                return _ZoomableImage(path: widget.images[index]);
              },
            ),

            // ================= TOP BAR =================
            SafeArea(
              child: FadeTransition(
                opacity: _fade,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.black.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
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
            ),

            // ================= DOT INDICATOR =================
            if (total > 1)
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fade,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      total,
                      (index) {
                        final isActive = _currentIndex == index;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 12 : 8,
                          height: isActive ? 12 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? Colors.white : Colors.white38,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// ✅ ZOOMABLE IMAGE WIDGET (NEW 🔥)
// =====================================================

class _ZoomableImage extends StatefulWidget {
  final String path;

  const _ZoomableImage({required this.path});

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final TransformationController _transformController =
      TransformationController();

  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  // ✅ DOUBLE TAP ZOOM
  void _handleDoubleTap() {
    if (_transformController.value != Matrix4.identity()) {
      _transformController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails!.localPosition;

      _transformController.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(2.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformController,
        minScale: 1,
        maxScale: 4,
        child: Center(child: _buildImage(widget.path)),
      ),
    );
  }

  Widget _buildImage(String path) {
    if (kIsWeb) {
      return const Icon(
        Icons.image,
        color: Colors.white,
        size: 80,
      );
    }

    return Image.file(
      File(path),
      fit: BoxFit.contain,
      width: double.infinity,
    );
  }
}
