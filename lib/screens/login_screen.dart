import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import '../utils/constans.dart';
import 'forgot_password_email_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .login(_emailController.text, _passwordController.text);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Login gagal: ${e.toString()}"),
      ));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: oren,
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              SizedBox(height: 150),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 1,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 50),
                      Text(
                        "Masuk",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Silahkan masukkan email dan kata sandi anda",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: 30),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.black, // Warna border saat aktif
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color:
                                  Colors.grey, // Warna border saat tidak aktif
                            ),
                          ),
                          labelText: "Email Address",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        obscureText: true,
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.black, // Warna border saat aktif
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color:
                                  Colors.grey, // Warna border saat tidak aktif
                            ),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                              ? SizedBox(
                                  height: 21,
                                  width: 21,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("Masuk",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.white)),
                        ),
                      ),
                      SizedBox(height: 20),
                      // bagian register
                      RichText(
                        text: TextSpan(
                          text: "Belum punya akun? ",
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: "Daftar",
                              style: TextStyle(
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
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordEmailScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Lupa Password?',
                          style: TextStyle(color: oren),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
