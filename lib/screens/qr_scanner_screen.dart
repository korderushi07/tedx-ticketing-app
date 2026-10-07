import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';

class QRScannerScreen extends StatefulWidget {
  final dynamic counter;
  final int totalScans;
  final ValueChanged<String> onScanToken;

  const QRScannerScreen({
    super.key,
    required this.counter,
    required this.totalScans,
    required this.onScanToken,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> with SingleTickerProviderStateMixin {
  late final MobileScannerController _controller;
  late final AnimationController _animController;
  late final Animation<double> _scanAnimation;

  bool _hasPermission = false;
  bool _permissionChecked = false;
  bool _isProcessing = false;
  bool _torchOn = false;
  bool _showManualEntry = false;
  final TextEditingController _manualController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() {
        _hasPermission = status.isGranted;
        _permissionChecked = true;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    _manualController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final raw = barcodes.first.rawValue;
    if (raw == null || raw.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    widget.onScanToken(raw.trim());

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  void _submitManualToken([String? overrideToken]) {
    final token = overrideToken ?? _manualController.text.trim();
    if (token.isEmpty) return;
    FocusScope.of(context).unfocus();
    widget.onScanToken(token);
  }

  @override
  Widget build(BuildContext context) {
    final counterName = widget.counter?.name ?? 'COUNTER';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    counterName.toString().toUpperCase(),
                    style: const TextStyle(
                      color: TEDxColors.tedRed,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Scan Attendee QR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code_scanner, size: 14, color: TEDxColors.tedRed),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.totalScans} SCANNED',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Camera Container
          Container(
            height: 320,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: TEDxColors.cardBorder, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (!_permissionChecked)
                    const Center(
                      child: CircularProgressIndicator(color: TEDxColors.tedRed),
                    )
                  else if (!_hasPermission)
                    _buildPermissionDeniedView()
                  else
                    MobileScanner(
                      controller: _controller,
                      onDetect: _onDetect,
                      errorBuilder: (context, error) {
                        return _buildCameraErrorView(error.toString());
                      },
                    ),

                  // Overlay Mask & Frame (if permission granted)
                  if (_hasPermission && _permissionChecked) ...[
                    // Custom Scanner Bracket & Scanning Line Overlay
                    AnimatedBuilder(
                      animation: _scanAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: ScannerOverlayPainter(
                            progress: _scanAnimation.value,
                            isProcessing: _isProcessing,
                          ),
                        );
                      },
                    ),

                    // Controls over Camera: Flashlight & Camera Switch
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              await _controller.toggleTorch();
                              setState(() {
                                _torchOn = !_torchOn;
                              });
                            },
                            icon: Icon(
                              _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                              color: _torchOn ? Colors.amber : Colors.white70,
                              size: 22,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () async {
                              await _controller.switchCamera();
                            },
                            icon: const Icon(
                              Icons.cameraswitch_rounded,
                              color: Colors.white70,
                              size: 22,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status pill at bottom of camera frame
                    Positioned(
                      bottom: 12,
                      left: 16,
                      right: 16,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isProcessing ? TEDxColors.tedRed : Colors.white24,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isProcessing) ...[
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: TEDxColors.tedRed,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Verifying Attendee...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ] else ...[
                                const Icon(
                                  Icons.center_focus_strong,
                                  size: 14,
                                  color: TEDxColors.tedRed,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Align QR inside the box',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Instructions text
          const Center(
            child: Column(
              children: [
                Text(
                  'Position the attendee QR code inside the box',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'The scanner detects tokens automatically',
                  style: TextStyle(
                    color: TEDxColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Manual Entry Toggle & Input Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TEDxColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TEDxColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.keyboard_outlined, size: 18, color: TEDxColors.tedRed),
                        SizedBox(width: 8),
                        Text(
                          'Enter ID manually',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showManualEntry = !_showManualEntry;
                        });
                      },
                      child: Text(
                        _showManualEntry ? 'HIDE' : 'ENTER TOKEN',
                        style: const TextStyle(
                          color: TEDxColors.tedRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                if (_showManualEntry) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'e.g. qr_tok_rahul_1023',
                            hintStyle: const TextStyle(color: TEDxColors.textMuted, fontSize: 13),
                            filled: true,
                            fillColor: TEDxColors.inputBg,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: TEDxColors.cardBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: TEDxColors.cardBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: TEDxColors.tedRed),
                            ),
                          ),
                          onSubmitted: (_) => _submitManualToken(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => _submitManualToken(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TEDxColors.tedRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'VERIFY',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 14),
                const Text(
                  'QUICK DEMO TOKENS FOR TESTING:',
                  style: TextStyle(
                    color: TEDxColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDemoChip('Rahul (Premium)', 'qr_tok_rahul_1023'),
                    _buildDemoChip('Rushikesh (VIP)', 'qr_tok_rushikesh_1024'),
                    _buildDemoChip('Aarav (Standard)', 'qr_tok_aarav_1026'),
                    _buildDemoChip('Invalid Token', 'invalid_token_999'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDemoChip(String label, String token) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      backgroundColor: TEDxColors.inputBg,
      side: const BorderSide(color: TEDxColors.cardBorder),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      onPressed: () => _submitManualToken(token),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined, size: 48, color: TEDxColors.tedRed),
            const SizedBox(height: 12),
            const Text(
              'Camera Access Required',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Camera access is required to scan TEDx attendee QR codes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: TEDxColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await openAppSettings();
              },
              icon: const Icon(Icons.settings, size: 16),
              label: const Text('OPEN SETTINGS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TEDxColors.tedRed,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off_outlined, size: 48, color: TEDxColors.warning),
            const SizedBox(height: 12),
            const Text(
              'Camera Unavailable',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Unable to start the camera ($error).\nPlease restart the app or retry.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: TEDxColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                _controller.start();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: TEDxColors.cardBorder),
              ),
              child: const Text('RETRY CAMERA'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the QR target overlay box with red corner brackets & scanning beam line
class ScannerOverlayPainter extends CustomPainter {
  final double progress;
  final bool isProcessing;

  ScannerOverlayPainter({
    required this.progress,
    required this.isProcessing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final frameSize = size.width * 0.65;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: frameSize,
      height: frameSize,
    );

    // Dark background mask with cutout
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)));
    final overlayPath = Path.combine(PathOperation.difference, backgroundPath, cutoutPath);

    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawPath(overlayPath, overlayPaint);

    // Corner brackets
    final bracketPaint = Paint()
      ..color = isProcessing ? Colors.greenAccent : TEDxColors.tedRed
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 24.0;
    const radius = 16.0;

    // Top Left Corner
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.top + cornerLength)
        ..lineTo(rect.left, rect.top + radius)
        ..arcToPoint(Offset(rect.left + radius, rect.top), radius: const Radius.circular(radius))
        ..lineTo(rect.left + cornerLength, rect.top),
      bracketPaint,
    );

    // Top Right Corner
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - cornerLength, rect.top)
        ..lineTo(rect.right - radius, rect.top)
        ..arcToPoint(Offset(rect.right, rect.top + radius), radius: const Radius.circular(radius))
        ..lineTo(rect.right, rect.top + cornerLength),
      bracketPaint,
    );

    // Bottom Left Corner
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.bottom - cornerLength)
        ..lineTo(rect.left, rect.bottom - radius)
        ..arcToPoint(Offset(rect.left + radius, rect.bottom), radius: const Radius.circular(radius), clockwise: false)
        ..lineTo(rect.left + cornerLength, rect.bottom),
      bracketPaint,
    );

    // Bottom Right Corner
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - cornerLength, rect.bottom)
        ..lineTo(rect.right, rect.bottom - cornerLength)
        ..lineTo(rect.right, rect.bottom - radius)
        ..arcToPoint(Offset(rect.right - radius, rect.bottom), radius: const Radius.circular(radius)),
      bracketPaint,
    );

    // Animated Scanning Line inside frame
    if (!isProcessing) {
      final lineY = rect.top + (rect.height * progress);
      final linePaint = Paint()
        ..color = TEDxColors.tedRed
        ..strokeWidth = 2.5
        ..shader = LinearGradient(
          colors: [
            TEDxColors.tedRed.withValues(alpha: 0.1),
            TEDxColors.tedRed,
            TEDxColors.tedRed.withValues(alpha: 0.1),
          ],
        ).createShader(Rect.fromLTWH(rect.left, lineY, rect.width, 2.5));

      canvas.drawLine(
        Offset(rect.left + 8, lineY),
        Offset(rect.right - 8, lineY),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isProcessing != isProcessing;
  }
}

