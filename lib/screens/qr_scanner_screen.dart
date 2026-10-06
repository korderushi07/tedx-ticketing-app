import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class QRScannerScreen extends StatefulWidget {
  final VolunteerModel volunteer;
  final VoidCallback onClose;
  final Function(String ticketId) onScanComplete;

  const QRScannerScreen({
    super.key,
    required this.volunteer,
    required this.onClose,
    required this.onScanComplete,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;
  bool _isTorchOn = false;
  final _manualIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 240.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _manualIdController.dispose();
    super.dispose();
  }

  void _openManualEntryModal() {
    _manualIdController.text = 'TDX-2026-10482';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TEDxColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TEDxColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Manual Ticket Verification',
                style: TextStyle(
                  color: TEDxColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter the 12-digit Ticket ID printed on the physical badge or printed pass.',
                style: TextStyle(
                  color: TEDxColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _manualIdController,
                autofocus: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
                decoration: const InputDecoration(
                  labelText: 'Ticket ID / Reference',
                  hintText: 'TDX-2026-XXXXX',
                  prefixIcon: Icon(Icons.confirmation_number_outlined, color: TEDxColors.tedRed),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (_manualIdController.text.trim().isNotEmpty) {
                    widget.onScanComplete(_manualIdController.text.trim());
                  }
                },
                child: const Text('Verify Ticket ID'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated Camera Feed (Dark textured grid background)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF070707),
              child: CustomPaint(
                painter: CameraGridPainter(torchOn: _isTorchOn),
              ),
            ),
          ),

          // Torch glow simulation
          if (_isTorchOn)
            Positioned(
              top: 100,
              left: MediaQuery.of(context).size.width / 2 - 150,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.15),
                      blurRadius: 100,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),

          // Center Viewfinder Overlay Frame
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Animated Laser Scanner Line
                      AnimatedBuilder(
                        animation: _scanLineAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: _scanLineAnimation.value,
                            left: 10,
                            right: 10,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: TEDxColors.tedRed,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: TEDxColors.tedRed.withOpacity(0.8),
                                    blurRadius: 12,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Viewfinder Corner Brackets
                      const ViewfinderCorner(top: 0, left: 0, isTop: true, isLeft: true),
                      const ViewfinderCorner(top: 0, right: 0, isTop: true, isLeft: false),
                      const ViewfinderCorner(bottom: 0, left: 0, isTop: false, isLeft: true),
                      const ViewfinderCorner(bottom: 0, right: 0, isTop: false, isLeft: false),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Scan attendee QR code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Position the QR code inside the frame',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Top Action Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    ),
                    onPressed: widget.onClose,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.qr_code_scanner, color: TEDxColors.tedRed, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.volunteer.counterId} • ${widget.volunteer.counterName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),

          // Bottom Controls & Demo Quick Selectors Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.9),
                    Colors.black,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Operational Controls Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Torch Toggle Button
                      GestureDetector(
                        onTap: () {
                          setState(() => _isTorchOn = !_isTorchOn);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: _isTorchOn
                                ? Colors.white
                                : Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _isTorchOn ? Colors.white : Colors.white24,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                                color: _isTorchOn ? Colors.black : Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isTorchOn ? 'Flash ON' : 'Flashlight',
                                style: TextStyle(
                                  color: _isTorchOn ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Manual Entry Button
                      GestureDetector(
                        onTap: _openManualEntryModal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.keyboard_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Manual Entry',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Demo Quick Scan Selectors Banner
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: TEDxColors.cardDark.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TEDxColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DEMO QUICK SCAN TARGETS',
                          style: TextStyle(
                            color: TEDxColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _demoChip(
                                label: 'Rahul S. (AVAILABLE)',
                                color: TEDxColors.success,
                                onTap: () => widget.onScanComplete('TDX-2026-10482'),
                              ),
                              const SizedBox(width: 8),
                              _demoChip(
                                label: 'Amit P. (ALREADY CLAIMED)',
                                color: TEDxColors.warning,
                                onTap: () => widget.onScanComplete('TDX-2026-CLAIMED'),
                              ),
                              const SizedBox(width: 8),
                              _demoChip(
                                label: 'Sneha J. (NOT ELIGIBLE)',
                                color: TEDxColors.error,
                                onTap: () => widget.onScanComplete('TDX-2026-NOT-ELIGIBLE'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _demoChip({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class ViewfinderCorner extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final bool isTop;
  final bool isLeft;

  const ViewfinderCorner({
    super.key,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.isTop,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: TEDxColors.tedRed, width: 4) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: TEDxColors.tedRed, width: 4) : BorderSide.none,
            left: isLeft ? const BorderSide(color: TEDxColors.tedRed, width: 4) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: TEDxColors.tedRed, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class CameraGridPainter extends CustomPainter {
  final bool torchOn;
  CameraGridPainter({required this.torchOn});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(torchOn ? 0.08 : 0.03)
      ..strokeWidth = 1;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
