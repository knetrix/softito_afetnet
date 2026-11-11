import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../l10n/app_localizations.dart';
import '../utils/permission_queue.dart';

/// Yerel bildirimler ve FCM `all_users` topic aboneliği servisi
/// (PROJECT_NEW.md §6, Kural 10, R2).
abstract interface class NotificationService {
  static const criticalChannelId = 'afetnet_critical_alerts';
  static const allUsersTopic = 'all_users';

  Future<void> initialize();

  /// Kullanıcı tercihine göre `all_users` topic aboneliğini günceller.
  /// `optIn == true` ise bildirim izni ilk kez burada istenir (açılışta değil).
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
  bool _permissionRequested = false;
  bool? _lastOptIn;
  late final AppLocalizations _l10n = _deviceLocalizations();

  FirebaseMessaging get _fcm => _messaging ?? FirebaseMessaging.instance;

  /// Kanal adı sistem ayarlarında görünür; uygulamayla aynı dil kuralı (tr, değilse en).
  static AppLocalizations _deviceLocalizations() {
    final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return lookupAppLocalizations(Locale(code == 'tr' ? 'tr' : 'en'));
  }

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
        AndroidNotificationChannel(
          NotificationService.criticalChannelId,
          _l10n.notificationChannelName,
          description: _l10n.notificationChannelDescription,
          importance: Importance.max,
          playSound: true,
        ),
      );
    } catch (_) {
      // Test veya desteklenmeyen ortamlarda sessizce geçer.
    }

    try {
      _foregroundSub = FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    } catch (_) {
      // iOS simülatör veya APNs olmadan FCM hata verirse uygulama çökmez.
    }
  }

  Future<void> _requestPermissionOnce() async {
    if (_permissionRequested) return;
    _permissionRequested = true;
    try {
      await PermissionQueue.run(() async {
        await _local
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        await _fcm.requestPermission(alert: true, badge: true, sound: true);
      });
    } catch (_) {
      // İzin istenemese de abonelik denenir.
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
        await _requestPermissionOnce();
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
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            NotificationService.criticalChannelId,
            _l10n.notificationChannelName,
            channelDescription: _l10n.notificationChannelDescription,
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

