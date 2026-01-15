import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/notification_service.dart';
import 'home_screen.dart';
import '../utils/constans.dart';
import 'forgot_password_email_screen.dart';
import '../widgets/custom_text_field.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isPasswordVisible = false;

  String? _emailError;
  String? _passwordError;
  String? _generalError;

  void _login() async {
    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        if (_emailController.text.isEmpty) {
          _emailError = "Email wajib diisi";
        }
        if (_passwordController.text.isEmpty) {
          _passwordError = "Password wajib diisi";
        }
        _isLoading = false;
      });
      return;
    }

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .login(_emailController.text, _passwordController.text);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      final error = e.toString().toLowerCase();

      if (error.contains("email")) {
        _emailError = "Email tidak valid atau tidak terdaftar";
      } else if (error.contains("password")) {
        _passwordError = "Kata sandi salah";
      } else if (error.contains("credential")) {
        _generalError = "Email atau kata sandi salah";
      } else {
        _generalError = "Terjadi kesalahan. Silakan coba lagi.";
      }
    }

    setState(() => _isLoading = false);
  }

  void _loginWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false).loginWithGoogle();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      NotificationService()
          .showError(context, "Login Google gagal: ${e.toString()}");
    }

    setState(() => _isGoogleLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: oren,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 150),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    const Center(
                      child: Text("Masuk",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                    ),
                    const Center(
                      child: Text("Silahkan masukkan email dan kata sandi anda",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.normal)),
                    ),
                    const SizedBox(height: 30),
                    if (_emailError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          _emailError!,
                          style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    CustomTextField(
                      controller: _emailController,
                      label: "Email Address",
                      primaryColor: oren,
                      borderColor: oren,
                    ),
                    if (_passwordError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          _passwordError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    CustomTextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      label: "Password",
                      primaryColor: oren,
                      borderColor: oren,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    if (_generalError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _generalError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: oren,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: _login,
                        child: _isLoading
                            ? const SizedBox(
                                height: 21,
                                width: 21,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Masuk",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _loginWithGoogle,
                        icon: Image.asset(
                          'assets/images/google-logo.webp',
                          height: 20,
                        ),
                        label: _isGoogleLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(),
                              )
                            : const Text(
                                "Masuk dengan Google",
                                style: TextStyle(color: Colors.black),
                              ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "Belum punya akun? ",
                            style: const TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: "Daftar",
                                style: const TextStyle(
                                  color: oren,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(context, '/register');
                                  },
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ForgotPasswordEmailScreen()),
                            );
                          },
                          child: const Text('Lupa Password?',
                              style: TextStyle(color: oren)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
