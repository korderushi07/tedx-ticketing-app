enum EntitlementState {
  available,
  claimed,
  notIncluded,
}

enum RedemptionStatus {
  success,
  alreadyClaimed,
  notEligible,
}

class EntitlementItem {
  final String id;
  final String name;
  final EntitlementState state;
  final String? claimedTime;
  final String? claimedCounter;

  const EntitlementItem({
    required this.id,
    required this.name,
    required this.state,
    this.claimedTime,
    this.claimedCounter,
  });
}

class AttendeeModel {
  final String ticketId;
  final String name;
  final String email;
  final String phone;
  final String ticketType; // PREMIUM, STANDARD, VIP, etc.
  final List<EntitlementItem> entitlements;

  const AttendeeModel({
    required this.ticketId,
    required this.name,
    required this.email,
    required this.phone,
    required this.ticketType,
    required this.entitlements,
  });

  EntitlementItem? getEntitlement(String itemName) {
    try {
      return entitlements.firstWhere(
        (e) => e.name.toLowerCase() == itemName.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

class VolunteerModel {
  final String id;
  final String name;
  final String role;
  final String counterId;
  final String counterName;
  final String eventName;
  final String avatarInitials;

  const VolunteerModel({
    required this.id,
    required this.name,
    required this.role,
    required this.counterId,
    required this.counterName,
    required this.eventName,
    required this.avatarInitials,
  });
}

class HistoryLogItem {
  final String id;
  final String attendeeName;
  final String ticketId;
  final String item;
  final String time;
  final RedemptionStatus status;
  final String counterId;
  final String volunteerId;

  const HistoryLogItem({
    required this.id,
    required this.attendeeName,
    required this.ticketId,
    required this.item,
    required this.time,
    required this.status,
    required this.counterId,
    required this.volunteerId,
  });
}

class CounterStats {
  final int totalScans;
  final int successfulClaims;
  final int alreadyClaimed;
  final int notEligible;
  final int itemGoal;

  const CounterStats({
    required this.totalScans,
    required this.successfulClaims,
    required this.alreadyClaimed,
    required this.notEligible,
    required this.itemGoal,
  });
}
