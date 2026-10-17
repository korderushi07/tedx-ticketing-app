import 'package:flutter_test/flutter_test.dart';
import 'package:ticketingapp/models/app_models.dart';

void main() {
  test('counter metadata maps all configured backend add-ons', () {
    final counterSpecs = [
      (
        'C01',
        'Registration Counter',
        'Food',
        1,
        CounterKey.food,
        'Registration / Ticket Verification',
      ),
      ('C02', 'Food Counter 01', 'Food', 1, CounterKey.food, 'Food redemption'),
      (
        'C03',
        'T-Shirt Counter',
        'T-Shirt',
        2,
        CounterKey.merch,
        'T-Shirt redemption',
      ),
      (
        'C04',
        'Goodie Bag Counter',
        'Goodie Bag',
        3,
        CounterKey.goodie,
        'Goodie Bag redemption',
      ),
      (
        'C05',
        'VIP Workshop Desk',
        'Workshop',
        4,
        CounterKey.workshop,
        'VIP Workshop Check-in',
      ),
    ];

    for (var index = 0; index < counterSpecs.length; index++) {
      final (code, name, addon, addonId, key, description) =
          counterSpecs[index];
      final counter = CounterInfo.fromJson({
        'id': index + 1,
        'name': name,
        'code': code,
        'addon': addon,
        'addon_id': addonId,
        'is_active': true,
      });

      expect(counter.code, code);
      expect(counter.name, name);
      expect(counter.key, key);
      expect(counter.id, index + 1);
      expect(counter.addonId, addonId);
      expect(counter.description, description);
    }
  });
}
