enum Outcome { approved, redeemed, notEligible, invalid, network }

enum CounterKey { food, merch, goodie, workshop }

enum FilterOption { all, approved, rejected }

class CounterInfo {
  final CounterKey key;
  final String name;
  final String benefit;
  final String code;
  final int total;
  final int? id;
  final int? addonId;

  const CounterInfo({
    required this.key,
    required this.name,
    required this.benefit,
    required this.code,
    required this.total,
    this.id,
    this.addonId,
  });

  static const food = CounterInfo(
    key: CounterKey.food,
    name: 'Food Counter 01',
    benefit: 'Lunch',
    code: 'FC–01',
    total: 0,
  );

  static const merch = CounterInfo(
    key: CounterKey.merch,
    name: 'Merchandise Counter',
    benefit: 'T-Shirt',
    code: 'MC–01',
    total: 0,
  );

  static const goodie = CounterInfo(
    key: CounterKey.goodie,
    name: 'Goodie Bag Counter',
    benefit: 'Goodie Bag',
    code: 'C04',
    total: 0,
  );

  static const workshop = CounterInfo(
    key: CounterKey.workshop,
    name: 'VIP Workshop Desk',
    benefit: 'Workshop',
    code: 'C05',
    total: 0,
  );

  factory CounterInfo.fromJson(Map<String, dynamic> json) {
    final addonName = json['addon']?.toString().trim();
    final normalizedAddon = addonName?.toLowerCase() ?? '';
    final key = switch (normalizedAddon) {
      'food' || 'lunch' || 'refreshment' => CounterKey.food,
      't-shirt' || 'tshirt' || 'merchandise' || 'merch' => CounterKey.merch,
      'goodie bag' || 'goodies' => CounterKey.goodie,
      'workshop' => CounterKey.workshop,
      _ => throw FormatException(
        'Unsupported counter add-on: ${addonName ?? 'none'}',
      ),
    };
    final id = json['id'];
    final addonId = json['addon_id'];
    if (id is! int || addonId is! int) {
      throw const FormatException(
        'Counter response is missing its ID or add-on ID.',
      );
    }

    return CounterInfo(
      key: key,
      name: json['name']?.toString() ?? 'Assigned counter',
      benefit: addonName ?? 'Addon',
      code: json['code']?.toString() ?? 'Counter',
      total: 0,
      id: id,
      addonId: addonId,
    );
  }

  static CounterInfo fromKey(CounterKey key) {
    return switch (key) {
      CounterKey.food => food,
      CounterKey.merch => merch,
      CounterKey.goodie => goodie,
      CounterKey.workshop => workshop,
    };
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
    case Outcome.notEligible:
      return outcomeNotEligibleLabel;
    case Outcome.invalid:
      return outcomeInvalidLabel;
    case Outcome.network:
      return outcomeNetworkLabel;
  }
}
