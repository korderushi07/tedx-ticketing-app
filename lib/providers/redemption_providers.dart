import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';
import '../services/api_service.dart';

/// Provider for active counter selection
final counterProvider = StateNotifierProvider<CounterNotifier, CounterInfo>((
  ref,
) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<CounterInfo> {
  CounterNotifier() : super(CounterInfo.food);

  void setCounter(CounterKey key) {
    state = CounterInfo.fromKey(key);
  }
}

/// Provider for active scan result state (separate from persistent history)
final currentScanProvider =
    StateNotifierProvider<CurrentScanNotifier, ScanModel?>((ref) {
      return CurrentScanNotifier();
    });

class CurrentScanNotifier extends StateNotifier<ScanModel?> {
  CurrentScanNotifier() : super(null);

  void setScan(ScanModel scan) {
    state = scan;
  }

  void clearScan() {
    state = null;
  }
}

/// Provider for persistent redemption history fetched directly from SQLite via FastAPI
final redemptionHistoryProvider =
    StateNotifierProvider<
      RedemptionHistoryNotifier,
      AsyncValue<List<ScanModel>>
    >((ref) {
      return RedemptionHistoryNotifier();
    });

class RedemptionHistoryNotifier
    extends StateNotifier<AsyncValue<List<ScanModel>>> {
  RedemptionHistoryNotifier() : super(const AsyncValue.data([]));

  String _formatServerTime(dynamic rawTime) {
    if (rawTime == null || rawTime.toString().trim().isEmpty) {
      return 'Time unavailable';
    }

    try {
      final dt = DateTime.parse(rawTime.toString()).toLocal();
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:$minute $amPm';
    } catch (_) {
      return rawTime.toString();
    }
  }

  Future<void> fetchHistory() async {
    state = const AsyncValue.loading();
    try {
      final rawLogs = await ApiService().getMyHistory();
      final parsed = rawLogs.map((item) {
        final m = item as Map<String, dynamic>;
        final attName = m['attendee_name']?.toString() ?? 'Attendee';
        final ticketId = (m['ticket_id'] ?? '').toString().trim();
        final addonName = m['addon_name']?.toString() ?? 'Addon';
        final counterName = m['counter_name']?.toString() ?? 'Counter';
        final formattedTime = _formatServerTime(m['redeemed_at']);

        return ScanModel(
          id: 'history-${m['id']}',
          time: formattedTime,
          name: attName,
          ticketId: ticketId.isNotEmpty ? ticketId : 'Ticket unavailable',
          pass: 'VERIFIED',
          benefit: addonName,
          counter: counterName,
          outcome: Outcome.approved,
          volunteerName: m['volunteer_name']?.toString() ?? 'Volunteer',
          attendeeId: m['attendee_id'] as int?,
          addonId: m['addon_id'] as int?,
          counterId: m['counter_id'] as int?,
        );
      }).toList();

      if (!mounted) return;
      state = AsyncValue.data(parsed);
    } catch (err, stackTrace) {
      debugPrint('[RedemptionHistoryNotifier] Error fetching history: $err');
      if (!mounted) return;
      state = AsyncValue.error(err, stackTrace);
    }
  }

  Future<void> refresh() async {
    await fetchHistory();
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}
