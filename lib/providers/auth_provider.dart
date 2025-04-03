import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;
  Map<String, dynamic>? _userProfile;

  UserModel? get user => _user;
  bool get isAuthenticated => _token != null;
  String? get token => _token;
  Map<String, dynamic>? get userProfile => _userProfile;

  Future<void> fetchUserData() async {
    if (_token == null) {
      throw Exception("Token tidak valid");
    }

    final response = await ApiService.getUserData(_token);
    _user = UserModel.fromJson(response);
    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    if (_token == null) {
      throw Exception("Token tidak valid");
    }

    final response = await ApiService.getUserProfile(_token);
    _userProfile = response;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final response = await ApiService.login(email, password);
    _user = UserModel.fromJson(response['user']);
    _token = response['token'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);

    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    final response = await ApiService.register(name, email, password);
    _user = UserModel.fromJson(response['user']);
    _token = response['token'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);

    notifyListeners();
  }

  Future<void> logout() async {
    if (_token == null) return;

    await ApiService.logout(_token!);
    _user = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    notifyListeners();
  }

  Future<void> sendOtp(String email) async {
    try {
      await ApiService.sendOtp(email);
    } catch (error) {
      throw error;
    }
  }

  // Fungsi untuk memverifikasi OTP
  Future<void> verifyOtp(String email, String otp) async {
    try {
      await ApiService.verifyOtp(email, otp);
    } catch (error) {
      throw error;
    }
  }

  // Fungsi untuk mereset password
  Future<void> resetPassword(String email, String otp, String password,
      String passwordConfirmation) async {
    try {
      await ApiService.resetPassword(
          email, otp, password, passwordConfirmation);
    } catch (error) {
      throw error;
    }
  }
}
