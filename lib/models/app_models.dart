enum Outcome {
  approved,
  redeemed,
  not_eligible,
  invalid,
  network,
}

enum CounterKey {
  food,
  merch,
}

enum FilterOption {
  all,
  approved,
  rejected,
}

class CounterInfo {
  final CounterKey key;
  final String name;
  final String benefit;
  final String code;
  final int total;

  const CounterInfo({
    required this.key,
    required this.name,
    required this.benefit,
    required this.code,
    required this.total,
  });

  static const food = CounterInfo(
    key: CounterKey.food,
    name: 'Food Counter 01',
    benefit: 'Lunch',
    code: 'FC–01',
    total: 842,
  );

  static const merch = CounterInfo(
    key: CounterKey.merch,
    name: 'Merchandise Counter',
    benefit: 'T-Shirt',
    code: 'MC–01',
    total: 1221,
  );

  static CounterInfo fromKey(CounterKey key) {
    return key == CounterKey.food ? food : merch;
  }
}

class ScanModel {
  final String id;
  final String time;
  final String name;
  final String ticketId;
  final String pass;
  final String benefit;
  final String counter;
  final Outcome outcome;
  final int? attendeeId;
  final int? addonId;
  final int? counterId;

  const ScanModel({
    required this.id,
    required this.time,
    required this.name,
    required this.ticketId,
    required this.pass,
    required this.benefit,
    required this.counter,
    required this.outcome,
    this.attendeeId,
    this.addonId,
    this.counterId,
  });

  ScanModel copyWith({
    String? id,
    String? time,
    String? name,
    String? ticketId,
    String? pass,
    String? benefit,
    String? counter,
    Outcome? outcome,
    int? attendeeId,
    int? addonId,
    int? counterId,
  }) {
    return ScanModel(
      id: id ?? this.id,
      time: time ?? this.time,
      name: name ?? this.name,
      ticketId: ticketId ?? this.ticketId,
      pass: pass ?? this.pass,
      benefit: benefit ?? this.benefit,
      counter: counter ?? this.counter,
      outcome: outcome ?? this.outcome,
      attendeeId: attendeeId ?? this.attendeeId,
      addonId: addonId ?? this.addonId,
      counterId: counterId ?? this.counterId,
    );
  }
}

class AttendeeModel {
  final String ticketId;
  final String name;
  final String ticketType; // VIP, Premium, General
  final List<String> benefits;

  const AttendeeModel({
    required this.ticketId,
    required this.name,
    required this.ticketType,
    required this.benefits,
  });
}

class VolunteerModel {
  final String id;
  final String name;
  final String role;
  final String email;

  const VolunteerModel({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
  });
}

const String outcomeApprovedLabel = 'Approved';
const String outcomeRedeemedLabel = 'Already redeemed';
const String outcomeNotEligibleLabel = 'Not eligible';
const String outcomeInvalidLabel = 'Invalid QR';
const String outcomeNetworkLabel = 'Connection lost';

String getOutcomeLabel(Outcome outcome) {
  switch (outcome) {
    case Outcome.approved:
      return outcomeApprovedLabel;
    case Outcome.redeemed:
      return outcomeRedeemedLabel;
    case Outcome.not_eligible:
      return outcomeNotEligibleLabel;
    case Outcome.invalid:
      return outcomeInvalidLabel;
    case Outcome.network:
      return outcomeNetworkLabel;
  }
}
