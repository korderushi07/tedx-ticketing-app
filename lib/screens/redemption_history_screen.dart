import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';
import '../models/app_models.dart';
import '../providers/redemption_providers.dart';

class RedemptionHistoryScreen extends ConsumerStatefulWidget {
  final CounterInfo counter;
  final ValueChanged<ScanModel> onSelectScan;

  const RedemptionHistoryScreen({
    super.key,
    required this.counter,
    required this.onSelectScan,
  });

  @override
  ConsumerState<RedemptionHistoryScreen> createState() =>
      _RedemptionHistoryScreenState();
}

class _RedemptionHistoryScreenState
    extends ConsumerState<RedemptionHistoryScreen> {
  FilterOption _filter = FilterOption.all;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(redemptionHistoryProvider.notifier).fetchHistory(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(redemptionHistoryProvider);

    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(redemptionHistoryProvider.notifier).refresh(),
          color: TEDxColors.tedRed,
          backgroundColor: TEDxColors.cardDark,
          child: historyAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: TEDxColors.tedRed),
            ),
            error: (err, stack) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: TEDxColors.tedRed,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load history',
                      style: AppFonts.heading(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      err.toString(),
                      textAlign: TextAlign.center,
                      style: AppFonts.body(
                        color: TEDxColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => ref
                          .read(redemptionHistoryProvider.notifier)
                          .refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('RETRY'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TEDxColors.tedRed,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (allScans) {
              final scopedHistory = allScans
                  .where((scan) => scan.counter == widget.counter.name)
                  .toList();

              final filtered = scopedHistory.where((scan) {
                if (_filter == FilterOption.all) {
                  return true;
                }
                if (_filter == FilterOption.approved) {
                  return scan.outcome == Outcome.approved;
                }
                return scan.outcome != Outcome.approved;
              }).toList();

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeading(
                      label: 'PERSISTED ACTIVITY',
                      title: 'Redemption history',
                      support:
                          '${widget.counter.name} · ${filtered.length} verified records',
                    ),
                    const SizedBox(height: 16),

                    // Filter Buttons Row
                    Row(
                      children: [
                        _filterButton('All scans', FilterOption.all),
                        const SizedBox(width: 8),
                        _filterButton('Approved', FilterOption.approved),
                        const SizedBox(width: 8),
                        _filterButton('Rejected', FilterOption.rejected),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Scan List or Empty State
                    if (filtered.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: TEDxColors.cardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: TEDxColors.cardBorder),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.inbox_outlined,
                              color: TEDxColors.textMuted,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No Redemptions Found',
                              style: AppFonts.heading(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Redemption transactions recorded at this counter will appear here.',
                              textAlign: TextAlign.center,
                              style: AppFonts.body(
                                color: TEDxColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ScanListWidget(
                        scans: filtered,
                        onSelect: widget.onSelectScan,
                      ),
                    const SizedBox(height: 16),

                    const Center(
                      child: Text(
                        'Each attempt is recorded. Each benefit is issued once.',
                        style: TextStyle(
                          color: TEDxColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _filterButton(String label, FilterOption option) {
    final isSelected = _filter == option;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = option),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? TEDxColors.surfaceElevated
                : TEDxColors.cardDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? TEDxColors.tedRed : TEDxColors.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : TEDxColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
