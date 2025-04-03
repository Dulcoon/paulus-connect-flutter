import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constans.dart';

class ApiService {
  // Method untuk login
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse("$BASE_URL/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Login gagal");
    }
  }

  // Method untuk register
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("$BASE_URL/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": password
      }),
    );

    if (response.statusCode == 201) {
      print('sukses');
      return jsonDecode(response.body);
    } else {
      throw Exception("Registrasi gagal");
    }
  }

  // Method untuk logout
  static Future<void> logout(String token) async {
    final response = await http.post(
      Uri.parse("$BASE_URL/logout"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Logout gagal");
    }
  }

  // Method untuk mengambil data wilayah
  static Future<List<Map<String, dynamic>>> getWilayah() async {
    final response = await http.get(
      Uri.parse("$BASE_URL/wilayah"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          jsonDecode(response.body); // Parse JSON
      final List<dynamic> data =
          jsonResponse['data']; // Ambil hanya bagian "data"

      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception("Gagal memuat data wilayah");
    }
  }

  // Method untuk menyimpan data user
  static Future<void> saveUserData(
      String token, int userId, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$BASE_URL/user-profile"), // Sesuaikan dengan endpoint API Anda
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception("Gagal menyimpan data user");
    }
  }

  static Future<Map<String, dynamic>> getUserData(String? token) async {
    final response = await http.get(
      Uri.parse("$BASE_URL/user"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal mendapatkan data user");
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(String? token) async {
    final response = await http.get(
      Uri.parse("$BASE_URL/user-profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal mendapatkan profil user");
    }
  }

  static Future<void> sendOtp(String email) async {
    final url = Uri.parse("$BASE_URL/forgot-password/send-otp");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode != 200) {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['errors']['email'][0]);
    }
  }

  // Fungsi untuk memverifikasi OTP
  static Future<void> verifyOtp(String email, String otp) async {
    final url = Uri.parse("$BASE_URL/forgot-password/verify-otp");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );

    if (response.statusCode != 200) {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['message']);
    }
  }

  // Fungsi untuk mereset password
  static Future<void> resetPassword(String email, String otp, String password,
      String passwordConfirmation) async {
    final url = Uri.parse("$BASE_URL/forgot-password/reset");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
        "password": password,
        "password_confirmation": passwordConfirmation,
      }),
    );

    if (response.statusCode != 200) {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['message']);
    }
  }
}
