import 'package:afetnet/features/safety_signal/domain/safety_signal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  SafetySignal signal({String? handledBy}) => SafetySignal(
        uid: 'u1',
        state: SafetySignalState.danger,
        location: const LatLng(36.2, 36.16),
        geohash: 'sy3tyy6u',
        updatedAt: DateTime(2026, 11, 12, 11),
        handledBy: handledBy,
        handledAt: handledBy == null ? null : DateTime(2026, 11, 12, 11, 5),
      );

  test('isHandled yalnızca handledBy doluysa true', () {
    expect(signal().isHandled, isFalse);
    expect(signal(handledBy: 'yetkili1').isHandled, isTrue);
  });
}
