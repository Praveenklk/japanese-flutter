import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';

class ApiService {
  /// 🔐 JWT TOKEN
  static String? _token;

  /// ================= INIT TOKEN =================
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token");
    print("🔐 TOKEN LOADED => $_token");
  }

  /// ================= SET TOKEN =================
  static Future<void> setToken(String token) async {
    _token = token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);

    print("🔐 TOKEN SAVED => $token");
  }

  /// ================= CLEAR TOKEN =================
  static Future<void> clearToken() async {
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    print("🚪 TOKEN CLEARED");
  }

  /// ================= HEADERS =================
  static Map<String, String> _headers() {
    return {
      "Content-Type": "application/json",
      if (_token != null) "Authorization": "Bearer $_token",
    };
  }

  /// ================= GET =================
  static Future<dynamic> get(String endpoint) async {
    final url = ApiEndpoints.baseUrl + endpoint;

    print("🌐 [GET] => $url");

    final response = await http.get(
      Uri.parse(url),
      headers: _headers(),
    );

    return _handleResponse(response);
  }

  /// ================= POST =================
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = ApiEndpoints.baseUrl + endpoint;

    print("🌐 [POST] => $url");
    print("📤 BODY => $body");

    final response = await http.post(
      Uri.parse(url),
      headers: _headers(),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  /// ================= PATCH =================
  static Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = ApiEndpoints.baseUrl + endpoint;

    print("🌐 [PATCH] => $url");

    final response = await http.patch(
      Uri.parse(url),
      headers: _headers(),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  /// ================= HANDLE RESPONSE =================
  static dynamic _handleResponse(http.Response response) {
    print("📡 STATUS => ${response.statusCode}");
    print("📥 RESPONSE => ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(data["message"] ?? "Something went wrong");
  }

  /// ================= REGISTER =================
  static Future<bool> registerUser({
    required String email,
    required String password,
  }) async {
    try {
      await post(ApiEndpoints.register, {
        "email": email,
        "password": password,
      });

      print("✅ REGISTER SUCCESS");
      return true;
    } catch (e) {
      print("❌ REGISTER ERROR => $e");
      return false;
    }
  }
}