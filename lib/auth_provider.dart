import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:senslinq/globals.dart' as globals;

class AuthProvider with ChangeNotifier {
  String? _token;

  String? get token => _token;

  bool get isAuth => _token != null;

  Future<void> loginUser(String email, String password) async {
    final url = Uri.parse(globals.Globals.apiUrl + '/api/v1/UserLogin');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        _token = responseBody['token'];
        globals.Globals.globalToken = _token!; // Update global token

        notifyListeners();

        // Save token to shared preferences
        await _saveTokenToPrefs(_token!);
      } else {
        throw Exception('Failed to login');
      }
    } catch (error) {
      throw Exception('Failed to login: $error');
    }
  }

  Future<bool> verifyToken(String? token) async {
    if (token == null || token.isEmpty) {
      return false;
    }

    final url = Uri.parse(globals.Globals.apiUrl + '/api/v1/verifyToken'); // Update to your actual token verification endpoint
    final headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (error) {
      print('Error verifying token: $error');
      return false;
    }
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('authToken')) {
      return;
    }
    _token = prefs.getString('authToken');

    // Verify the token before considering it valid
    if (await verifyToken(_token)) {
      notifyListeners();
    } else {
      _token = null;
      await prefs.remove('authToken');
    }
  }

  Future<void> logout() async {
    _token = null;
    notifyListeners();

    // Remove token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
  }

  Future<void> _saveTokenToPrefs(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }
}
