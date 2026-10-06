import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';
import '../models/app_models.dart';

class QRScannerScreen extends StatefulWidget {
  final CounterInfo counter;
  final int totalScans;
  final Function(Outcome outcome, CounterKey? counterKey) onSimulateScan;

  const QRScannerScreen({
    super.key,
    required this.counter,
    required this.totalScans,
    required this.onSimulateScan,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String _cameraState = 'demo'; // 'demo' | 'denied' | 'unavailable'
  bool _showScenarios = true;
  bool _showCameraErrorControls = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeading(
                label: '${widget.counter.code} · ${widget.counter.benefit.toUpperCase()} REDEMPTION',
                title: 'Scan attendee QR',
                support: widget.counter.name,
              ),
              const SizedBox(height: 16),

              // Viewfinder Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: TEDxColors.inputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: TEDxColors.cardBorder),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fiber_manual_record, size: 8, color: TEDxColors.tedRed),
                          SizedBox(width: 6),
                          Text(
                            'DEMO SCANNER',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Target Frame
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: TEDxColors.tedRed.withValues(alpha: 0.6), width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 56,
                          color: TEDxColors.tedRed,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _cameraState == 'demo'
                          ? 'Position the attendee’s QR inside the frame'
                          : _cameraState == 'denied'
                              ? 'Camera permission is required'
                              : 'Camera unavailable on this device',
                      style: const TextStyle(
                        color: TEDxColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              if (_cameraState != 'demo') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TEDxColors.cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: TEDxColors.warningBorder.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _cameraState == 'denied'
                            ? 'Allow camera access in your browser settings, then try again.'
                            : 'Try another device or contact your counter lead.',
                        style: const TextStyle(
                          color: TEDxColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => setState(() => _cameraState = 'demo'),
                        child: const Text(
                          'Return to demo scanner →',
                          style: TextStyle(
                            color: TEDxColors.tedRed,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Scanner Count Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SUCCESSFUL SCANS TODAY',
                      style: TextStyle(
                        color: TEDxColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      widget.totalScans.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Prototype mode. Choose a scenario below to simulate a scan; no camera or live ticket verification is used.',
                style: TextStyle(
                  color: TEDxColors.textMuted,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),

              // Demo Scenarios Accordion
              Container(
                decoration: BoxDecoration(
                  color: TEDxColors.inputBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _showScenarios = !_showScenarios),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: TEDxColors.textSecondary),
                                children: [
                                  TextSpan(text: 'Demo scenarios '),
                                  TextSpan(text: '5 outcomes', style: TextStyle(color: TEDxColors.textMuted, fontSize: 11)),
                                ],
                              ),
                            ),
                            Icon(
                              _showScenarios ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: TEDxColors.textMuted,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showScenarios)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                        child: Column(
                          children: [
                            _scenarioRow(
                              color: TEDxColors.success,
                              title: 'Valid ticket',
                              subtitle: 'Rushikesh Korde · VIP · ${widget.counter.benefit}',
                              onTap: () => widget.onSimulateScan(Outcome.approved, null),
                            ),
                            const SizedBox(height: 8),
                            _scenarioRow(
                              color: TEDxColors.warning,
                              title: 'Already redeemed',
                              subtitle: 'Same ticket, same benefit',
                              onTap: () => widget.onSimulateScan(Outcome.redeemed, null),
                            ),
                            const SizedBox(height: 8),
                            _scenarioRow(
                              color: TEDxColors.error,
                              title: 'Not eligible',
                              subtitle: 'Aarav Sharma · General · T-shirt',
                              onTap: () => widget.onSimulateScan(Outcome.not_eligible, CounterKey.merch),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ActionButton(
                                    text: 'Invalid QR',
                                    secondary: true,
                                    onPressed: () => widget.onSimulateScan(Outcome.invalid, null),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ActionButton(
                                    text: 'Network error',
                                    secondary: true,
                                    onPressed: () => widget.onSimulateScan(Outcome.network, null),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Camera error states accordion
              Container(
                decoration: BoxDecoration(
                  color: TEDxColors.inputBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _showCameraErrorControls = !_showCameraErrorControls),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Camera error states',
                              style: TextStyle(
                                color: TEDxColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              _showCameraErrorControls ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: TEDxColors.textMuted,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showCameraErrorControls)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: ActionButton(
                                text: 'Permission denied',
                                secondary: true,
                                onPressed: () => setState(() => _cameraState = 'denied'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ActionButton(
                                text: 'Unavailable',
                                secondary: true,
                                onPressed: () => setState(() => _cameraState = 'unavailable'),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scenarioRow({
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: TEDxColors.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TEDxColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: TEDxColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Text('→', style: TextStyle(color: TEDxColors.textMuted, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
