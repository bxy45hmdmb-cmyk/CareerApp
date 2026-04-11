import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'token_storage.dart';
import 'lang_controller.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  // ⚠️  Change to your machine's IP when testing on a real device
  static const String baseUrl = 'http://192.168.1.107:8003/api/v1';

  final TokenStorage _storage = TokenStorage();

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _storage.getAccessToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _decode(http.Response res) {
    final body = utf8.decode(res.bodyBytes);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(body) as Map<String, dynamic>;
    }
    String msg = 'Қате орын алды';
    try {
      final err = json.decode(body);
      msg = err['detail'] ?? msg;
    } catch (_) {}
    throw ApiException(res.statusCode, msg);
  }

  List<dynamic> _decodeList(http.Response res) {
    final body = utf8.decode(res.bodyBytes);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(body) as List<dynamic>;
    }
    String msg = 'Қате орын алды';
    try {
      final err = json.decode(body);
      msg = err['detail'] ?? msg;
    } catch (_) {}
    throw ApiException(res.statusCode, msg);
  }

  /// GET with automatic token refresh on 401
  Future<http.Response> _getWithRefresh(String url) async {
    var res = await http.get(Uri.parse(url), headers: await _headers());
    if (res.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) {
        res = await http.get(Uri.parse(url), headers: await _headers());
      }
    }
    return res;
  }

  /// POST with automatic token refresh on 401
  Future<http.Response> _postWithRefresh(
      String url, Map<String, dynamic> body) async {
    var res = await http.post(Uri.parse(url),
        headers: await _headers(), body: json.encode(body));
    if (res.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) {
        res = await http.post(Uri.parse(url),
            headers: await _headers(), body: json.encode(body));
      }
    }
    return res;
  }

  // ── Auth ───────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required int grade,
    String? school,
    String? city,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await _headers(auth: false),
      body: json.encode({
        'email': email,
        'password': password,
        'full_name': fullName,
        'grade': grade,
        if (school != null) 'school': school,
        if (city != null) 'city': city,
      }),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/verify-email'),
      headers: await _headers(auth: false),
      body: json.encode({'email': email, 'code': code}),
    );
    final data = _decode(res);
    await _storage.saveTokens(
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
    );
    return data;
  }

  Future<Map<String, dynamic>> resendVerification(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/resend-verification'),
      headers: await _headers(auth: false),
      body: json.encode({'email': email}),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: await _headers(auth: false),
      body: json.encode({'email': email}),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: await _headers(auth: false),
      body: json.encode({
        'email': email,
        'code': code,
        'new_password': newPassword,
      }),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _headers(auth: false),
      body: json.encode({'email': email, 'password': password}),
    );
    final data = _decode(res);
    await _storage.saveTokens(
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
    );
    return data;
  }

  Future<void> logout() async {
    await _storage.clearTokens();
  }

  Future<bool> refreshToken() async {
    final refresh = await _storage.getRefreshToken();
    if (refresh == null) return false;
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: await _headers(auth: false),
        body: json.encode({'refresh_token': refresh}),
      );
      if (res.statusCode == 200) {
        final data = json.decode(utf8.decode(res.bodyBytes));
        await _storage.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        );
        return true;
      }
    } catch (_) {}
    return false;
  }

  // ── Users ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getMe() async {
    final res = await _getWithRefresh('$baseUrl/users/me');
    return _decode(res);
  }

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> data) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/users/me'),
      headers: await _headers(),
      body: json.encode(data),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> getProgress() async {
    final res = await _getWithRefresh('$baseUrl/users/me/progress');
    return _decode(res);
  }

  Future<Map<String, dynamic>> uploadAvatar(File imageFile) async {
    final token = await _storage.getAccessToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/users/me/avatar'),
    );
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return _decode(res);
  }

  // ── Questions ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final res = await _postWithRefresh('$baseUrl/users/me/change-password', {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
    return _decode(res);
  }

  Future<String> sendChatMessage({
    required String message,
    required List<Map<String, String>> history,
  }) async {
    final res = await _postWithRefresh('$baseUrl/chat/', {
      'message': message,
      'history': history,
    });
    final data = _decode(res);
    return data['reply'] as String;
  }

  String get _lang => LangController.instance.locale;

  Future<List<dynamic>> getQuestions() async {
    final res = await _getWithRefresh('$baseUrl/questions/?lang=$_lang');
    return _decodeList(res);
  }

  // ── Tests ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> submitTest(
      List<Map<String, dynamic>> answers) async {
    final res = await http.post(
      Uri.parse('$baseUrl/tests/submit'),
      headers: await _headers(),
      body: json.encode({'answers': answers}),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> getLatestResult() async {
    final res = await http.get(
      Uri.parse('$baseUrl/tests/latest'),
      headers: await _headers(),
    );
    return _decode(res);
  }

  Future<List<dynamic>> getMyResults() async {
    final res = await _getWithRefresh('$baseUrl/tests/my-results');
    return _decodeList(res);
  }

  // ── Professions ────────────────────────────────────────────────────────────

  Future<List<dynamic>> getProfessions({String? category}) async {
    final uri = Uri.parse('$baseUrl/professions/').replace(
      queryParameters: {
        if (category != null) 'category': category,
        'limit': '100',
        'lang': _lang,
      },
    );
    final res = await http.get(uri, headers: await _headers());
    return _decodeList(res);
  }

  Future<List<dynamic>> getHighDemandProfessions({int limit = 15}) async {
    final res = await http.get(
      Uri.parse('$baseUrl/professions/high-demand?limit=$limit&lang=$_lang'),
      headers: await _headers(),
    );
    return _decodeList(res);
  }

  Future<Map<String, dynamic>> getProfessionBySlug(String slug) async {
    final res = await http.get(
      Uri.parse('$baseUrl/professions/$slug?lang=$_lang'),
      headers: await _headers(),
    );
    return _decode(res);
  }

  // ── Recommendations ────────────────────────────────────────────────────────

  Future<List<dynamic>> getRecommendations() async {
    final res = await _getWithRefresh('$baseUrl/recommendations/?lang=$_lang');
    return _decodeList(res);
  }

  // ── Favorites ──────────────────────────────────────────────────────────────

  Future<List<dynamic>> getFavorites() async {
    final res = await _getWithRefresh('$baseUrl/favorites/');
    return _decodeList(res);
  }

  Future<Map<String, dynamic>> addFavorite(int professionId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/favorites/'),
      headers: await _headers(),
      body: json.encode({'profession_id': professionId}),
    );
    return _decode(res);
  }

  Future<void> removeFavorite(int professionId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/favorites/$professionId'),
      headers: await _headers(),
    );
    if (res.statusCode != 204) {
      throw ApiException(res.statusCode, 'Таңдаулылардан жою сәтсіз');
    }
  }

  Future<bool> checkFavorite(int professionId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/favorites/$professionId/status'),
      headers: await _headers(),
    );
    final data = _decode(res);
    return data['is_favorite'] as bool;
  }

  // ── Universities ───────────────────────────────────────────────────────────

  Future<List<dynamic>> getUniversities({String? city}) async {
    final uri = Uri.parse('$baseUrl/universities/').replace(
      queryParameters: {if (city != null) 'city': city},
    );
    final res = await http.get(uri, headers: await _headers());
    return _decodeList(res);
  }

  Future<List<dynamic>> getUniversitiesByProfession(
      String categoryKey) async {
    final res = await http.get(
      Uri.parse('$baseUrl/universities/by-profession/$categoryKey'),
      headers: await _headers(),
    );
    return _decodeList(res);
  }
}