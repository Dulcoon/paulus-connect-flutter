import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'firebase_notification_service.dart';
import 'providers/auth_provider.dart';
import 'utils/constans.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/artikel_screen.dart';
import 'user-profiles/user_data_screen.dart';
import 'user-profiles/edit_user_profiles_screen.dart';
import 'screens/forgot_password_email_screen.dart';
import 'screens/verify_otp_screen.dart';
import 'screens/reset_password_screen.dart';
import 'sakramen/sakramen_event_list.dart';
import 'doa/list_doa_screen.dart';
import 'doa/detail_doa_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'kalender-liturgi/kalender-liturgi.dart';
import 'text-misa/text_misa_list.dart';
import 'alkitab/alkitab.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'splash_screen.dart';
import 'screens/jadwal_misa_screen.dart';
import 'screens/donation_screen.dart';
import 'screens/persembahan_screen.dart';
import 'sakramen/registrationStatusScreen.dart';
import 'screens/pengumuman_list_screen.dart';
import 'sakramen/sakramen_event_detail.dart';
import 'sakramen/sakramen_event_list.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  // ===== INITIALIZE FIREBASE =====
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ===== SETUP NOTIFICATION CHANNEL =====
  setupNotificationChannel();

  // ===== HANDLE INITIAL MESSAGE (APP TERMINATED STATE) =====
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    print("📨 Initial message detected: ${initialMessage.data}");
    FirebaseNotificationService().handleMessage(initialMessage);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Poppins',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: oren,
            brightness: Brightness.light,
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/register': (context) => const RegisterScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/artikel': (context) => const ArtikelScreen(),
          '/userData': (context) => const UserDataScreen(),
          '/editUserData': (context) => const EditUserProfileScreen(),
          '/doa': (context) => const ListDoaScreen(),
          '/persembahan': (context) => const PersembahanScreen(),
          '/sakramen-list': (context) => SakramenEventList(),
          '/forgot-password': (context) => ForgotPasswordEmailScreen(),
          '/kalender-liturgi': (context) => const KalenderLiturgiScreen(),
          '/alkitab': (context) => const AlkitabScreen(),
          '/text-misa': (context) => const TextMisaList(),
          '/donasi': (context) => const DonationScreen(),
          '/verify-otp': (context) => VerifyOtpScreen(
                email: ModalRoute.of(context)!.settings.arguments as String,
              ),
          '/reset-password': (context) => ResetPasswordScreen(
                email: (ModalRoute.of(context)!.settings.arguments
                    as Map)['email'],
                otp: (ModalRoute.of(context)!.settings.arguments as Map)['otp'],
              ),
          '/jadwal-misa': (context) => const JadwalMisaScreen(),
          '/sakramen-list': (context) => SakramenEventList(),
          '/sakramen-event-detail': (context) {
            final args = _safeMapArguments(context);

            print("📥 Route arguments: $args");

            // ===== GET SAKRAMEN EVENT ID =====
            final sakramenEventId = args['sakramen_event_id'];
            final pendaftarId = args['pendaftar_id'];
            final jenisSakramen = args['jenis_sakramen'];
            final status = args['status'];

            print("📋 sakramen_event_id: $sakramenEventId");
            print("📋 jenis_sakramen: $jenisSakramen");
            print("📋 status: $status");

            // ===== JIKA DARI NOTIFICATION (SAKRAMEN EVENT ID ADA) =====
            if (sakramenEventId != null &&
                sakramenEventId.toString().isNotEmpty) {
              print(
                  "✅ Dari notification - Loading event data untuk ID: $sakramenEventId");

              return SakramenEventDetail(
                event: {
                  'sakramen_event_id': sakramenEventId.toString(),
                  'id': sakramenEventId.toString(),
                  'pendaftar_id': pendaftarId,
                  'jenis_sakramen': jenisSakramen ?? 'Sakramen',
                  'nama_event': 'Loading...',
                  'status': 'loading',
                  'notification_status': status,
                  'notification_title': args['notification_title'],
                  'notification_body': args['notification_body'],
                  'deskripsi': '',
                  'tanggal_pelaksanaan': '',
                  'tempat_pelaksanaan': '',
                  'nama_romo': '',
                  'kuota_pendaftar': 0,
                },
              );
            }

            // ===== JIKA DARI SAKRAMEN LIST (FULL EVENT OBJECT) =====
            if (args.containsKey('nama_event') &&
                args['nama_event'].toString() != 'Loading...') {
              print("✅ Dari list - Full event data");
              return SakramenEventDetail(event: args);
            }

            // ===== FALLBACK =====
            print("❌ Invalid arguments: $args");
            return SakramenEventList();
          },
          '/detail-doa': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;

            if (args is Map<String, dynamic>) {
              return DetailDoaScreen(
                title: args['title'] as String? ?? 'Doa',
                content: args['content'] as String? ?? 'Konten tidak tersedia',
              );
            } else if (args is Map<String, String>) {
              return DetailDoaScreen(
                title: args['title'] ?? 'Doa',
                content: args['content'] ?? 'Konten tidak tersedia',
              );
            } else {
              return DetailDoaScreen(
                title: 'Doa',
                content: 'Konten tidak tersedia',
              );
            }
          },
          '/registration-status': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;

            if (args is Map<String, dynamic>) {
              return RegistrationStatusScreen(
                status: args['status'] as String?,
                alasan: args['alasan'] as String?,
              );
            } else if (args is Map<String, String>) {
              return RegistrationStatusScreen(
                status: args['status'],
                alasan: args['alasan'],
              );
            } else {
              return RegistrationStatusScreen(
                status: null,
                alasan: null,
              );
            }
          },
          '/pengumuman-list': (context) => const PengumumanListScreen(),
        },
        onGenerateRoute: (settings) {
          print("🔀 Generating route: ${settings.name}");
          return null;
        },
        onUnknownRoute: (settings) {
          print("❌ Unknown route: ${settings.name}");
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Halaman Tidak Ditemukan'),
                backgroundColor: oren,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Halaman Tidak Ditemukan',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Route: ${settings.name}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: oren,
                      ),
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      ),
                      child: const Text('Kembali ke Home'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

Map<String, dynamic> _safeMapArguments(BuildContext context) {
  try {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      return Map<String, dynamic>.from(args);
    }
    return {};
  } catch (e) {
    print("Error parsing arguments: $e");
    return {};
  }
}

void setupNotificationChannel() {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_channel', // ID channel
    'Default', // Nama channel
    description: 'Default notification channel', // Deskripsi
    importance: Importance.max,
  );

  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

// handle permissions
Future<void> requestPermissions(BuildContext context) async {
  if (await Permission.notification.isDenied) {
    print("Izin notifikasi awal: Ditolak");
    await Permission.notification.request();
    if (await Permission.notification.isGranted) {
      print("Izin notifikasi diberikan setelah permintaan.");
    } else {
      print("Izin notifikasi tetap ditolak.");
    }
  } else if (await Permission.notification.isGranted) {
    print("Izin notifikasi sudah diberikan.");
  } else if (await Permission.notification.isPermanentlyDenied) {
    print("Izin notifikasi ditolak secara permanen.");
  }

  final isAndroid13 = await isAndroid13OrHigher();

  if (Platform.isAndroid) {
    if (isAndroid13) {
      await Permission.photos.request();
      await Permission.videos.request();
      await Permission.audio.request();
      await Permission.storage.request();
      await Permission.mediaLibrary.request();
      await Permission.scheduleExactAlarm.request();
      await Permission.manageExternalStorage.request();
    } else {
      var status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        print("Izin penyimpanan diberikan.");
      } else if (status.isPermanentlyDenied) {
        print(
            "Izin penyimpanan ditolak secara permanen. Membuka pengaturan...");
        openAppSettings();
      }
    }
  }

  if (await Permission.camera.isDenied) {
    await Permission.camera.request();
  }
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
    print("Izin notifikasi ditolak.");
  }

  if (await Permission.notification.isGranted &&
      await Permission.camera.isGranted) {
    print("Semua izin telah diberikan.");
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  } else {
    print("Beberapa izin ditolak.");
  }
}

Future<bool> isAndroid13OrHigher() async {
  final androidInfo = await DeviceInfoPlugin().androidInfo;
  return androidInfo.version.sdkInt >= 33;
}
