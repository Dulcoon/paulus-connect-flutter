import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constans.dart';
import 'dart:io';
import 'package:path/path.dart'; // Import the path package for basename
import 'package:http_parser/http_parser.dart'; // Import MediaType from http_parser

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
    print("Data yang dikirim: $data");

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

  static Future<List<dynamic>> getActiveSakramenEvents(String token) async {
    final url = Uri.parse('$BASE_URL/sakramen-events/active');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data']; // Mengembalikan daftar event
        } else {
          throw Exception(data['message'] ?? 'Gagal mengambil data.');
        }
      } else {
        throw Exception(
            'Gagal mengambil data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Fetch default data for the user
  static Future<Map<String, dynamic>> fetchDefaultData(String token) async {
    final url = Uri.parse('$BASE_URL/pendaftars/default');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']; // Mengembalikan data default
      } else {
        throw Exception(
            'Gagal mengambil data default. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Fungsi untuk mengirim data pendaftaran
  static Future<void> submitRegistrationWithFiles(
      String token, Map<String, dynamic> data, Map<String, File?> files) async {
    final url = Uri.parse('$BASE_URL/pendaftars/daftar');

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });

      // Tambahkan data ke dalam request
      data.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Tambahkan file ke dalam request
      files.forEach((key, file) {
        if (file != null) {
          request.files.add(
            http.MultipartFile(
              key,
              file.readAsBytes().asStream(),
              file.lengthSync(),
              filename: basename(file.path),
              contentType: MediaType('application', 'octet-stream'),
            ),
          );
        }
      });

      // Kirim request
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseData = json.decode(responseBody);
        print('Response from server: $responseData');
        // print(responseData);
        if (responseData['success'] != true) {
          throw Exception(responseData['message'] ?? 'Pendaftaran gagal.');
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        final responseData = json.decode(responseBody);
        throw Exception(responseData['message'] ??
            'Gagal mengirim data pendaftaran. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  static Future<Map<String, dynamic>> checkRegistration(
      String token, int sakramenEventId) async {
    final url = Uri.parse(
        '$BASE_URL/pendaftars/check-registration?sakramen_event_id=$sakramenEventId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Mengembalikan respons JSON
      } else {
        throw Exception(
            'Gagal memeriksa status pendaftaran. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(
          'Terjadi kesalahan saat memeriksa status pendaftaran: $e');
    }
  }

  static Future<List<dynamic>> fetchPengumuman(String token) async {
    final url = Uri.parse('$BASE_URL/pengumuman');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']; // Mengembalikan daftar pengumuman
      } else {
        throw Exception(
            'Gagal mengambil data pengumuman. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil data pengumuman: $e');
    }
  }
}
