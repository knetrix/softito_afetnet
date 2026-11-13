import 'dart:async';

import 'package:afetnet/core/utils/permission_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('izin istekleri sırayla çalışır, hata kuyruğu durdurmaz', () async {
    final log = <String>[];
    final first = Completer<void>();

    final a = PermissionQueue.run(() async {
      log.add('a başladı');
      await first.future;
      log.add('a bitti');
    });
    final b = PermissionQueue.run(() async => throw StateError('b'));
    final c = PermissionQueue.run(() async => log.add('c'));

    await Future<void>.delayed(Duration.zero);
    expect(log, ['a başladı'], reason: 'a bitmeden diğerleri başlamaz');

    first.complete();
    await a;
    await expectLater(b, throwsStateError);
    await c;
    expect(log, ['a başladı', 'a bitti', 'c']);
  });
}
