import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_notification_service.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'utils/constans.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // ===== LOAD TOKEN =====
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.loadToken();

      // ===== INITIALIZE FIREBASE NOTIFICATIONS =====
      await FirebaseNotificationService().initNotifications();

      if (!mounted) return;

      // ===== DELAY UNTUK UI SPLASH SMOOTH =====
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // ===== NAVIGATE BASED ON AUTH STATUS =====
      if (authProvider.isAuthenticated) {
        print("✅ User authenticated, navigating to HomeScreen");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        print("❌ User not authenticated, navigating to LoginScreen");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      print("❌ Error during initialization: $e");

      if (!mounted) return;

      // ===== FALLBACK TO LOGIN SCREEN =====
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: oren,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ===== LOGO =====
            Image.asset(
              'assets/images/logo st paulus.png',
              width: 150,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.white,
                    size: 60,
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            // ===== APP NAME =====
            Text(
              'Paulus Connect',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // ===== TAGLINE =====
            Text(
              'Komunitas Gereja Online',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.8),
              ),
            ),

            const SizedBox(height: 50),

            // ===== LOADING INDICATOR =====
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
            const SizedBox(height: 16),

            // ===== LOADING TEXT =====
            Text(
              'Memuat...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
