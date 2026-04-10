import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();
  static const _defaultBase = 'http://10.0.2.2:8000'; // Android emulator → localhost

  static Future<String> get baseUrl async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_base_url') ?? _defaultBase;
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', url.trimRight().replaceAll(RegExp(r'/$'), ''));
  }

  static Future<String?> get token => _storage.read(key: 'auth_token');

  static Future<void> saveToken(String token) =>
      _storage.write(key: 'auth_token', value: token);

  static Future<void> clearToken() => _storage.delete(key: 'auth_token');

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = {'Content-Type': 'application/json'};
    if (auth) {
      final t = await token;
      if (t != null) h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final base = await baseUrl;
    final resp = await http.post(
      Uri.parse('$base/auth/login'),
      headers: await _headers(auth: false),
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(resp.body);
    if (resp.statusCode == 200) {
      await saveToken(data['access_token']);
    }
    return {'status': resp.statusCode, 'data': data};
  }

  // ── Generic requests ──────────────────────────────────────────────────────

  static Future<dynamic> get(String path) async {
    final base = await baseUrl;
    final resp = await http.get(
      Uri.parse('$base$path'),
      headers: await _headers(),
    );
    if (resp.statusCode == 401) throw UnauthorizedException();
    return jsonDecode(resp.body);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final base = await baseUrl;
    final resp = await http.post(
      Uri.parse('$base$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (resp.statusCode == 401) throw UnauthorizedException();
    return jsonDecode(resp.body);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final base = await baseUrl;
    final resp = await http.put(
      Uri.parse('$base$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (resp.statusCode == 401) throw UnauthorizedException();
    return jsonDecode(resp.body);
  }

  static Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final base = await baseUrl;
    final resp = await http.patch(
      Uri.parse('$base$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (resp.statusCode == 401) throw UnauthorizedException();
    return jsonDecode(resp.body);
  }

  static Future<void> delete(String path) async {
    final base = await baseUrl;
    final resp = await http.delete(
      Uri.parse('$base$path'),
      headers: await _headers(),
    );
    if (resp.statusCode == 401) throw UnauthorizedException();
  }
}

class UnauthorizedException implements Exception {}
