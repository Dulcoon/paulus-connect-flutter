import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constans.dart';
import '../widgets/custom_text_field.dart'; // Import CustomTextField
import 'home_screen.dart';
import 'package:flutter/gestures.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  void _register() async {
    setState(() => _isLoading = true);

    try {
      if (_passwordController.text != _confirmPasswordController.text) {
        throw Exception("Password dan Konfirmasi Password tidak cocok.");
      }

      await Provider.of<AuthProvider>(context, listen: false).register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Registrasi gagal: ${e.toString()}"),
      ));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Pastikan ini diatur ke true
      backgroundColor: oren,
      body: SafeArea(
        child: SingleChildScrollView(
          // Bungkus konten dengan SingleChildScrollView
          child: Container(
            child: Column(
              children: [
                const SizedBox(height: 150),
                Container(
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
                    children: [
                      const SizedBox(height: 50),
                      const Text(
                        "Daftar",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Silahkan daftarkan diri anda!",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        controller: _nameController,
                        label: "Nama Lengkap",
                        primaryColor: oren,
                        borderColor: oren,
                      ),
                      CustomTextField(
                        controller: _emailController,
                        label: "Email Address",
                        primaryColor: oren,
                        borderColor: oren,
                      ),
                      CustomTextField(
                        controller: _passwordController,
                        label: "Password",
                        primaryColor: oren,
                        borderColor: oren,
                        obscureText: true,
                      ),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: "Konfirmasi kata sandi",
                        primaryColor: oren,
                        borderColor: oren,
                        obscureText: true,
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
                          onPressed: _register,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 21,
                                  width: 21,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("Daftar",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      RichText(
                          text: TextSpan(
                        text: "Sudah punya akun? ",
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                              text: "Masuk",
                              style: const TextStyle(
                                color: oren,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushNamed(context, '/login');
                                }),
                        ],
                      )),
                      const SizedBox(height: 300),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
