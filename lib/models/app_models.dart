enum Outcome { ready, approved, redeemed, notEligible, invalid, network }

enum CounterKey { unassigned, registration, food, merch, goodie, workshop }

enum FilterOption { all, approved, rejected }

class CounterInfo {
  final CounterKey key;
  final String name;
  final String benefit;
  final String code;
  final int total;
  final int? id;
  final int? addonId;

  String get description => switch (code) {
    'C01' => 'Registration / Ticket Verification',
    'C02' => 'Food redemption',
    'C03' => 'T-Shirt redemption',
    'C04' => 'Goodie Bag redemption',
    'C05' => 'VIP Workshop Check-in',
    _ => '$benefit redemption',
  };

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
    code: 'C02',
    total: 0,
  );

  static const registration = CounterInfo(
    key: CounterKey.registration,
    name: 'Registration Counter',
    benefit: 'Ticket Verification',
    code: 'C01',
    total: 0,
  );

  static const unselected = CounterInfo(
    key: CounterKey.unassigned,
    name: 'No counter selected',
    benefit: 'Ticket Verification',
    code: '',
    total: 0,
  );

  static const merch = CounterInfo(
    key: CounterKey.merch,
    name: 'T-Shirt Counter',
    benefit: 'T-Shirt',
    code: 'C03',
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
    final code = json['code']?.toString() ?? '';
    final name = json['name']?.toString() ?? 'Assigned counter';
    final id = json['id'];
    if (id is! int) {
      throw const FormatException('Counter response is missing its ID.');
    }

    if (code == 'C01') {
      return CounterInfo(
        key: CounterKey.registration,
        name: name,
        benefit: 'Ticket Verification',
        code: code,
        total: 0,
        id: id,
      );
    }

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
    final addonId = json['addon_id'];
    if (addonId is! int) {
      throw const FormatException(
        'Non-registration counter response is missing its add-on ID.',
      );
    }

    return CounterInfo(
      key: key,
      name: name,
      benefit: addonName ?? 'Addon',
      code: json['code']?.toString() ?? 'Counter',
      total: 0,
      id: id,
      addonId: addonId,
    );
  }

  static CounterInfo fromKey(CounterKey key) {
    return switch (key) {
      CounterKey.unassigned => unselected,
      CounterKey.registration => registration,
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
  final String? orderId;
  final String volunteerName;
  final List<AttendeeModel> orderTickets;
  final String? statusMessage;
  final String? previousRedemptionAt;
  final String? previousRedemptionCounter;
  final String? previousRedemptionVolunteer;
  final String? previousRedemptionClaimant;
  final bool orderTicketsLoading;
  final bool orderTicketsLoadFailed;

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
    this.orderId,
    this.volunteerName = '',
    this.orderTickets = const [],
    this.statusMessage,
    this.previousRedemptionAt,
    this.previousRedemptionCounter,
    this.previousRedemptionVolunteer,
    this.previousRedemptionClaimant,
    this.orderTicketsLoading = false,
    this.orderTicketsLoadFailed = false,
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
    String? orderId,
    String? volunteerName,
    List<AttendeeModel>? orderTickets,
    String? statusMessage,
    String? previousRedemptionAt,
    String? previousRedemptionCounter,
    String? previousRedemptionVolunteer,
    String? previousRedemptionClaimant,
    bool? orderTicketsLoading,
    bool? orderTicketsLoadFailed,
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
      orderId: orderId ?? this.orderId,
      volunteerName: volunteerName ?? this.volunteerName,
      orderTickets: orderTickets ?? this.orderTickets,
      statusMessage: statusMessage ?? this.statusMessage,
      previousRedemptionAt: previousRedemptionAt ?? this.previousRedemptionAt,
      previousRedemptionCounter:
          previousRedemptionCounter ?? this.previousRedemptionCounter,
      previousRedemptionVolunteer:
          previousRedemptionVolunteer ?? this.previousRedemptionVolunteer,
      previousRedemptionClaimant:
          previousRedemptionClaimant ?? this.previousRedemptionClaimant,
      orderTicketsLoading: orderTicketsLoading ?? this.orderTicketsLoading,
      orderTicketsLoadFailed:
          orderTicketsLoadFailed ?? this.orderTicketsLoadFailed,
    );
  }
}

class AttendeeModel {
  final int? attendeeId;
  final String ticketId;
  final String name;
  final String ticketType; // VIP, Premium, Standard
  final List<String> benefits;
  final int? addonId;
  final bool? isEligible;
  final bool isRedeemed;
  final Outcome? redemptionOutcome;
  final String? statusMessage;
  final String? redeemedAt;
  final String? redeemedCounter;
  final String? redeemedBy;
  final String? claimedBy;

  const AttendeeModel({
    this.attendeeId,
    required this.ticketId,
    required this.name,
    required this.ticketType,
    required this.benefits,
    this.addonId,
    this.isEligible,
    this.isRedeemed = false,
    this.redemptionOutcome,
    this.statusMessage,
    this.redeemedAt,
    this.redeemedCounter,
    this.redeemedBy,
    this.claimedBy,
  });

  AttendeeModel copyWith({
    int? attendeeId,
    String? ticketId,
    String? name,
    String? ticketType,
    List<String>? benefits,
    int? addonId,
    bool? isEligible,
    bool? isRedeemed,
    Outcome? redemptionOutcome,
    String? statusMessage,
    String? redeemedAt,
    String? redeemedCounter,
    String? redeemedBy,
    String? claimedBy,
  }) {
    return AttendeeModel(
      attendeeId: attendeeId ?? this.attendeeId,
      ticketId: ticketId ?? this.ticketId,
      name: name ?? this.name,
      ticketType: ticketType ?? this.ticketType,
      benefits: benefits ?? this.benefits,
      addonId: addonId ?? this.addonId,
      isEligible: isEligible ?? this.isEligible,
      isRedeemed: isRedeemed ?? this.isRedeemed,
      redemptionOutcome: redemptionOutcome ?? this.redemptionOutcome,
      statusMessage: statusMessage ?? this.statusMessage,
      redeemedAt: redeemedAt ?? this.redeemedAt,
      redeemedCounter: redeemedCounter ?? this.redeemedCounter,
      redeemedBy: redeemedBy ?? this.redeemedBy,
      claimedBy: claimedBy ?? this.claimedBy,
    );
  }
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

const String outcomeApprovedLabel = 'Redeemed';
const String outcomeRedeemedLabel = 'Already redeemed';
const String outcomeNotEligibleLabel = 'Not eligible';
const String outcomeInvalidLabel = 'Invalid QR';
const String outcomeNetworkLabel = 'Connection lost';

String getOutcomeLabel(Outcome outcome) {
  switch (outcome) {
    case Outcome.ready:
      return 'Eligible - confirmation required';
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
