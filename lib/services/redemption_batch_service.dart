import 'package:flutter/foundation.dart';
import '../models/app_models.dart';

class RedemptionBatchService {
  Future<List<AttendeeModel>> redeemSelected({
    required List<ScanModel> tickets,
    required Future<Map<String, dynamic>> Function(ScanModel ticket) claim,
    required Future<bool> Function(ScanModel ticket) reconcile,
  }) async {
    final results = <AttendeeModel>[];
    for (final ticket in tickets) {
      try {
        final response = await claim(ticket);
        final details = _responseDetails(response);
        var outcome = response['success'] == true
            ? Outcome.approved
            : switch (details['error']) {
                'ALREADY_CLAIMED' => Outcome.redeemed,
                'NOT_ELIGIBLE' || 'COUNTER_UNAUTHORIZED' => Outcome.notEligible,
                _ => Outcome.network,
              };
        var confirmedInHistory = false;
        if (outcome == Outcome.network) {
          confirmedInHistory = await _tryReconcile(ticket, reconcile);
          if (confirmedInHistory) outcome = Outcome.approved;
        }

        final redemption = response['redemption'];
        final redemptionDetails = redemption is Map
            ? redemption
            : const <String, dynamic>{};
        results.add(
          _result(
            ticket,
            outcome,
            statusMessage: outcome == Outcome.approved
                ? confirmedInHistory
                      ? 'Redemption confirmed in history.'
                      : '${ticket.benefit} redemption recorded successfully.'
                : details['message']?.toString() ??
                      'The result could not be confirmed. Verify this ticket before issuing the benefit.',
            redeemedAt:
                _previousRedemptionTime(details) ??
                redemptionDetails['redeemed_at']?.toString(),
            redeemedCounter:
                _previousRedemptionCounter(details) ??
                redemptionDetails['counter']?.toString(),
            redeemedBy:
                _previousRedemptionVolunteer(details) ??
                redemptionDetails['volunteer']?.toString(),
            claimedBy:
                _previousClaimantName(details) ??
                redemptionDetails['claimant_name']?.toString(),
          ),
        );
      } catch (error) {
        debugPrint('[GROUP REDEMPTION ERROR] ${ticket.ticketId}: $error');
        final confirmedInHistory = await _tryReconcile(ticket, reconcile);
        results.add(
          _result(
            ticket,
            confirmedInHistory ? Outcome.approved : Outcome.network,
            statusMessage: confirmedInHistory
                ? 'Redemption confirmed in history.'
                : 'The request result is uncertain. Verify this ticket before issuing the benefit.',
          ),
        );
      }
    }
    return results;
  }

  Future<bool> _tryReconcile(
    ScanModel ticket,
    Future<bool> Function(ScanModel ticket) reconcile,
  ) async {
    try {
      return await reconcile(ticket);
    } catch (error) {
      debugPrint(
        '[GROUP REDEMPTION RECONCILIATION ERROR] ${ticket.ticketId}: $error',
      );
      return false;
    }
  }

  AttendeeModel _result(
    ScanModel ticket,
    Outcome outcome, {
    required String statusMessage,
    String? redeemedAt,
    String? redeemedCounter,
    String? redeemedBy,
    String? claimedBy,
  }) {
    return AttendeeModel(
      attendeeId: ticket.attendeeId,
      ticketId: ticket.ticketId,
      name: ticket.name,
      ticketType: ticket.pass,
      benefits: const [],
      addonId: ticket.addonId,
      isEligible: outcome == Outcome.notEligible ? false : null,
      isRedeemed: outcome == Outcome.redeemed || outcome == Outcome.approved,
      redemptionOutcome: outcome,
      statusMessage: statusMessage,
      redeemedAt: redeemedAt,
      redeemedCounter: redeemedCounter,
      redeemedBy: redeemedBy,
      claimedBy: claimedBy,
    );
  }

  Map<String, dynamic> _responseDetails(Map<String, dynamic> response) {
    final detail = response['detail'];
    return detail is Map ? Map<String, dynamic>.from(detail) : response;
  }

  String? _previousRedemptionTime(Map<String, dynamic> response) {
    final previous = response['previous_redemption'];
    return previous is Map ? previous['redeemed_at']?.toString() : null;
  }

  String? _previousRedemptionCounter(Map<String, dynamic> response) {
    final previous = response['previous_redemption'];
    return previous is Map ? previous['counter']?.toString() : null;
  }

  String? _previousRedemptionVolunteer(Map<String, dynamic> response) {
    final previous = response['previous_redemption'];
    return previous is Map ? previous['volunteer']?.toString() : null;
  }

  String? _previousClaimantName(Map<String, dynamic> response) {
    final previous = response['previous_redemption'];
    return previous is Map ? previous['claimant_name']?.toString() : null;
  }
}
