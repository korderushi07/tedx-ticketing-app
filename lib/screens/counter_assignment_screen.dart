import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';

class CounterAssignmentScreen extends StatefulWidget {
  final VoidCallback onStartCounter;

  const CounterAssignmentScreen({super.key, required this.onStartCounter});

  @override
  State<CounterAssignmentScreen> createState() => _CounterAssignmentScreenState();
}

class _CounterAssignmentScreenState extends State<CounterAssignmentScreen> {
  String _selectedCounterId = 'C-03';

  final List<Map<String, String>> _availableCounters = [
    {
      'id': 'C-03',
      'name': 'T-Shirt Counter',
      'category': 'Swag & Merchandise',
      'location': 'Main Concourse North',
    },
    {
      'id': 'C-02',
      'name': 'Goodie Bag Counter',
      'category': 'Welcome Kits',
      'location': 'Main Entry Hall B',
    },
    {
      'id': 'C-01',
      'name': 'Food & Beverage',
      'category': 'Catered Luncheon',
      'location': 'Dining Atrium',
    },
    {
      'id': 'C-04',
      'name': 'VIP Lounge Entitlements',
      'category': 'Speaker & VIP Access',
      'location': 'Executive Level 2',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final activeCounter = _availableCounters.firstWhere(
      (c) => c['id'] == _selectedCounterId,
    );

    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      appBar: AppBar(
        title: const TEDxLogo(fontSize: 20, subtitle: ''),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: TEDxColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: TEDxColors.cardBorder),
            ),
            child: const Row(
              children: [
                Icon(Icons.event_seat_rounded, size: 12, color: TEDxColors.tedRed),
                SizedBox(width: 4),
                Text(
                  'TEDx YCCE 2026',
                  style: TextStyle(
                    color: TEDxColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Greeting Section
              const Text(
                'Good Morning,',
                style: TextStyle(
                  color: TEDxColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'Rushikesh',
                    style: TextStyle(
                      color: TEDxColors.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: TEDxColors.cardDark,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: TEDxColors.cardBorder),
                    ),
                    child: const Text(
                      'VOL-024',
                      style: TextStyle(
                        color: TEDxColors.tedRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Assigned Counter Header
              const Text(
                'Assigned Operational Station',
                style: TextStyle(
                  color: TEDxColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Active Counter Highlight Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TEDxColors.tedRed.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: TEDxColors.tedRed.withOpacity(0.08),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: TEDxColors.tedRed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'COUNTER ${activeCounter['id']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        StatusBadge.active(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      activeCounter['name']!,
                      style: const TextStyle(
                        color: TEDxColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${activeCounter['category']} • ${activeCounter['location']}',
                      style: const TextStyle(
                        color: TEDxColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Counter Select list header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Switch Assigned Counter',
                    style: TextStyle(
                      color: TEDxColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${_availableCounters.length} Available',
                    style: const TextStyle(
                      color: TEDxColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // List of counters
              Expanded(
                child: ListView.separated(
                  itemCount: _availableCounters.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = _availableCounters[index];
                    final isSelected = item['id'] == _selectedCounterId;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCounterId = item['id']!;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? TEDxColors.surfaceElevated
                                : TEDxColors.cardDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? TEDxColors.tedRed
                                  : TEDxColors.cardBorder,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? TEDxColors.tedRedSubtle
                                      : TEDxColors.inputBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    item['id']!,
                                    style: TextStyle(
                                      color: isSelected
                                          ? TEDxColors.tedRed
                                          : TEDxColors.textSecondary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name']!,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : TEDxColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['location']!,
                                      style: const TextStyle(
                                        color: TEDxColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: TEDxColors.tedRed,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              // CTA Button
              TEDxButton(
                text: 'Start Counter Session',
                icon: Icons.play_arrow_rounded,
                onPressed: widget.onStartCounter,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
