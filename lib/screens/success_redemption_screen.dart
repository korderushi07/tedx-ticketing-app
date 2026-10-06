import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';
import '../models/app_models.dart';

class OutcomeResultScreen extends StatefulWidget {
  final ScanModel scan;
  final ScanModel? lastSuccess;
  final VoidCallback onActionClick;

  const OutcomeResultScreen({
    super.key,
    required this.scan,
    this.lastSuccess,
    required this.onActionClick,
  });

  @override
  State<OutcomeResultScreen> createState() => _OutcomeResultScreenState();
}

class _OutcomeResultScreenState extends State<OutcomeResultScreen> {
  bool _showHelp = false;

  @override
  Widget build(BuildContext context) {
    final scan = widget.scan;
    final outcome = scan.outcome;
    final isApproved = outcome == Outcome.approved;
    final isNetwork = outcome == Outcome.network;
    final isInvalid = outcome == Outcome.invalid;

    Color markColor;
    Color markBg;
    String markIcon;

    if (isApproved) {
      markColor = TEDxColors.success;
      markBg = TEDxColors.successBg;
      markIcon = '✓';
    } else if (isNetwork) {
      markColor = TEDxColors.warning;
      markBg = TEDxColors.warningBg;
      markIcon = '!';
    } else {
      markColor = TEDxColors.error;
      markBg = TEDxColors.errorBg;
      markIcon = '×';
    }

    String actionText = isApproved
        ? 'SCAN NEXT'
        : isNetwork
            ? 'RETRY CONNECTION'
            : 'SCAN AGAIN';

    List<MapEntry<String, String>> metadataRows = [];
    if (isApproved) {
      metadataRows = [
        MapEntry('Time', scan.time),
        MapEntry('Counter', scan.counter),
        const MapEntry('Recorded by', 'Rahul Sharma'),
      ];
    } else if (outcome == Outcome.redeemed) {
      metadataRows = [
        MapEntry('Collected at', widget.lastSuccess?.counter ?? scan.counter),
        MapEntry('Original scan', widget.lastSuccess?.time ?? '12:42 PM'),
        const MapEntry('Volunteer', 'Rahul Sharma'),
      ];
    } else if (outcome == Outcome.not_eligible) {
      metadataRows = const [
        MapEntry('Ticket includes', 'Lunch only'),
        MapEntry('Required pass', 'Premium or VIP'),
      ];
    } else if (isNetwork) {
      metadataRows = const [
        MapEntry('Connection', 'Offline'),
        MapEntry('Last synced', '02:43 PM'),
        MapEntry('Redemption', 'Not confirmed'),
      ];
    }

    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scan.counter.toUpperCase(),
                style: const TextStyle(
                  color: TEDxColors.tedRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Mark Circle & Outcome Title
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: markBg, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        markIcon,
                        style: TextStyle(
                          color: markColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      getOutcomeLabel(outcome).toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Outcome Content
              if (isInvalid || isNetwork) ...[
                Text(
                  isNetwork ? 'Unable to verify this ticket.' : 'This code could not be verified.',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  isNetwork
                      ? 'No redemption has been confirmed. Retry before issuing the benefit.'
                      : 'Ask the attendee to show their original TEDx event ticket.',
                  style: const TextStyle(color: TEDxColors.textSecondary, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 20),
                if (isNetwork) MetadataList(rows: metadataRows),
              ] else ...[
                // Attendee Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TEDxColors.cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: TEDxColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan.name,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 13, color: TEDxColors.textSecondary),
                          children: [
                            TextSpan(text: '${scan.pass} PASS ', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                            TextSpan(text: '· ${scan.ticketId}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Requested Benefit Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TEDxColors.cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: TEDxColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'REQUESTED BENEFIT',
                        style: TextStyle(color: TEDxColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scan.benefit.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isApproved
                            ? 'Successfully redeemed'
                            : outcome == Outcome.redeemed
                                ? 'This benefit was already collected'
                                : 'This benefit isn’t included with this ticket.',
                        style: TextStyle(
                          color: isApproved ? TEDxColors.success : TEDxColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                MetadataList(rows: metadataRows),

                if (!isApproved) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: TEDxColors.errorBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TEDxColors.errorBorder.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      outcome == Outcome.redeemed
                          ? 'Do not provide this benefit again.'
                          : 'Do not issue the T-shirt for this pass.',
                      style: const TextStyle(color: TEDxColors.error, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 32),

              // Bottom Actions
              ActionButton(
                text: actionText,
                trailingArrow: '→',
                onPressed: widget.onActionClick,
              ),
              const SizedBox(height: 12),
              if (isApproved)
                const Center(
                  child: Text(
                    'Redemption recorded in this demo session',
                    style: TextStyle(color: TEDxColors.textMuted, fontSize: 11),
                  ),
                )
              else ...[
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _showHelp = !_showHelp),
                    child: const Text(
                      'Contact counter lead',
                      style: TextStyle(color: TEDxColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                if (_showHelp) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: TEDxColors.inputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TEDxColors.cardBorder),
                    ),
                    child: Text(
                      'Visit the event operations desk next to the Main Entrance. Quote volunteer ID VOL–014 and counter ${scan.counter}.',
                      style: const TextStyle(color: TEDxColors.textSecondary, fontSize: 12, height: 1.3),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
