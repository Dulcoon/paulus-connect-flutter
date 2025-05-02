import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialization
  Future<void> initNotifications() async {
    await _requestPermission(); // Minta izin
    await _initLocalNotifications(); // Init notifikasi lokal
    await _setupFCMListeners(); // Listener pesan FCM
  }

  // Permission untuk iOS & Android 13+
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

  // Init plugin notifikasi lokal
  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Arahkan ke halaman tertentu saat user klik notifikasi
        print("Klik notifikasi dengan payload: ${details.payload}");
      },
    );
  }

  // Listener untuk handle pesan FCM
  Future<void> _setupFCMListeners() async {
    // Token debug (opsional)
    final token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    // Foreground: tampilkan sebagai notifikasi lokal
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Pesan diterima di foreground: ${message.notification?.title}");

      _showLocalNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        payload: message.data['screen'], // misalnya payload screen
      );
    });

    // Saat app dibuka dari notifikasi (background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("App dibuka dari notifikasi: ${message.data}");

      // Misalnya, navigate ke list sakramen
      final screen = message.data['screen'];
      if (screen != null) {
        // kamu bisa simpan navigator key dan pakai untuk pushNamed
        // atau trigger dari luar
      }
    });
  }

  // Tampilkan notifikasi lokal
  Future<void> _showLocalNotification({
    String? title,
    String? body,
    String? payload,
  }) async {
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
      0,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }
}
