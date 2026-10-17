import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';
import '../models/app_models.dart';
import '../services/api_service.dart';

class CounterAssignmentScreen extends StatefulWidget {
  final CounterInfo counter;
  final String volunteerName;
  final String volunteerCode;
  final ValueChanged<CounterInfo>? onCounterSelected;
  final VoidCallback onStartScanning;
  final VoidCallback? onBackPressed;

  const CounterAssignmentScreen({
    super.key,
    required this.counter,
    required this.volunteerName,
    required this.volunteerCode,
    required this.onStartScanning,
    this.onCounterSelected,
    this.onBackPressed,
  });

  @override
  State<CounterAssignmentScreen> createState() =>
      _CounterAssignmentScreenState();
}

class _CounterAssignmentScreenState extends State<CounterAssignmentScreen> {
  late CounterInfo _selectedCounter;
  List<CounterInfo> _availableCounters = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCounter = widget.counter;
    _loadCounters();
  }

  Future<void> _loadCounters() async {
    setState(() => _isLoading = true);
    try {
      final counters = await ApiService().getCounters();
      if (mounted) {
        setState(() {
          if (counters.isNotEmpty) {
            _availableCounters = counters;
            // Match selected counter if present in loaded counters
            final matched = counters.where(
              (c) => c.id == _selectedCounter.id || c.code == _selectedCounter.code,
            );
            if (matched.isNotEmpty) {
              _selectedCounter = matched.first;
            }
          } else {
            _availableCounters = [
              CounterInfo.food,
              CounterInfo.merch,
              CounterInfo.goodie,
              CounterInfo.workshop,
            ];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[CounterAssignmentScreen] Error loading counters: $e');
      if (mounted) {
        setState(() {
          _availableCounters = [
            CounterInfo.food,
            CounterInfo.merch,
            CounterInfo.goodie,
            CounterInfo.workshop,
          ];
          _isLoading = false;
        });
      }
    }
  }

  void _handleConfirm() {
    ApiService().setSelectedCounter(_selectedCounter);
    widget.onCounterSelected?.call(_selectedCounter);
    widget.onStartScanning();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.onBackPressed != null) ...[
                GestureDetector(
                  onTap: widget.onBackPressed,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Color(0xFFA1A1AA),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'BACK TO DASHBOARD',
                        style: AppFonts.mono(
                          color: const Color(0xFFA1A1AA),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const SectionHeading(
                label: 'COUNTER SELECTION',
                title: 'Select active counter.',
                support:
                    'Choose the counter you are operating for this shift. Switch anytime.',
              ),
              const SizedBox(height: 20),

              // Available Counters Selector Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AVAILABLE COUNTERS',
                    style: AppFonts.mono(
                      color: TEDxColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: TEDxColors.tedRed,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Counters List
              ..._availableCounters.map((counter) {
                final isSelected =
                    (counter.id != null && counter.id == _selectedCounter.id) ||
                    counter.code == _selectedCounter.code;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCounter = counter;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1E1718)
                          : TEDxColors.cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? TEDxColors.tedRed
                            : TEDxColors.cardBorder,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Radio circle
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? TEDxColors.tedRed
                                  : const Color(0xFF52525B),
                              width: 2,
                            ),
                            color: isSelected
                                ? TEDxColors.tedRed
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Center(
                                  child: Icon(
                                    Icons.check,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 14),

                        // Counter Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? TEDxColors.tedRed
                                          : const Color(0xFF27272A),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      counter.code,
                                      style: AppFonts.mono(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    counter.name,
                                    style: AppFonts.heading(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${counter.benefit} redemption',
                                style: AppFonts.body(
                                  color: TEDxColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Volunteer Profile Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: TEDxColors.tedRed,
                      child: Text(
                        widget.volunteerName
                            .trim()
                            .split(RegExp(r'\s+'))
                            .where((part) => part.isNotEmpty)
                            .take(2)
                            .map((part) => part[0].toUpperCase())
                            .join(),
                        style: AppFonts.heading(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.volunteerName,
                          style: AppFonts.heading(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: widget.volunteerCode,
                                style: AppFonts.mono(
                                  color: TEDxColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: ' · Operating volunteer',
                                style: AppFonts.body(
                                  color: TEDxColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Counter Permissions Box for active selection
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PERMISSIONS FOR ${_selectedCounter.code}',
                      style: AppFonts.mono(
                        color: TEDxColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _permissionRow('Scan attendee QR codes'),
                    const SizedBox(height: 8),
                    _permissionRow('Redeem ${_selectedCounter.benefit}'),
                    const SizedBox(height: 8),
                    _permissionRow('Audit scan events for ${_selectedCounter.name}'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              ActionButton(
                text: 'CONFIRM COUNTER & START SCANNING',
                trailingArrow: '→',
                onPressed: _handleConfirm,
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Counter context is recorded with every scan and redemption',
                  style: AppFonts.body(
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

  Widget _permissionRow(String text) {
    return Row(
      children: [
        Text(
          '✓',
          style: AppFonts.body(
            color: TEDxColors.success,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: AppFonts.body(
            color: TEDxColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
