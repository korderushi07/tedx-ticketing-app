import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';
import '../models/app_models.dart';

class OutcomeResultScreen extends StatelessWidget {
  final ScanModel scan;
  final VoidCallback onActionClick;
  final Future<void> Function() onConfirmRedemption;
  final Future<void> Function()? onRetryVerification;
  final ValueChanged<AttendeeModel>? onToggleRelatedTicket;
  final VoidCallback? onTogglePrimaryTicket;
  final bool isPrimarySelected;
  final int selectedTicketCount;
  final Set<String> selectedRedemptionKeys;
  final VoidCallback? onClearSelection;
  final VoidCallback? onRetryRelatedEligibility;
  final bool isConfirming;

  const OutcomeResultScreen({
    super.key,
    required this.scan,
    required this.onActionClick,
    required this.onConfirmRedemption,
    this.onRetryVerification,
    this.onToggleRelatedTicket,
    this.onTogglePrimaryTicket,
    this.isPrimarySelected = false,
    this.selectedTicketCount = 0,
    this.selectedRedemptionKeys = const {},
    this.onClearSelection,
    this.onRetryRelatedEligibility,
    this.isConfirming = false,
  });

  @override
  Widget build(BuildContext context) {
    final isKnownTicket = scan.attendeeId != null;
    final status = isConfirming
        ? const _OutcomeStatus(
            title: 'Redemption in progress',
            icon: Icons.sync_rounded,
            color: TEDxColors.warning,
            background: TEDxColors.warningBg,
          )
        : _statusFor(scan.outcome);
    final showRelatedTickets = isKnownTicket && scan.orderId != null;

    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          color: TEDxColors.tedRed,
                          size: 17,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            scan.counter.toUpperCase(),
                            style: AppFonts.mono(
                              color: TEDxColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (isKnownTicket) ...[
                      Text(
                        scan.name,
                        style: AppFonts.heading(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _TicketIdentity(scan: scan),
                      const SizedBox(height: 16),
                    ],
                    _BenefitStatus(
                      scan: scan,
                      status: status,
                      isConfirming: isConfirming,
                    ),
                    if (scan.outcome == Outcome.ready) ...[
                      const SizedBox(height: 8),
                      _TicketSelectionButton(
                        selected: isPrimarySelected,
                        enabled: !isConfirming,
                        label: isPrimarySelected ? 'Selected' : 'Approve',
                        onPressed: onTogglePrimaryTicket,
                      ),
                    ],
                    if (scan.outcome == Outcome.redeemed ||
                        scan.outcome == Outcome.approved) ...[
                      const SizedBox(height: 6),
                      _MetadataRow(
                        label: 'Claimed by',
                        value: _claimantNameOrFallback(
                          scan.previousRedemptionClaimant,
                        ),
                      ),
                      if (scan.previousRedemptionAt != null) ...[
                        const SizedBox(height: 6),
                        _MetadataRow(
                          label: 'Redeemed on',
                          value: _formatDate(scan.previousRedemptionAt!),
                        ),
                      ],
                      if (scan.previousRedemptionVolunteer != null) ...[
                        const SizedBox(height: 6),
                        _MetadataRow(
                          label: 'Processed by',
                          value: scan.previousRedemptionVolunteer!,
                        ),
                      ],
                    ],
                    if (showRelatedTickets) ...[
                      const SizedBox(height: 18),
                      _RelatedTickets(
                        scan: scan,
                        tickets: scan.orderTickets,
                        isLoading: scan.orderTicketsLoading,
                        hasLoadFailed: scan.orderTicketsLoadFailed,
                        onRetry: isConfirming
                            ? null
                            : onRetryRelatedEligibility,
                        isSelected: (ticket) => selectedRedemptionKeys.contains(
                          '${ticket.ticketId}::${scan.addonId}',
                        ),
                        onToggle: isConfirming ? null : onToggleRelatedTicket,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedTicketCount > 0) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '$selectedTicketCount ${selectedTicketCount == 1 ? 'ticket' : 'tickets'} selected for ${scan.benefit}',
                        textAlign: TextAlign.center,
                        style: AppFonts.body(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: isConfirming ? null : onClearSelection,
                      child: const Text('CLEAR SELECTIONS'),
                    ),
                  ] else if (scan.outcome == Outcome.ready ||
                      scan.orderTickets.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Select eligible tickets to enable redemption',
                        textAlign: TextAlign.center,
                        style: AppFonts.body(
                          color: TEDxColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  ActionButton(
                    text: isConfirming
                        ? 'PROCESSING REDEMPTIONS...'
                        : selectedTicketCount > 0
                        ? 'CONFIRM $selectedTicketCount ${selectedTicketCount == 1 ? 'TICKET' : 'TICKETS'} FOR ${scan.benefit.toUpperCase()}'
                        : scan.outcome == Outcome.ready ||
                              scan.orderTickets.any(
                                (ticket) => ticket.isEligible == true,
                              )
                        ? 'SELECT TICKETS TO REDEEM'
                        : 'SCAN NEXT TICKET',
                    icon: isConfirming
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : selectedTicketCount > 0
                        ? const Icon(Icons.verified_outlined, size: 19)
                        : const Icon(Icons.qr_code_scanner_rounded, size: 19),
                    onPressed: isConfirming || scan.orderTicketsLoading
                        ? null
                        : selectedTicketCount > 0
                        ? () => _requestRedemptionConfirmation(context)
                        : scan.outcome == Outcome.ready ||
                              scan.orderTickets.any(
                                (ticket) => ticket.isEligible == true,
                              )
                        ? null
                        : onActionClick,
                  ),
                  if (!isConfirming &&
                      selectedTicketCount == 0 &&
                      (scan.outcome == Outcome.ready ||
                          scan.orderTickets.any(
                            (ticket) => ticket.isEligible == true,
                          ))) ...[
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: onActionClick,
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 17),
                      label: const Text('SCAN NEXT WITHOUT REDEEMING'),
                    ),
                  ],
                  if (scan.outcome == Outcome.network &&
                      onRetryVerification != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: isConfirming ? null : onRetryVerification,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('VERIFY THIS TICKET AGAIN'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestRedemptionConfirmation(BuildContext context) async {
    final selectedTickets = <(String, String)>[];
    final addonId = scan.addonId;
    if (addonId == null) return;

    if (scan.outcome == Outcome.ready &&
        scan.attendeeId != null &&
        selectedRedemptionKeys.contains('${scan.ticketId}::$addonId')) {
      selectedTickets.add((scan.name, scan.ticketId));
    }
    for (final ticket in scan.orderTickets) {
      if (ticket.attendeeId != null &&
          ticket.isEligible == true &&
          !ticket.isRedeemed &&
          selectedRedemptionKeys.contains('${ticket.ticketId}::$addonId')) {
        selectedTickets.add((ticket.name, ticket.ticketId));
      }
    }
    if (selectedTickets.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: TEDxColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: TEDxColors.cardBorder),
        ),
        title: Text(
          'Confirm redemption',
          style: AppFonts.heading(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Redeem ${scan.benefit} for these selected tickets at ${scan.counter}?',
                style: AppFonts.body(
                  color: TEDxColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              for (final ticket in selectedTickets) ...[
                Text(
                  ticket.$1,
                  style: AppFonts.body(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ticket.$2,
                  style: AppFonts.mono(
                    color: TEDxColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
    if (confirmed == true) await onConfirmRedemption();
  }

  static _OutcomeStatus _statusFor(Outcome outcome) {
    return switch (outcome) {
      Outcome.ready => const _OutcomeStatus(
        title: 'Eligible',
        icon: Icons.check_circle_outline_rounded,
        color: TEDxColors.success,
        background: TEDxColors.successBg,
      ),
      Outcome.approved => const _OutcomeStatus(
        title: 'REDEEMED',
        icon: Icons.task_alt_rounded,
        color: TEDxColors.success,
        background: TEDxColors.successBg,
      ),
      Outcome.redeemed => const _OutcomeStatus(
        title: 'REDEEMED',
        icon: Icons.info_outline_rounded,
        color: TEDxColors.warning,
        background: TEDxColors.warningBg,
      ),
      Outcome.notEligible => const _OutcomeStatus(
        title: 'Not eligible',
        icon: Icons.block_outlined,
        color: TEDxColors.error,
        background: TEDxColors.errorBg,
      ),
      Outcome.invalid => const _OutcomeStatus(
        title: 'Ticket not recognized',
        icon: Icons.qr_code_2_rounded,
        color: TEDxColors.error,
        background: TEDxColors.errorBg,
      ),
      Outcome.network => const _OutcomeStatus(
        title: 'Verification uncertain',
        icon: Icons.cloud_off_outlined,
        color: TEDxColors.warning,
        background: TEDxColors.warningBg,
      ),
    };
  }

  static String _formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate).toLocal();
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '${date.year}-$month-$day  $hour:$minute $period';
    } on FormatException {
      return rawDate;
    }
  }

  static String _claimantNameOrFallback(String? name) {
    final claimantName = name?.trim();
    return claimantName == null || claimantName.isEmpty
        ? 'Claimant information unavailable'
        : claimantName;
  }
}

class _OutcomeStatus {
  final String title;
  final IconData icon;
  final Color color;
  final Color background;

  const _OutcomeStatus({
    required this.title,
    required this.icon,
    required this.color,
    required this.background,
  });
}

class _BenefitStatus extends StatelessWidget {
  final ScanModel scan;
  final _OutcomeStatus status;
  final bool isConfirming;

  const _BenefitStatus({
    required this.scan,
    required this.status,
    required this.isConfirming,
  });

  @override
  Widget build(BuildContext context) {
    final message = isConfirming
        ? 'Submitting this ticket and benefit. Keep this screen open until the result is confirmed.'
        : scan.statusMessage ??
              switch (scan.outcome) {
                Outcome.ready =>
                  'Not redeemed yet. Confirm only for this ticket.',
                Outcome.approved => 'The backend confirmed this redemption.',
                Outcome.redeemed => 'Do not issue this benefit again.',
                Outcome.notEligible =>
                  'This ticket does not include this benefit.',
                Outcome.invalid =>
                  'Ask the attendee to show their original ticket.',
                Outcome.network =>
                  'The result is not confirmed. Verify again before issuing the benefit.',
              };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color.withValues(alpha: 0.48)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(status.icon, size: 22, color: status.color),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scan.benefit.toUpperCase(),
                  style: AppFonts.mono(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  status.title,
                  style: AppFonts.heading(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: AppFonts.body(
                    color: TEDxColors.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketIdentity extends StatelessWidget {
  final ScanModel scan;

  const _TicketIdentity({required this.scan});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 5,
      children: [
        Text(
          scan.pass,
          style: AppFonts.body(
            color: TEDxColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '·',
          style: AppFonts.body(color: TEDxColors.textMuted, fontSize: 13),
        ),
        Text(
          scan.ticketId,
          style: AppFonts.mono(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetadataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 94,
          child: Text(
            label,
            style: AppFonts.body(color: TEDxColors.textMuted, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppFonts.body(color: TEDxColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _RelatedTickets extends StatelessWidget {
  final ScanModel scan;
  final List<AttendeeModel> tickets;
  final bool isLoading;
  final bool hasLoadFailed;
  final VoidCallback? onRetry;
  final bool Function(AttendeeModel ticket) isSelected;
  final ValueChanged<AttendeeModel>? onToggle;

  const _RelatedTickets({
    required this.scan,
    required this.tickets,
    required this.isLoading,
    required this.hasLoadFailed,
    required this.onRetry,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final visibleTickets = tickets
        .where(
          (ticket) =>
              ticket.isRedeemed ||
              ticket.isEligible == true ||
              ticket.redemptionOutcome != null,
        )
        .toList(growable: false);
    return Material(
      color: TEDxColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: TEDxColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Other Tickets in Same Order',
              style: AppFonts.body(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isLoading) ...[
              const SizedBox(height: 8),
              Text(
                'Checking eligibility for ${scan.benefit}',
                style: AppFonts.body(color: TEDxColors.textMuted, fontSize: 12),
              ),
            ],
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(
                  color: TEDxColors.tedRed,
                  backgroundColor: TEDxColors.surfaceElevated,
                ),
              ),
            if (!isLoading && visibleTickets.isEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    hasLoadFailed
                        ? 'Some ticket eligibility could not be checked.'
                        : 'No other eligible tickets for this counter',
                    style: AppFonts.body(
                      color: TEDxColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              if (hasLoadFailed && onRetry != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('RETRY ELIGIBILITY CHECK'),
                  ),
                ),
            ],
            if (!isLoading && visibleTickets.isNotEmpty) ...[
              if (hasLoadFailed) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Some other tickets could not be checked and are not available to select.',
                        style: AppFonts.body(
                          color: TEDxColors.warning,
                          fontSize: 11,
                        ),
                      ),
                      if (onRetry != null)
                        TextButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('RETRY ELIGIBILITY CHECK'),
                        ),
                    ],
                  ),
                ),
              ],
              for (final ticket in visibleTickets) ...[
                const Divider(height: 16, color: TEDxColors.cardBorder),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: TEDxColors.success,
                      size: 18,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.name,
                            style: AppFonts.body(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${ticket.ticketId} · ${ticket.ticketType}',
                            style: AppFonts.mono(
                              color: TEDxColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            ticket.isRedeemed
                                ? 'REDEEMED'
                                : ticket.redemptionOutcome == Outcome.network
                                ? 'Redemption result uncertain'
                                : ticket.statusMessage ??
                                      'Eligible for ${scan.benefit}',
                            style: AppFonts.body(
                              color: ticket.isRedeemed
                                  ? TEDxColors.warning
                                  : ticket.redemptionOutcome == Outcome.network
                                  ? TEDxColors.warning
                                  : TEDxColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          if (ticket.isRedeemed) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Claimed by ${OutcomeResultScreen._claimantNameOrFallback(ticket.claimedBy)}',
                              style: AppFonts.body(
                                color: TEDxColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            if (ticket.redeemedAt != null)
                              Text(
                                'Redeemed on ${OutcomeResultScreen._formatDate(ticket.redeemedAt!)}',
                                style: AppFonts.body(
                                  color: TEDxColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            if (ticket.redeemedBy != null)
                              Text(
                                'Processed by ${ticket.redeemedBy}',
                                style: AppFonts.body(
                                  color: TEDxColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!ticket.isRedeemed && ticket.redemptionOutcome == null)
                      _TicketSelectionButton(
                        selected: isSelected(ticket),
                        enabled: onToggle != null && ticket.isEligible == true,
                        label: isSelected(ticket) ? 'Selected' : 'Approve',
                        onPressed: onToggle == null
                            ? null
                            : () => onToggle!(ticket),
                      )
                    else
                      Icon(
                        ticket.isRedeemed
                            ? Icons.check_circle_rounded
                            : Icons.error_outline_rounded,
                        color: ticket.isRedeemed
                            ? TEDxColors.success
                            : TEDxColors.warning,
                      ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _TicketSelectionButton extends StatelessWidget {
  final bool selected;
  final bool enabled;
  final String label;
  final VoidCallback? onPressed;

  const _TicketSelectionButton({
    required this.selected,
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(
        selected ? Icons.check_circle_rounded : Icons.add_circle_outline,
        size: 17,
      ),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? TEDxColors.success : Colors.white,
        side: BorderSide(
          color: selected ? TEDxColors.success : TEDxColors.cardBorder,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        minimumSize: const Size(0, 38),
      ),
    );
  }
}
