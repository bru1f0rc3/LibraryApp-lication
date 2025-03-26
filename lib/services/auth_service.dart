import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:5120/api';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  Future<void> saveUser(Account user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, jsonEncode(user.toJson()));
  }

  Future<Account?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(userKey);
    if (userJson != null) {
      return Account.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/auth/validate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }

  Future<Account> login(String login, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(LoginDto(login: login, password: password).toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = Account.fromJson(data['user']);
        await saveUser(user);
        await saveToken(data['token']);
        return user;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Ошибка авторизации');
      }
    } catch (e) {
      throw Exception('Ошибка авторизации: $e');
    }
  }

  Future<void> register(String login, String password, String fullName, String email, String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'login': login,
          'password': password,
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'role': 3, // Роль читателя по умолчанию
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Ошибка регистрации: $e');
    }
  }

  Future<Account> getUserProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Не авторизован');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Account.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Ошибка загрузки профиля: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserBooks() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Не авторизован');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/books'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Ошибка загрузки книг: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  // Метод для добавления заголовка авторизации к запросам
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
} 