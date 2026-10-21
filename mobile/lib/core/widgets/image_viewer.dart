import 'package:flutter/material.dart';
import 'skeleton.dart';

/// Opens [url] full screen inside the app: pinch to zoom, double-tap to zoom
/// in and out, close with the X or the back button.
Future<void> showImageViewer(BuildContext context, String url) {
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, animation, secondaryAnimation) =>
          _ImageViewerPage(url: url),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class _ImageViewerPage extends StatefulWidget {
  const _ImageViewerPage({required this.url});

  final String url;

  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage> {
  final _transform = TransformationController();
  TapDownDetails? _doubleTap;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  // Double-tap: zoom to 2.5x around the tapped point, or back to 1x
  void _toggleZoom() {
    final tap = _doubleTap;
    if (tap == null) return;
    if (_transform.value.getMaxScaleOnAxis() > 1.01) {
      _transform.value = Matrix4.identity();
      return;
    }
    final p = tap.localPosition;
    _transform.value = Matrix4.identity()
      ..translateByDouble(-p.dx * 1.5, -p.dy * 1.5, 0, 1)
      ..scaleByDouble(2.5, 2.5, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onDoubleTapDown: (d) => _doubleTap = d,
            onDoubleTap: _toggleZoom,
            child: InteractiveViewer(
              transformationController: _transform,
              minScale: 1,
              maxScale: 5,
              child: Center(
                child: Image.network(
                  widget.url,
                  fit: BoxFit.contain,
                  // A grey shimmer while it loads, not a spinner
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const SkeletonShimmer(
                          child: SkeletonBox(
                            width: double.infinity,
                            height: 320,
                            radius: 0,
                          ),
                        ),
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 56,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: 'Close',
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
