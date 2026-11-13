import 'package:afetnet/core/constants/help_type.dart';
import 'package:afetnet/core/utils/priority_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PriorityPolicy', () {
    test('debris ve medical -> 1 (Kritik)', () {
      expect(PriorityPolicy.calculate(HelpType.debris), PriorityPolicy.critical);
      expect(PriorityPolicy.calculate(HelpType.medical), PriorityPolicy.critical);
      expect(PriorityPolicy.calculate(HelpType.debris), 1);
      expect(PriorityPolicy.calculate(HelpType.medical), 1);
    });

    test('shelter, heating ve babyFood -> 2 (Acil)', () {
      expect(PriorityPolicy.calculate(HelpType.shelter), PriorityPolicy.urgent);
      expect(PriorityPolicy.calculate(HelpType.heating), PriorityPolicy.urgent);
      expect(PriorityPolicy.calculate(HelpType.babyFood), PriorityPolicy.urgent);
      expect(PriorityPolicy.calculate(HelpType.shelter), 2);
      expect(PriorityPolicy.calculate(HelpType.heating), 2);
      expect(PriorityPolicy.calculate(HelpType.babyFood), 2);
    });

    test('water ve other -> 3 (Normal)', () {
      expect(PriorityPolicy.calculate(HelpType.water), PriorityPolicy.normal);
      expect(PriorityPolicy.calculate(HelpType.other), PriorityPolicy.normal);
      expect(PriorityPolicy.calculate(HelpType.water), 3);
      expect(PriorityPolicy.calculate(HelpType.other), 3);
    });

    test('highest iki öncelikten en yükseğini (sayıca küçüğünü) seçer', () {
      expect(PriorityPolicy.highest(1, 2), 1);
      expect(PriorityPolicy.highest(2, 1), 1);
      expect(PriorityPolicy.highest(2, 3), 2);
      expect(PriorityPolicy.highest(3, 2), 2);
      expect(PriorityPolicy.highest(1, 3), 1);
      expect(PriorityPolicy.highest(2, 2), 2);
    });
  });
}
