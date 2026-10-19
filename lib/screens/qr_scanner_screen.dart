import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class QRScannerScreen extends StatefulWidget {
  final CounterInfo counter;
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

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _controller;
  bool _hasPermission = false;
  bool _permissionChecked = false;
  bool _isProcessing = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
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
    _controller.dispose();
    super.dispose();
  }

  void _submitTicketId(String value) {
    if (_isProcessing) return;
    final ticketId = value.trim();
    if (ticketId.isEmpty) {
      return;
    }

    setState(() => _isProcessing = true);
    widget.onScanToken(ticketId);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    });
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final raw = barcodes.first.rawValue;
    if (raw == null || raw.trim().isEmpty) return;

    _submitTicketId(raw);
  }

  @override
  Widget build(BuildContext context) {
    final counterCode = widget.counter.code;
    final counterName = widget.counter.name;
    final benefit = widget.counter.benefit;

    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenHeight < 700;

    // Adaptively scale camera height & viewfinder frame based on available screen real estate
    final cameraHeight = isSmallScreen
        ? (screenHeight * 0.28).clamp(180.0, 240.0)
        : (screenHeight * 0.35).clamp(220.0, 310.0);
    final frameSize = (cameraHeight * 0.58).clamp(120.0, 180.0);

    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth < 360 ? 16 : 24,
                vertical: isSmallScreen ? 10 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section above heading
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: TEDxColors.tedRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$counterCode  ·  ${benefit.toUpperCase()} REDEMPTION',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.mono(
                            color: const Color(0xFF9EA0A5),
                            fontSize: isSmallScreen ? 10 : 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 6),
                  Text(
                    'Scan attendee QR',
                    style: AppFonts.heading(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 26 : 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    counterName,
                    style: AppFonts.body(
                      color: const Color(0xFFA1A1AA),
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 14 : 20),

                  // Live Camera Container
                  Container(
                    height: cameraHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF26262A),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (!_permissionChecked)
                            const Center(
                              child: CircularProgressIndicator(
                                color: TEDxColors.tedRed,
                              ),
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

                          if (_hasPermission && _permissionChecked) ...[
                            // Camera Header Overlay
                            Positioned(
                              top: 10,
                              left: 12,
                              right: 12,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.fiber_manual_record,
                                        size: 7,
                                        color: Color(0xFF10B981),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'LIVE SCANNER',
                                        style: AppFonts.mono(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          await _controller.toggleTorch();
                                          setState(() => _torchOn = !_torchOn);
                                        },
                                        icon: Icon(
                                          _torchOn
                                              ? Icons.flash_on_rounded
                                              : Icons.flash_off_rounded,
                                          color: _torchOn
                                              ? Colors.amber
                                              : Colors.white70,
                                          size: 18,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.black45,
                                          padding: const EdgeInsets.all(4),
                                          minimumSize: const Size(32, 32),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      IconButton(
                                        onPressed: () =>
                                            _controller.switchCamera(),
                                        icon: const Icon(
                                          Icons.cameraswitch_rounded,
                                          color: Colors.white70,
                                          size: 18,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.black45,
                                          padding: const EdgeInsets.all(4),
                                          minimumSize: const Size(32, 32),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Viewfinder Corner Brackets & Frame
                            Center(
                              child: SizedBox(
                                width: frameSize,
                                height: frameSize,
                                child: Stack(
                                  children: [
                                    CustomPaint(
                                      size: Size(frameSize, frameSize),
                                      painter: FramePainter(
                                        isProcessing: _isProcessing,
                                      ),
                                    ),
                                    Center(
                                      child: Icon(
                                        Icons.qr_code_scanner_rounded,
                                        size: isSmallScreen ? 28 : 36,
                                        color: const Color(0xFF52525B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Bottom instruction overlay inside frame
                            Positioned(
                              bottom: 10,
                              left: 12,
                              right: 12,
                              child: Text(
                                _isProcessing
                                    ? 'Verifying ticket code...'
                                    : 'Position attendee QR inside frame',
                                textAlign: TextAlign.center,
                                style: AppFonts.body(
                                  color: _isProcessing
                                      ? TEDxColors.tedRed
                                      : const Color(0xFFA1A1AA),
                                  fontSize: isSmallScreen ? 11 : 12,
                                  fontWeight: _isProcessing
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 22),
                  ManualTicketEntry(
                    isSmallScreen: isSmallScreen,
                    isProcessing: _isProcessing,
                    onSubmit: _submitTicketId,
                  ),
                  SizedBox(height: isSmallScreen ? 18 : 24),

                  // Successful Scans Today Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SUCCESSFUL SCANS TODAY',
                        style: AppFonts.mono(
                          color: const Color(0xFF71717A),
                          fontSize: isSmallScreen ? 10 : 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '${widget.totalScans}',
                        style: AppFonts.heading(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 14 : 18),
                  const Divider(color: Color(0xFF1F1F23), height: 1),
                  SizedBox(height: isSmallScreen ? 14 : 20),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 40,
              color: TEDxColors.tedRed,
            ),
            const SizedBox(height: 12),
            Text(
              'Camera Access Required',
              style: AppFonts.heading(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Camera access is needed to scan attendee event passes.',
              textAlign: TextAlign.center,
              style: AppFonts.body(
                color: const Color(0xFFA1A1AA),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => openAppSettings(),
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
            const Icon(
              Icons.videocam_off_outlined,
              size: 40,
              color: TEDxColors.warning,
            ),
            const SizedBox(height: 12),
            Text(
              'Camera Unavailable',
              style: AppFonts.heading(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Camera stream interrupted ($error).\nTap retry to restart camera.',
              textAlign: TextAlign.center,
              style: AppFonts.body(
                color: const Color(0xFFA1A1AA),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => _controller.start(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF26262A)),
              ),
              child: const Text('RETRY CAMERA'),
            ),
          ],
        ),
      ),
    );
  }
}

class ManualTicketEntry extends StatefulWidget {
  final bool isSmallScreen;
  final bool isProcessing;
  final ValueChanged<String> onSubmit;

  const ManualTicketEntry({
    super.key,
    required this.isSmallScreen,
    required this.isProcessing,
    required this.onSubmit,
  });

  @override
  State<ManualTicketEntry> createState() => _ManualTicketEntryState();
}

class _ManualTicketEntryState extends State<ManualTicketEntry> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final ticketId = _controller.text.trim();
    if (ticketId.isEmpty) {
      setState(() => _errorText = 'Enter a ticket ID to validate.');
      return;
    }
    setState(() => _errorText = null);
    widget.onSubmit(ticketId);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ENTER TICKET ID',
          style: AppFonts.mono(
            color: TEDxColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          enabled: !widget.isProcessing,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            if (_errorText != null) setState(() => _errorText = null);
          },
          onSubmitted: (_) => _submit(),
          style: AppFonts.mono(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Type or paste ticket ID',
            hintStyle: AppFonts.body(color: TEDxColors.textMuted, fontSize: 13),
            errorText: _errorText,
            prefixIcon: const Icon(
              Icons.confirmation_number_outlined,
              color: TEDxColors.textMuted,
              size: 19,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: widget.isSmallScreen ? 12 : 15,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.isProcessing ? null : _submit,
            icon: widget.isProcessing
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.verified_outlined, size: 19),
            label: Text(
              widget.isProcessing
                  ? 'VALIDATING TICKET...'
                  : 'VALIDATE TICKET ID',
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the 4 corner brackets ┌ ┐ └ ┘ inside the scanner frame
class FramePainter extends CustomPainter {
  final bool isProcessing;
  FramePainter({this.isProcessing = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isProcessing
          ? const Color(0xFF10B981)
          : Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const len = 28.0;

    // Top-Left
    canvas.drawLine(const Offset(0, 0), const Offset(len, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, len), paint);

    // Top-Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - len, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);

    // Bottom-Left
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - len),
      paint,
    );

    // Bottom-Right
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - len, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant FramePainter oldDelegate) =>
      oldDelegate.isProcessing != isProcessing;
}
