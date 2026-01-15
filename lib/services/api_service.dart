import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constans.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> loginWithGoogle() async {
    print('Initializing Google Sign In...');
    final GoogleSignIn googleSignIn = GoogleSignIn();

    await googleSignIn.signOut();
    print('Starting Google sign in...');

    final googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      print('Google sign in aborted by user');
      throw Exception("Login dibatalkan oleh pengguna");
    }

    print('Google user signed in: ${googleUser.email}');
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      print('Failed to get ID token');
      throw Exception("ID Token tidak ditemukan");
    }

    print('ID token obtained, sending to backend...');
    final response = await http.post(
      Uri.parse("$BASE_URL/auth/google"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id_token": idToken,
      }),
    );

    print('Backend response status: ${response.statusCode}');
    print('Backend response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('Login successful, data: $data');

      await saveUserToken(data['token']);

      await sendFcmTokenToLaravel(data['token']);

      return data;
    } else {
      print('Login failed with status ${response.statusCode}');
      throw Exception("Login Google gagal");
    }
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse("$BASE_URL/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await saveUserToken(data['token']);
      await sendFcmTokenToLaravel(data['token']);
      return data;
    } else if (response.statusCode == 401) {
      throw Exception("Email atau password salah");
    } else if (response.statusCode == 422) {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? "Validasi gagal";
      throw Exception(message);
    } else {
      throw Exception("Login gagal (${response.statusCode})");
    }
  }

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

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      await saveUserToken(data['token']);
      await sendFcmTokenToLaravel(data['token']);
      return data;
    } else if (response.statusCode == 422) {
      // Return the full error response for field-specific handling
      throw Exception(jsonEncode(data));
    } else {
      print(response.statusCode);
      throw Exception("Registrasi gagal");
    }
  }

  static Future<void> logout(String token) async {
    final response = await http.post(
      Uri.parse("$BASE_URL/logout"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      await clearUserToken();
    } else {
      throw Exception("Logout gagal");
    }
  }

  static Future<void> saveUserToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', token);
    print('Token berhasil disimpan: $token');
  }

  static Future<void> clearUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
  }

  static Future<void> sendFcmTokenToLaravel(String userToken) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      return;
    }

    final response = await http.post(
      Uri.parse('$BASE_URL/save-fcm-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
      body: jsonEncode({'fcm_token': fcmToken}),
    );

    if (response.statusCode == 200) {
      print('FCM Token berhasil dikirim ke server $fcmToken');
    } else {
      print('Gagal mengirim FCM Token ke server: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> getWilayah() async {
    final response = await http.get(
      Uri.parse("$BASE_URL/wilayah"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'];

      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception("Gagal memuat data wilayah");
    }
  }

  static Future<void> saveUserData(
      String token, int userId, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$BASE_URL/user-profile"),
      headers: {
        "Authorization": "Bearer $token",
        'Accept': 'application/json',
        "Content-Type": "application/json"
      },
      body: jsonEncode(data),
    );
    print("Data yang dikirim: $data");

    if (response.statusCode != 201) {
      print("Response: ${response.body}");
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

  static Future<void> updateUserProfile(
      String token, Map<String, dynamic> data) async {
    final url = Uri.parse('$BASE_URL/user-profile/update');
    print(token);
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile: ${response.body}');
    }
    print('Profile updated successfully: ${response.body}');
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
          return data['data'];
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
        return data['data'];
      } else {
        throw Exception(
            'Gagal mengambil data default. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  static Future<void> submitRegistrationWithFiles(
      String token, Map<String, dynamic> data, Map<String, File?> files) async {
    final url = Uri.parse('$BASE_URL/pendaftars/daftar');

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });

      data.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

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

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseData = json.decode(responseBody);
        print('Response from server: $responseData');

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
        return jsonDecode(response.body);
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
        return data['data'];
      } else {
        throw Exception(
            'Gagal mengambil data pengumuman. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil data pengumuman: $e');
    }
  }

  static Future<Map<String, dynamic>?> fetchLiturgiByDate(String date) async {
    final String apiUrl = "$BASE_URL/kalender-liturgi/by-date?date=$date";

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');

      if (token == null) {
        throw Exception("Token tidak ditemukan. Harap login kembali.");
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          return null;
        }
      } else {
        throw Exception(
            "Gagal mengambil data liturgi (${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan: $e");
    }
  }

  static Future<List<dynamic>> fetchTextMisa() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    if (token == null) {
      throw Exception("Token tidak ditemukan. Harap login kembali.");
    }

    final response = await http.get(
      Uri.parse('$BASE_URL/text-misa'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['data'];
      } else {
        throw Exception("Gagal mengambil data text misa.");
      }
    } else {
      throw Exception("Error: ${response.statusCode}");
    }
  }

  static Future<List<int>> downloadFile(String fileName) async {
    final url =
        '$BASE_URL_NO_API/misa-pdf/$fileName'; // ← gunakan endpoint baru
    print('Mengunduh file dari: $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Gagal mengunduh file: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> createDonation({
    required int amount,
    required String note,
    required String token,
  }) async {
    print('=== CREATE DONATION DEBUG ===');
    print('URL: $BASE_URL/donations');
    print('Amount: $amount');
    print('Note: $note');
    print('Token: ${token.substring(0, 20)}...');

    try {
      final requestBody = {
        'amount': amount,
        'note': note,
      };

      print('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse('$BASE_URL/donations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('SUCCESS - Parsed Data: $data');
        return data;
      } else {
        print('ERROR - HTTP ${response.statusCode}: ${response.body}');
        final errorData = json.decode(response.body);
        throw Exception(
            'HTTP ${response.statusCode}: ${errorData['message'] ?? response.body}');
      }
    } catch (e) {
      print('EXCEPTION in createDonation: $e');
      print('Exception Type: ${e.runtimeType}');
      throw Exception('Failed to create donation: $e');
    }
  }

  static Future<Map<String, dynamic>> checkPaymentStatus({
    required int donationId,
    required String token,
  }) async {
    print('=== CHECK PAYMENT STATUS DEBUG ===');
    print('URL: $BASE_URL/donations/$donationId/status');
    print('Donation ID: $donationId');
    print('Token: ${token.substring(0, 20)}...');

    try {
      final response = await http.get(
        Uri.parse("$BASE_URL/donations/$donationId/status"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS - Parsed Data: $data');
        return data;
      } else {
        print('ERROR - HTTP ${response.statusCode}: ${response.body}');
        final errorData = json.decode(response.body);
        throw Exception(
            'HTTP ${response.statusCode}: ${errorData['message'] ?? response.body}');
      }
    } catch (e) {
      print('EXCEPTION in checkPaymentStatus: $e');
      print('Exception Type: ${e.runtimeType}');
      throw Exception('Failed to check payment status: $e');
    }
  }

  static Future<Map<String, dynamic>> getDonationHistory({
    required String token,
  }) async {
    print('=== GET DONATION HISTORY DEBUG ===');
    print('URL: $BASE_URL/donations/history');
    print('Token: ${token.substring(0, 20)}...');

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/donations/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS - Parsed Data: $data');
        return data;
      } else {
        print('ERROR - HTTP ${response.statusCode}: ${response.body}');
        final errorData = json.decode(response.body);
        throw Exception(
            'HTTP ${response.statusCode}: ${errorData['message'] ?? response.body}');
      }
    } catch (e) {
      print('EXCEPTION in getDonationHistory: $e');
      print('Exception Type: ${e.runtimeType}');
      throw Exception('Failed to get donation history: $e');
    }
  }

  // Tambahkan method untuk persembahan

  static Future<Map<String, dynamic>> getPersembahanHistory({
    required String token,
  }) async {
    print('=== GET PERSEMBAHAN HISTORY DEBUG ===');
    print('URL: $BASE_URL/persembahan');
    print('Token: ${token.substring(0, 20)}...');

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/persembahan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS - Parsed Data: $data');
        return data;
      } else {
        print('ERROR - HTTP ${response.statusCode}: ${response.body}');
        final errorData = json.decode(response.body);
        throw Exception(
            'HTTP ${response.statusCode}: ${errorData['message'] ?? response.body}');
      }
    } catch (e) {
      print('EXCEPTION in getPersembahanHistory: $e');
      print('Exception Type: ${e.runtimeType}');
      throw Exception('Failed to get persembahan history: $e');
    }
  }

  static Future<Map<String, dynamic>> getPersembahanDetail({
    required int id,
    required String token,
  }) async {
    print('=== GET PERSEMBAHAN DETAIL DEBUG ===');
    print('URL: $BASE_URL/persembahan/$id');
    print('ID: $id');
    print('Token: ${token.substring(0, 20)}...');

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/persembahan/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS - Parsed Data: $data');
        return data;
      } else {
        print('ERROR - HTTP ${response.statusCode}: ${response.body}');
        final errorData = json.decode(response.body);
        throw Exception(
            'HTTP ${response.statusCode}: ${errorData['message'] ?? response.body}');
      }
    } catch (e) {
      print('EXCEPTION in getPersembahanDetail: $e');
      print('Exception Type: ${e.runtimeType}');
      throw Exception('Failed to get persembahan detail: $e');
    }
  }
}
