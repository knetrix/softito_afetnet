import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/location_service.dart';
import '../../../core/services/notification_service.dart';

/// Afetzede uygulaması açıkken yeni tahliye ve
/// artçı sarsıntı anonslarını takip eder.
///
/// PROJECT_NEW.md - Kural 10
class BroadcastNotificationListener {
  BroadcastNotificationListener({
    required this._locationService,
    required this._notificationService,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final LocationService _locationService;
  final NotificationService _notificationService;
  final FirebaseFirestore _firestore;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  String? _activeUid;
  bool _baselineReady = false;

  final Set<String> _processedIds = {};
  final Set<String> _processingIds = {};

  static const String _storagePrefix = 'afetnet_seen_broadcasts_';

  static const int _maxRemembered = 150;

  /// Yalnızca bildirimleri kabul eden afetzede için çağrılır.
  Future<void> start(String uid) async {
    if (_activeUid == uid) {
      return;
    }

    stop();

    _activeUid = uid;
    _baselineReady = false;

    try {
      final preferences = await SharedPreferences.getInstance();

      if (_activeUid != uid) {
        return;
      }

      _processedIds.addAll(
        preferences.getStringList('$_storagePrefix$uid') ?? [],
      );

      await _notificationService.initialize();

      if (_activeUid != uid) {
        return;
      }

      // En yeni 50 kayıt takip edilir.
      // İlk sunucu snapshot'ı mevcut kayıtların
      // başlangıç durumudur; geçmişe bildirim atılmaz.
      final query = _firestore
          .collection('broadcasts')
          .orderBy('createdAt', descending: true)
          .limit(50);

      _subscription = query
          .snapshots(includeMetadataChanges: true)
          .listen(
            _onSnapshot,
            onError: (Object error) {
              debugPrint('Tahliye anonsları dinlenemedi: $error');
            },
          );
    } catch (error) {
      debugPrint('Tahliye anonsu dinleyicisi başlatılamadı: $error');
    }
  }

  void _onSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (_activeUid == null) {
      return;
    }

    // Önbelleği başlangıç durumu kabul etmiyoruz.
    // İlk sunucu sonucunu bekliyoruz.
    if (snapshot.metadata.isFromCache) {
      return;
    }

    if (!_baselineReady) {
      _baselineReady = true;
      return;
    }

    for (final change in snapshot.docChanges) {
      if (change.type != DocumentChangeType.added) {
        continue;
      }

      unawaited(_handleBroadcast(change.doc));
    }
  }

  Future<void> _handleBroadcast(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) async {
    final uid = _activeUid;

    if (uid == null) {
      return;
    }

    final id = document.id;

    if (_processedIds.contains(id) || _processingIds.contains(id)) {
      return;
    }

    _processingIds.add(id);
    try {
      final data = document.data();

      // Belge silinmişse veya veri boşsa işleme devam etme.
      if (data == null) {
        return;
      }

      final type = data['type'];
      final title = data['title'];
      final body = data['body'];
      final center = data['center'];
      final radius = data['radiusMeters'];

      if (type != 'evacuation' && type != 'aftershock') {
        return;
      }

      if (title is! String ||
          title.trim().isEmpty ||
          body is! String ||
          body.trim().isEmpty ||
          center is! GeoPoint ||
          radius is! num) {
        return;
      }

      final radiusMeters = radius.toDouble();

      if (!radiusMeters.isFinite ||
          radiusMeters < 100 ||
          radiusMeters > 20000) {
        return;
      }

      // Panik sinyalinde kullanılan mevcut G3 servisi.
      // Konum izni yoksa bildirim gönderilmez.
      final coordinates = await _locationService.resolveCoordinates();

      if (_activeUid != uid) {
        return;
      }

      if (coordinates == null) {
        debugPrint('Anons kontrolü: cihaz konumu alınamadı.');
        return;
      }

      final distanceMeters = Geolocator.distanceBetween(
        coordinates.latitude,
        coordinates.longitude,
        center.latitude,
        center.longitude,
      );

      // Hedef bölgenin dışındaki kullanıcıya
      // yerel bildirim gönderilmez.
      if (distanceMeters > radiusMeters) {
        return;
      }

      final notificationId = id.hashCode & 0x7fffffff;

      await _notificationService.showLocalNotification(
        id: notificationId,
        title: title,
        body: body,
        payload: 'broadcast:$id',
      );

      if (_activeUid != uid) {
        return;
      }

      _processedIds.add(id);

      await _saveProcessedIds(uid);

      debugPrint(
        'Bölgesel anons işlendi: $id '
        '(${distanceMeters.round()} m)',
      );
    } catch (error) {
      debugPrint('Bölgesel anons kontrol hatası: $error');
    } finally {
      _processingIds.remove(id);
    }
  }

  Future<void> _saveProcessedIds(String uid) async {
    final preferences = await SharedPreferences.getInstance();

    if (_activeUid != uid) {
      return;
    }

    // Kaydedilen ID sayısını sınırlıyoruz.
    final remembered = _processedIds.toList();

    if (remembered.length > _maxRemembered) {
      remembered.removeRange(0, remembered.length - _maxRemembered);
    }

    _processedIds
      ..clear()
      ..addAll(remembered);

    await preferences.setStringList('$_storagePrefix$uid', remembered);
  }

  /// Hesap değiştiğinde veya çıkış yapıldığında
  /// Firestore dinleyicisi kapatılır.
  void stop() {
    _activeUid = null;
    _baselineReady = false;

    _subscription?.cancel();
    _subscription = null;

    _processedIds.clear();
    _processingIds.clear();
  }

  void dispose() {
    stop();
  }
}
