import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';
import '../models/app_models.dart';

class RedemptionHistoryScreen extends StatefulWidget {
  final CounterInfo counter;
  final List<ScanModel> history;
  final ValueChanged<ScanModel> onSelectScan;

  const RedemptionHistoryScreen({
    super.key,
    required this.counter,
    required this.history,
    required this.onSelectScan,
  });

  @override
  State<RedemptionHistoryScreen> createState() => _RedemptionHistoryScreenState();
}

class _RedemptionHistoryScreenState extends State<RedemptionHistoryScreen> {
  FilterOption _filter = FilterOption.all;

  @override
  Widget build(BuildContext context) {
    final scopedHistory = widget.history.where(
      (scan) => scan.counter == widget.counter.name,
    ).toList();

    final filtered = scopedHistory.where((scan) {
      if (_filter == FilterOption.all) return true;
      if (_filter == FilterOption.approved) return scan.outcome == Outcome.approved;
      return scan.outcome != Outcome.approved;
    }).toList();

    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeading(
                label: 'TODAY’S ACTIVITY',
                title: 'Scan history',
                support: '${widget.counter.name} · ${scopedHistory.length} demo records',
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

              // Scan List
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
            color: isSelected ? TEDxColors.surfaceElevated : TEDxColors.cardDark,
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
