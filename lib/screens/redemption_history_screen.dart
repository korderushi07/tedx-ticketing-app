import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';
import '../models/app_models.dart';

class RedemptionHistoryScreen extends StatefulWidget {
  final List<HistoryLogItem> logs;
  final Function(HistoryLogItem) onItemTap;

  const RedemptionHistoryScreen({
    super.key,
    required this.logs,
    required this.onItemTap,
  });

  @override
  State<RedemptionHistoryScreen> createState() => _RedemptionHistoryScreenState();
}

class _RedemptionHistoryScreenState extends State<RedemptionHistoryScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final filteredLogs = widget.logs.where((log) {
      final matchesSearch = log.attendeeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          log.ticketId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          log.item.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_selectedFilter == 'ALL') return true;
      if (_selectedFilter == 'SUCCESS' && log.status == RedemptionStatus.success) return true;
      if (_selectedFilter == 'CLAIMED' && log.status == RedemptionStatus.alreadyClaimed) return true;
      if (_selectedFilter == 'NOT_ELIGIBLE' && log.status == RedemptionStatus.notEligible) return true;

      return false;
    }).toList();

    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      appBar: AppBar(
        title: const Text('Redemption History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: TEDxColors.textSecondary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exporting log data to server backup...'),
                  backgroundColor: TEDxColors.cardDark,
                ),
              );
            },
            tooltip: 'Export Logs',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search attendee name, ID, or item...',
                  prefixIcon: const Icon(Icons.search_rounded, color: TEDxColors.textSecondary, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: TEDxColors.textSecondary),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 14),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('ALL', 'All Logs (${widget.logs.length})'),
                    const SizedBox(width: 8),
                    _filterChip('SUCCESS', 'Successful (192)'),
                    const SizedBox(width: 8),
                    _filterChip('CLAIMED', 'Already Claimed (31)'),
                    const SizedBox(width: 8),
                    _filterChip('NOT_ELIGIBLE', 'Not Eligible (25)'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Log count header
              Text(
                'Showing ${filteredLogs.length} Records',
                style: const TextStyle(
                  color: TEDxColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              // List of History Items
              Expanded(
                child: filteredLogs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.history_toggle_off_rounded, size: 48, color: TEDxColors.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              'No redemption records found',
                              style: TextStyle(color: TEDxColors.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredLogs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = filteredLogs[index];
                          return _buildHistoryItemCard(item);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filterKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? TEDxColors.tedRed : TEDxColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? TEDxColors.tedRed : TEDxColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : TEDxColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItemCard(HistoryLogItem log) {
    StatusBadge badge;
    IconData statusIcon;
    Color iconColor;

    switch (log.status) {
      case RedemptionStatus.success:
        badge = StatusBadge.available();
        statusIcon = Icons.check_circle_rounded;
        iconColor = TEDxColors.success;
        break;
      case RedemptionStatus.alreadyClaimed:
        badge = StatusBadge.claimed();
        statusIcon = Icons.warning_amber_rounded;
        iconColor = TEDxColors.warning;
        break;
      case RedemptionStatus.notEligible:
        badge = StatusBadge.notIncluded();
        statusIcon = Icons.block_rounded;
        iconColor = TEDxColors.error;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onItemTap(log),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TEDxColors.cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: TEDxColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.attendeeName,
                      style: const TextStyle(
                        color: TEDxColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${log.item} • ${log.ticketId}',
                      style: const TextStyle(
                        color: TEDxColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    log.time,
                    style: const TextStyle(
                      color: TEDxColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  badge,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
