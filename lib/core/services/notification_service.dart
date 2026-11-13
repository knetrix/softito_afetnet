// Bildirim servisi. İki iş yapar:
// 1) Uygulama açıkken ekrana yerel bildirim gösterir, 2) FCM ile all_users konusuna (topic) abone olur.

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../l10n/app_localizations.dart';
import '../utils/permission_queue.dart';
import 'locale_controller.dart';

/// Yerel bildirimler ve FCM `all_users` topic aboneliği servisi
/// (PROJECT_NEW.md §6, Kural 10, R2).
abstract interface class NotificationService {
  static const criticalChannelId = 'afetnet_critical_alerts';
  static const allUsersTopic = 'all_users';

  // Bildirim altyapısını hazırlar (uygulama açılışında bir kez).
  Future<void> initialize();

  /// Kullanıcı tercihine göre `all_users` topic aboneliğini günceller.
  /// `optIn == true` ise bildirim izni ilk kez burada istenir (açılışta değil).
  /// `optIn == false` ise önceki abonelik varsa bile topic'ten çıkar.
  Future<void> syncTopicSubscription({required bool optIn});

  /// Bildirim iznini (bir kez) ister. Onaylı yetkili, duyuru tercihinden
  /// bağımsız olarak panik ve kritik stok bildirimlerini almalıdır (Kural 3, 8).
  Future<void> requestPermission();

  /// Uygulama açıkken yerel bildirim gösterir (G3 FCM, G5 panik, G6 anons/stok).
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });

  // Kapanırken çalışır: dinleyicileri, akışları ve denetleyicileri kapatır (bellek sızıntısı olmasın diye).
  void dispose();
}

// NotificationService arayüzünün gerçek hâli.
// flutter_local_notifications paketiyle yerel bildirim, Firebase Cloud Messaging (FCM) ile push kullanır.
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

  // Kullanılacak FirebaseMessaging nesnesi. Testlerde dışarıdan sahtesi verilebilir.
  FirebaseMessaging get _fcm => _messaging ?? FirebaseMessaging.instance;

  /// Kanal adı sistem ayarlarında görünür; uygulamanın seçili dilindedir.
  AppLocalizations get _l10n => lookupAppLocalizations(LocaleController.current);

  // Android'de "Kritik uyarılar" bildirim kanalını oluşturur ve
  // uygulama açıkken gelen FCM mesajlarını dinlemeye başlar.
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

  // Kullanıcıdan bildirim izni ister.
  @override
  Future<void> requestPermission() => _requestPermissionOnce();

  // Bildirim iznini yalnızca bir kez ister; ikinci çağrıda tekrar pencere açmaz.
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

  // Uygulama açıkken FCM mesajı gelirse sistem onu göstermez;
  // bu yüzden mesajı burada yakalayıp yerel bildirim olarak biz gösteririz.
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

  // Kullanıcı kayıtta bildirim onayı verdiyse all_users konusuna abone eder, vermediyse aboneliği kaldırır.
  // Firebase Console'dan bu konuya gönderilen duyuru, uygulama kapalıyken bile gelir.
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

  // Telefonun bildirim alanında bir bildirim gösterir (başlık + metin).
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

  // Kapanırken çalışır: dinleyicileri, akışları ve denetleyicileri kapatır (bellek sızıntısı olmasın diye).
  @override
  void dispose() {
    _foregroundSub?.cancel();
  }
}

