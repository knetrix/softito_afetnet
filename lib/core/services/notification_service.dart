import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Yerel bildirimler ve FCM `all_users` topic aboneliği servisi
/// (PROJECT_NEW.md §6, Kural 10, R2).
abstract interface class NotificationService {
  static const criticalChannelId = 'afetnet_critical_alerts';
  static const allUsersTopic = 'all_users';

  Future<void> initialize();

  /// Kullanıcı tercihine göre `all_users` topic aboneliğini günceller.
  /// `optIn == false` ise önceki abonelik varsa bile topic'ten çıkar.
  Future<void> syncTopicSubscription({required bool optIn});

  /// Uygulama açıkken yerel bildirim gösterir (G3 FCM, G5 panik, G6 anons/stok).
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });

  void dispose();
}

class DeviceNotificationService implements NotificationService {
  DeviceNotificationService({
    FlutterLocalNotificationsPlugin? localNotifications,
    this._messaging,
  }) : _local = localNotifications ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _local;
  final FirebaseMessaging? _messaging;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  bool _initialized = false;
  bool? _lastOptIn;

  FirebaseMessaging get _fcm => _messaging ?? FirebaseMessaging.instance;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestSoundPermission: false,
        requestBadgePermission: false,
      );
      await _local.initialize(
        settings: const InitializationSettings(
          android: androidInit,
          iOS: darwinInit,
        ),
      );

      final androidPlugin =
          _local.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          NotificationService.criticalChannelId,
          'Kritik Uyarılar',
          description: 'Acil durum, tahliye ve kritik stok bildirimleri',
          importance: Importance.max,
          playSound: true,
        ),
      );
      await androidPlugin?.requestNotificationsPermission();
    } catch (_) {
      // Test veya desteklenmeyen ortamlarda sessizce geçer.
    }

    try {
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _foregroundSub = FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    } catch (_) {
      // iOS simülatör veya APNs olmadan FCM hata verirse uygulama çökmez.
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title'] as String?;
    final body = message.notification?.body ?? message.data['body'] as String?;
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }
    await showLocalNotification(
      id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch % 100000,
      title: title ?? 'AfetNet',
      body: body ?? '',
      payload: message.data['type'] as String?,
    );
  }

  @override
  Future<void> syncTopicSubscription({required bool optIn}) async {
    if (_lastOptIn == optIn) return;
    try {
      if (optIn) {
        await _fcm.subscribeToTopic(NotificationService.allUsersTopic);
      } else {
        await _fcm.unsubscribeFromTopic(NotificationService.allUsersTopic);
      }
      _lastOptIn = optIn;
    } catch (e) {
      debugPrint('FCM topic sync skipped: $e');
    }
  }

  @override
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _local.show(
        id: id,
        title: title,
        body: body,
        payload: payload,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            NotificationService.criticalChannelId,
            'Kritik Uyarılar',
            channelDescription: 'Acil durum, tahliye ve kritik stok bildirimleri',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBanner: true,
          ),
        ),
      );
    } catch (_) {
      // Bildirim gösterimi başarısız olursa uygulamayı durdurmaz.
    }
  }

  @override
  void dispose() {
    _foregroundSub?.cancel();
  }
}

