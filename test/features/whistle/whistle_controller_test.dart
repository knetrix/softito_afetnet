import 'package:afetnet/features/whistle/presentation/whistle_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeWhistleBackend implements WhistleAudioBackend {
  int playCalls = 0;
  int stopCalls = 0;
  int disposeCalls = 0;
  String? lastAsset;

  @override
  Future<void> configureAndPlayLoop(String assetPath) async {
    playCalls++;
    lastAsset = assetPath;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
  }
}

void main() {
  group('WhistleController', () {
    late _FakeWhistleBackend backend;
    late WhistleController controller;

    setUp(() {
      backend = _FakeWhistleBackend();
      controller = WhistleController(backend: backend);
    });

    tearDown(() => controller.dispose());

    test('başlangıçta pasiftir', () {
      expect(controller.isPlaying.value, isFalse);
    });

    test('toggle başlatır ve durdurur', () async {
      await controller.toggle();
      expect(controller.isPlaying.value, isTrue);
      expect(backend.playCalls, 1);
      expect(backend.lastAsset, WhistleController.whistleAssetPath);

      await controller.toggle();
      expect(controller.isPlaying.value, isFalse);
      expect(backend.stopCalls, 1);
    });

    test('dispose oynatıcıyı durdurur ve temizler', () {
      controller.dispose();
      expect(backend.stopCalls, greaterThanOrEqualTo(1));
      expect(backend.disposeCalls, 1);
    });
  });
}

