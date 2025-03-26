import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5120/api';

  Future<List<Book>> getBooks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/bookall'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> booksList = jsonResponse['books'] ?? [];
        return booksList.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Ошибка загрузки книг: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при загрузке книг: $e');
      throw Exception('Ошибка сети: $e');
    }
  }

  Future<List<Book>> searchBooks(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookall/search?query=$query'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> booksList = jsonResponse['books'] ?? [];
        return booksList.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Ошибка поиска: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при поиске книг: $e');
      throw Exception('Ошибка сети: $e');
    }
  }

  Future<Book> getBookById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/bookall/$id'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Book.fromJson(jsonResponse);
      } else {
        throw Exception('Ошибка загрузки книги: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при загрузке книги: $e');
      throw Exception('Ошибка сети: $e');
    }
  }
} 