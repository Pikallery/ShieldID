import 'package:flutter/material.dart';
import '../constants/theme.dart';

class DocumentScannerOverlay extends StatefulWidget {
  final bool isScanning;
  final bool isDetected;

  const DocumentScannerOverlay({
    super.key,
    this.isScanning = true,
    this.isDetected = false,
  });

  @override
  State<DocumentScannerOverlay> createState() => _DocumentScannerOverlayState();
}

class _DocumentScannerOverlayState extends State<DocumentScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final cardWidth = screenWidth * 0.88;
        final cardHeight = cardWidth / 1.58;
        final activeColor =
            widget.isDetected ? AppTheme.passGreen : AppTheme.primaryCyan;

        return Stack(
          children: [
            // Darkened background with cutout
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _ScannerCutoutPainter(
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                isDetected: widget.isDetected,
                accentColor: activeColor,
              ),
            ),

            // Animated Laser Scan Line
            if (widget.isScanning)
              Center(
                child: SizedBox(
                  width: cardWidth - 16,
                  height: cardHeight - 16,
                  child: AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Align(
                        alignment: Alignment(0, (_scanAnimation.value * 2) - 1),
                        child: Container(
                          height: widget.isDetected ? 4 : 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                activeColor,
                                Colors.white,
                                activeColor,
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.9),
                                blurRadius: 14,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // QR & Document Center Target Reticle
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: activeColor.withValues(alpha: widget.isDetected ? 0.9 : 0.4),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.isDetected ? Icons.qr_code_scanner_rounded : Icons.qr_code_2_rounded,
                    color: activeColor.withValues(alpha: widget.isDetected ? 1.0 : 0.6),
                    size: 38,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScannerCutoutPainter extends CustomPainter {
  final double cardWidth;
  final double cardHeight;
  final bool isDetected;
  final Color accentColor;

  _ScannerCutoutPainter({
    required this.cardWidth,
    required this.cardHeight,
    required this.isDetected,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.72)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = accentColor.withValues(alpha: isDetected ? 0.9 : 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isDetected ? 2.5 : 1.8;

    final cornerPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isDetected ? 5.5 : 4.5
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cardWidth,
      height: cardHeight,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    // Draw background cutout
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, backgroundPaint);

    // Subtle guideline border
    canvas.drawRRect(rrect, borderPaint);

    // Corner Target Brackets
    final cornerLength = isDetected ? 34.0 : 28.0;
    const radius = 16.0;

    // Top-Left Corner
    final topLeft = Path()
      ..moveTo(rect.left, rect.top + cornerLength)
      ..lineTo(rect.left, rect.top + radius)
      ..arcToPoint(
        Offset(rect.left + radius, rect.top),
        radius: const Radius.circular(radius),
      )
      ..lineTo(rect.left + cornerLength, rect.top);
    canvas.drawPath(topLeft, cornerPaint);

    // Top-Right Corner
    final topRight = Path()
      ..moveTo(rect.right - cornerLength, rect.top)
      ..lineTo(rect.right - radius, rect.top)
      ..arcToPoint(
        Offset(rect.right, rect.top + radius),
        radius: const Radius.circular(radius),
      )
      ..lineTo(rect.right + cornerLength, rect.top);
    canvas.drawPath(topRight, cornerPaint);

    // Bottom-Left Corner
    final bottomLeft = Path()
      ..moveTo(rect.left, rect.bottom - cornerLength)
      ..lineTo(rect.left, rect.bottom - radius)
      ..arcToPoint(
        Offset(rect.left + radius, rect.bottom),
        radius: const Radius.circular(radius),
      )
      ..lineTo(rect.left + cornerLength, rect.bottom);
    canvas.drawPath(bottomLeft, cornerPaint);

    // Bottom-Right Corner
    final bottomRight = Path()
      ..moveTo(rect.right - cornerLength, rect.bottom)
      ..lineTo(rect.right - radius, rect.bottom)
      ..arcToPoint(
        Offset(rect.right, rect.bottom - radius),
        radius: const Radius.circular(radius),
      )
      ..lineTo(rect.right, rect.bottom - cornerLength);
    canvas.drawPath(bottomRight, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerCutoutPainter oldDelegate) =>
      oldDelegate.isDetected != isDetected ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.cardWidth != cardWidth ||
      oldDelegate.cardHeight != cardHeight;
}
