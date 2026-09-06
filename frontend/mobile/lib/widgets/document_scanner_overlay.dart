import 'package:flutter/material.dart';
import '../constants/theme.dart';

class DocumentScannerOverlay extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool isScanning;

  const DocumentScannerOverlay({
    super.key,
    required this.title,
    required this.subtitle,
    this.isScanning = true,
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
      duration: const Duration(milliseconds: 2200),
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
        // Document card aspect ratio (standard ID-1 card: 85.6mm x 53.98mm ~ 1.586)
        final screenWidth = constraints.maxWidth;
        final cardWidth = screenWidth * 0.88;
        final cardHeight = cardWidth / 1.58;

        return Stack(
          children: [
            // Darkened background with cutout
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _ScannerCutoutPainter(
                cardWidth: cardWidth,
                cardHeight: cardHeight,
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
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppTheme.primaryCyan,
                                Colors.white,
                                AppTheme.primaryCyan,
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryCyan.withOpacity(0.8),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Top Status & Guidelines
            Positioned(
              top: 30,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryCyan.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.radar_rounded,
                          size: 16,
                          color: AppTheme.primaryCyan,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
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

  _ScannerCutoutPainter({
    required this.cardWidth,
    required this.cardHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppTheme.primaryCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cornerPaint = Paint()
      ..color = AppTheme.primaryCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
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
    const cornerLength = 28.0;
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
      ..lineTo(rect.right, rect.top + cornerLength);
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
