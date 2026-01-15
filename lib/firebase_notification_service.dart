import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'main.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("📨 Background Message Handler");
  print("   - Title: ${message.notification?.title}");
  print("   - Body: ${message.notification?.body}");
  print("   - Data: ${message.data}");

  if (message.notification != null) {
    // ===== BUILD COMPLETE PAYLOAD WITH ALL DATA =====
    final payload = {
      'title': message.notification!.title,
      'body': message.notification!.body,
      'action': message.data['action'] ?? '',
      'sakramen_event_id': message.data['sakramen_event_id'],
      'pendaftar_id': message.data['pendaftar_id'],
      'jenis_sakramen': message.data['jenis_sakramen'],
      'status': message.data['status'],
      'content': message.data['content'],
      // ===== INCLUDE ALL OTHER DATA =====
      ...message.data,
    };

    print("✅ Payload dengan data lengkap: $payload");

    FlutterLocalNotificationsPlugin().show(
      message.hashCode,
      message.notification!.title,
      message.notification!.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(payload), // ===== PASS COMPLETE PAYLOAD =====
    );
  }
}

class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    await _requestPermission();
    await _initLocalNotifications();
    await _setupFCMListeners();
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('Notifikasi tidak diizinkan');
    }
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        print("Klik notifikasi dengan payload: ${details.payload}");
        if (details.payload != null) {
          try {
            final Map<String, dynamic> data = jsonDecode(details.payload!);
            _handleNotificationClick(data);
          } catch (e) {
            print("Error parsing payload: $e");
          }
        }
      },
    );
  }

  Future<void> _setupFCMListeners() async {
    final token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Pesan diterima di foreground: ${message.notification?.title}");

      _showLocalNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        data: message.data,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("App dibuka dari notifikasi: ${message.data}");
      handleMessage(message);
    });
  }

  // ===== HANDLE NOTIFICATION CLICK =====
  void _handleNotificationClick(Map<String, dynamic> data) {
    final action = data['action'] as String? ?? '';
    final title = data['title'] as String? ?? '';
    final body = data['body'] as String? ?? '';

    print("=== NOTIFICATION HANDLER ===");
    print("Action: $action");
    print("Title: $title");
    print("Body: $body");
    print("Full Data: $data");
    print("Data Keys: ${data.keys.toList()}");
    print("========================");

    // ===== CHECK IF IT'S SACRAMENT NOTIFICATION =====
    if (_isSacramentNotification(title)) {
      print("Detected as Sacrament Notification");
      _handleSacramentNotification(title, body, data);
    }
    // ===== CHECK IF IT'S DOA NOTIFICATION =====
    else if (_isDoaNotification(action, title)) {
      print("Detected as Doa Notification");
      _handleDoaNotification(data);
    }
    // ===== DEFAULT: TRY DOA FIRST, THEN SACRAMENT =====
    else {
      print("Undetermined notification type, trying doa...");
      if (data.containsKey('content')) {
        _handleDoaNotification(data);
      } else {
        _handleSacramentNotification(title, body, data);
      }
    }
  }

  // ===== CHECK IF SACRAMENT NOTIFICATION =====
  bool _isSacramentNotification(String title) {
    final sacramentKeywords = [
      'baptis',
      'komuni',
      'krisma',
      'sakramen',
      'pendaftaran',
      'ditolak',
      'diterima',
      'menunggu',
    ];

    return sacramentKeywords
        .any((keyword) => title.toLowerCase().contains(keyword));
  }

  // ===== CHECK IF DOA NOTIFICATION =====
  bool _isDoaNotification(String action, String title) {
    return action == 'view_doa' ||
        action.toLowerCase().contains('doa') ||
        title.toLowerCase().contains('doa reminder') ||
        title.toLowerCase().contains('pengingat doa');
  }

  // ===== HANDLE SACRAMENT NOTIFICATION =====
  void _handleSacramentNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      print("❌ Context tidak tersedia");
      return;
    }

    print('📦 data sakramen (RAW): $data');
    print('📦 data type: ${data.runtimeType}');

    // ===== DEBUG: PRINT EACH VALUE =====
    data.forEach((key, value) {
      print('   - $key: $value (type: ${value.runtimeType})');
    });

    // ===== EXTRACT SAKRAMEN EVENT ID - WITH SAFE CASTING =====
    String? sakramenEventId = _safeStringValue(data, 'sakramen_event_id');
    String? pendaftarId = _safeStringValue(data, 'pendaftar_id');
    String? jenisSakramen = _safeStringValue(data, 'jenis_sakramen');
    String? status = _safeStringValue(data, 'status');

    print(
        "📋 Sakramen Event ID: $sakramenEventId (type: ${sakramenEventId.runtimeType})");
    print("📋 Pendaftar ID: $pendaftarId");
    print("📋 Jenis Sakramen: $jenisSakramen");
    print("📋 Status: $status");

    // ===== VALIDATION: SAKRAMEN EVENT ID WAJIB ADA =====
    if (sakramenEventId == null || sakramenEventId.isEmpty) {
      print("❌ Sakramen Event ID tidak ditemukan!");
      print("❌ Available keys: ${data.keys.toList()}");

      // Fallback: Show error notification
      if (navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: const Text('Data notifikasi tidak lengkap'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    print("✅ Sakramen Event ID valid: $sakramenEventId");

    // ===== BUILD NOTIFICATION DATA =====
    final notificationData = {
      'sakramen_event_id': sakramenEventId,
      'pendaftar_id': pendaftarId,
      'jenis_sakramen': jenisSakramen ?? 'Sakramen',
      'status': status,
      'notification_title': title,
      'notification_body': body,
    };

    print("✅ Notification Data: $notificationData");

    // ===== NAVIGATE TO SAKRAMEN EVENT DETAIL =====
    Future.delayed(const Duration(milliseconds: 500), () {
      if (navigatorKey.currentContext != null) {
        print("🚀 Navigating to /sakramen-event-detail");
        print("   - sakramen_event_id: $sakramenEventId");
        print("   - status: $status");

        try {
          Navigator.pushNamed(
            navigatorKey.currentContext!,
            '/sakramen-event-detail',
            arguments: notificationData,
          );
        } catch (e) {
          print("❌ Navigation error: $e");
        }
      } else {
        print("❌ Navigator context is null");
      }
    });
  }

  // ===== HELPER: SAFE STRING VALUE EXTRACTION =====
  String? _safeStringValue(Map<String, dynamic> data, String key) {
    try {
      final value = data[key];
      if (value == null) return null;

      // Convert to string if it's int, double, or other type
      return value.toString();
    } catch (e) {
      print("⚠️ Error extracting $key: $e");
      return null;
    }
  }

  // ===== HANDLE DOA NOTIFICATION =====
  void _handleDoaNotification(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      print("Context tidak tersedia");
      return;
    }

    final title = data['title'] as String?;
    final content = data['content'] as String?;

    print("Doa Title: $title");
    print("Doa Content: $content");

    // ===== VALIDATE DOA DATA =====
    if (title == null || title.isEmpty) {
      print("Doa title tidak valid");
      return;
    }

    // ===== IF CONTENT NOT PROVIDED, FETCH FROM DATABASE OR USE DEFAULT =====
    final finalContent = (content == null || content.isEmpty)
        ? 'Konten doa tidak tersedia'
        : content;

    Future.delayed(const Duration(seconds: 1), () {
      if (navigatorKey.currentContext != null) {
        Navigator.pushNamed(
          navigatorKey.currentContext!,
          '/detail-doa',
          arguments: {
            'title': title,
            'content': finalContent,
          },
        );
      }
    });
  }

  void handleMessage(RemoteMessage message) {
    Future.delayed(const Duration(milliseconds: 500), () {
      print("📨 Handling FCM message...");
      print("   - Title: ${message.notification?.title}");
      print("   - Data: ${message.data}");

      final data = {
        'action': message.data['action'] ?? '',
        'title': message.notification?.title ?? message.data['title'] ?? '',
        'body': message.notification?.body ?? message.data['body'] ?? '',
        'sakramen_event_id': message.data['sakramen_event_id'],
        'pendaftar_id': message.data['pendaftar_id'],
        'jenis_sakramen': message.data['jenis_sakramen'],
        'status': message.data['status'],
        'content': message.data['content'],
      };

      _handleNotificationClick(data);
    });
  }

  Future<void> _showLocalNotification({
    String? title,
    String? body,
    Map<String, dynamic>? data,
  }) async {
    print("📲 Showing local notification");
    print("   - Title: $title");
    print("   - Body: $body");
    print("   - Data: $data");

    // ===== BUILD COMPLETE PAYLOAD =====
    final payload = {
      'title': title,
      'body': body,
      'action': data?['action'] ?? '',
      'sakramen_event_id': data?['sakramen_event_id'],
      'pendaftar_id': data?['pendaftar_id'],
      'jenis_sakramen': data?['jenis_sakramen'],
      'status': data?['status'],
      'content': data?['content'],
      if (data != null) ...data,
    };

    print("✅ Payload: $payload");

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel',
      'Default',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      platformDetails,
      payload: jsonEncode(payload),
    );
  }
}
