import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../utils/constans.dart';

class ForgotPasswordEmailScreen extends StatefulWidget {
  @override
  _ForgotPasswordEmailScreenState createState() =>
      _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .sendOtp(_emailController.text);
      Navigator.pushNamed(context, '/verify-otp',
          arguments: _emailController.text);
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // Pastikan ini diatur ke true
      appBar: AppBar(
        title: Text('Lupa Password'),
        backgroundColor: oren,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text(
                              'Kami akan mengirimkan kode OTP ke email Anda untuk mengatur ulang kata sandi.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 20),
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email',
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Email tidak boleh kosong'
                                      : null,
                            ),
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Menambahkan ruang fleksibel agar tombol berada di bawah
                    Image.asset(
                      'assets/images/asking-question.png',
                      height:
                          300, // Sesuaikan ukuran gambar agar tidak terlalu besar
                      width: 300,
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: oren,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _sendOtp();
                            }
                          },
                          child: _isLoading
                              ? SizedBox(
                                  height: 21,
                                  width: 21,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Kirim OTP",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
