// Düdük sesini çalar/durdurur (internetsiz).

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Düdük ses oynatıcı soyutlaması (unit testlerde sahte oynatıcı ile değiştirilebilir).
abstract interface class WhistleAudioBackend {
  Future<void> configureAndPlayLoop(String assetPath);
  Future<void> stop();
  Future<void> dispose();
}

/// `audioplayers` tabanlı gerçek ses oynatıcı.
///
/// Android'de medya sesi kısık olsa bile duyulabilmesi için `alarm` kanalını,
/// iOS'ta sessiz anahtarda bile çalması için `playback` kategorisini kullanır.
class AudioPlayersWhistleBackend implements WhistleAudioBackend {
  AudioPlayersWhistleBackend({AudioPlayer? player})
      : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  bool _configured = false;

  @override
  Future<void> configureAndPlayLoop(String assetPath) async {
    if (!_configured) {
      await _player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.alarm,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
          ),
        ),
      );
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(1.0);
      _configured = true;
    }
    await _player.play(AssetSource(assetPath));
  }

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();
}

/// A3 — Çevrimdışı Düdük ekranı kontrolcüsü (`--ui-only`, `ValueNotifier` tabanlı).
class WhistleController {
  WhistleController({WhistleAudioBackend? backend})
      : _backend = backend ?? AudioPlayersWhistleBackend();

  static const whistleAssetPath = 'sounds/whistle.wav';

  final WhistleAudioBackend _backend;
  final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);
  bool _disposed = false;
  bool _busy = false;

  Future<void> toggle() async {
    if (_disposed || _busy) return;
    _busy = true;
    try {
      if (isPlaying.value) {
        await _backend.stop();
        if (!_disposed) isPlaying.value = false;
      } else {
        await _backend.configureAndPlayLoop(whistleAssetPath);
        if (!_disposed) isPlaying.value = true;
      }
    } catch (_) {
      // Ses oynatma başarısız olursa durum tutarlı kalır.
      if (!_disposed) isPlaying.value = false;
    } finally {
      _busy = false;
    }
  }

  Future<void> stop() async {
    if (_disposed || !isPlaying.value) return;
    await _backend.stop();
    if (!_disposed) isPlaying.value = false;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _backend.stop().catchError((Object _) {});
    _backend.dispose().catchError((Object _) {});
    isPlaying.dispose();
  }
}

