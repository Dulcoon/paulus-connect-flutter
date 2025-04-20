import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/artikel_screen.dart';
import 'features/user_data_screen.dart';
import 'screens/forgot_password_email_screen.dart';
import 'screens/verify_otp_screen.dart';
import 'screens/reset_password_screen.dart';
import 'sakramen/sakramen_event_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'utils/constans.dart';
import 'sakramen/sakramen_event_detail.dart';
import 'doa/list_doa_screen.dart';
import 'package:timezone/data/latest.dart' as tz;

// Inisialisasi plugin notifikasi lokal
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi notifikasi lokal
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    print('Aplikasi dibuka dari notifikasi: ${initialMessage.data}');
    if (initialMessage.data['action'] == 'view_sakramen_event') {
      final sakramenEventId = initialMessage.data['sakramen_event_id'];
      if (sakramenEventId != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => SakramenEventDetail(
              event: {'id': sakramenEventId},
            ),
          ),
        );
      }
    }
  }
  setupFCM();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Poppins'),
        initialRoute: '/login',
        routes: {
          '/register': (context) => RegisterScreen(),
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/artikel': (context) => ArtikelScreen(),
          '/userData': (context) => UserDataScreen(),
          '/doa': (context) => ListDoaScreen(),
          '/sakramen-list': (context) => SakramenEventList(),
          '/forgot-password': (context) => ForgotPasswordEmailScreen(),
          '/verify-otp': (context) => VerifyOtpScreen(
                email: ModalRoute.of(context)!.settings.arguments as String,
              ),
          '/reset-password': (context) => ResetPasswordScreen(
                email: (ModalRoute.of(context)!.settings.arguments
                    as Map)['email'],
                otp: (ModalRoute.of(context)!.settings.arguments as Map)['otp'],
              ),
        },
      ),
    ),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  RemoteNotification? notification = message.notification;
  if (notification != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  } else if (message.data.isNotEmpty) {
    print('terkirimPesan');
    // Menampilkan notifikasi manual untuk Data Message
    flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.data['title'] ?? 'Judul Default',
      message.data['body'] ?? 'Isi Default',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            message.data['body'] ??
                'Isi Default', // Teks lengkap untuk notifikasi
            contentTitle: message.data['title'] ?? 'Judul Default', // Judul
            htmlFormatContent: true, // Jika ingin mendukung HTML
            htmlFormatContentTitle: true, // Jika ingin mendukung HTML di judul
          ),
        ),
      ),
    );
  }

  print('Handling background message: ${message.messageId}');
}

// Fungsi untuk mengatur Firebase Cloud Messaging (FCM)
void setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Dapatkan FCM token
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  // Menangani pesan FCM di background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Menangani pesan FCM saat aplikasi berjalan di foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default',
            importance: Importance.max,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(
              message.data['body'] ??
                  'Isi Default', // Teks lengkap untuk notifikasi
              contentTitle: message.data['title'] ?? 'Judul Default', // Judul
              htmlFormatContent: true, // Jika ingin mendukung HTML
              htmlFormatContentTitle:
                  true, // Jika ingin mendukung HTML di judul
            ),
          ),
        ),
      );
    } else if (message.data.isNotEmpty) {
      // Menampilkan notifikasi manual untuk Data Message
      flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.data['title'] ?? 'Judul Default',
        message.data['body'] ?? 'Isi Default',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default',
            importance: Importance.max,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(
              message.data['body'] ??
                  'Isi Default', // Teks lengkap untuk notifikasi
              contentTitle: message.data['title'] ?? 'Judul Default', // Judul
              htmlFormatContent: true, // Jika ingin mendukung HTML
              htmlFormatContentTitle:
                  true, // Jika ingin mendukung HTML di judul
            ),
          ),
        ),
      );
    }
  });

  // Menangani notifikasi yang membuka aplikasi
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('❗❗❗❗❗❗❗❗❗❗❗❗❗');

    if (message.data['action'] == 'view_sakramen_event') {
      final sakramenEventId = message.data['sakramen_event_id'];
      if (sakramenEventId != null) {
        // Navigasi ke halaman detail sakramen
        Navigator.push(
          navigatorKey.currentContext!,
          MaterialPageRoute(
            builder: (context) => SakramenEventDetail(
              event: {'id': sakramenEventId}, // Kirim data event
            ),
          ),
        );
      }
    }
  });
}
