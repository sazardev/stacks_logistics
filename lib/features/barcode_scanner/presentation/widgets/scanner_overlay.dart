import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';

/// Scanner overlay widget that shows the scanning frame
class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent overlay
        Container(color: AppColors.textPrimary.withOpacity(0.6)),
        // Scanning frame cutout
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Corner indicators
                _buildCornerIndicator(Alignment.topLeft),
                _buildCornerIndicator(Alignment.topRight),
                _buildCornerIndicator(Alignment.bottomLeft),
                _buildCornerIndicator(Alignment.bottomRight),
                // Scanning animation (optional)
                _buildScanningLine(),
              ],
            ),
          ),
        ),
        // Cutout for the scanning area
        Center(
          child: ClipPath(
            clipper: ScannerClipPath(),
            child: Container(
              width: 250,
              height: 250,
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCornerIndicator(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.accent, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildScanningLine() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Positioned(
          top: value * 220 + 15,
          left: 15,
          right: 15,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.accent.withOpacity(0.8),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        );
      },
      onEnd: () {
        // Restart animation by rebuilding
      },
    );
  }
}

/// Custom clipper for creating a transparent scanning area
class ScannerClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Create outer rectangle (full size)
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create inner rectangle (scanning area) - this will be cut out
    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 250,
      height: 250,
    );

    // Cut out the inner rectangle
    path.addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(12)));

    path.fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
