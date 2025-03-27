import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import 'auth_service.dart';

class BookService {
  static const String baseUrl = 'http://localhost:5120/api';
  final AuthService _authService;

  BookService(this._authService);

  Future<List<Book>> getAllBooks() async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/bookall'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> books = data['books'] ?? [];
        return books.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Ошибка загрузки книг: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  Future<Book> getBookDetails(int id) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/GetBookIdDetails?id=$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        if (jsonList.isEmpty) {
          throw Exception('Книга не найдена');
        }
        return Book.fromJson(jsonList.first);
      } else {
        throw Exception('Ошибка загрузки книги: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  Future<List<Book>> searchBooks(String query) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/Search?searchQuery=$query'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> books = data['books'] ?? [];
        return books.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Ошибка поиска книг: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRequestedBooks() async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/book/requested/list/requested'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Ошибка загрузки запрошенных книг: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  Future<void> requestBook(int bookId, int accountId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/book/requested'),
        headers: headers,
        body: jsonEncode({
          'bookId': bookId,
          'accountId': accountId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Ошибка запроса книги: $e');
    }
  }

  Future<void> approveRequest(int requestId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/book/requested/approve/$requestId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Ошибка одобрения запроса: $e');
    }
  }

  Future<void> rejectRequest(int requestId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/book/requested/reject/$requestId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Ошибка отклонения запроса: $e');
    }
  }

  Future<void> returnBook(int bookId, int accountId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/book/returned'),
        headers: headers,
        body: jsonEncode({
          'bookId': bookId,
          'accountId': accountId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Ошибка возврата книги: $e');
    }
  }

  Future<void> saveBook(int bookId, int accountId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/book/save'),
        headers: headers,
        body: jsonEncode({
          'bookId': bookId,
          'accountId': accountId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Ошибка сохранения книги: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserSavedBooks(int accountId) async {
    try {
      print('Получение сохраненных книг для пользователя с ID: $accountId');
      final headers = await _authService.getAuthHeaders();
      print('Заголовки запроса: $headers');
      
      final response = await http.get(
        Uri.parse('$baseUrl/book/save/user/$accountId'),
        headers: headers,
      );

      print('Статус ответа: ${response.statusCode}');
      print('Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Декодированные данные: $data');
        
        final List<Map<String, dynamic>> result = [];
        for (var item in data) {
          print('Обработка элемента: $item');
          result.add({
            'id': item['id'],
            'bookTitle': item['bookTitle'],
            'CoverLink': item['CoverLink'],
            'createdAt': item['createdAt'],
          });
        }
        print('Обработанные данные: $result');
        return result;
      } else {
        throw Exception('Ошибка загрузки сохраненных книг: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при получении сохраненных книг: $e');
      throw Exception('Ошибка сети: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserBookEvents(int accountId) async {
    try {
      print('Получение истории книг для пользователя с ID: $accountId');
      final headers = await _authService.getAuthHeaders();
      print('Заголовки запроса: $headers');
      
      final response = await http.get(
        Uri.parse('$baseUrl/book/events/user/$accountId'),
        headers: headers,
      );

      print('Статус ответа: ${response.statusCode}');
      print('Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Декодированные данные: $data');
        
        final List<dynamic> events = data['events'] ?? [];
        final List<Map<String, dynamic>> result = [];
        
        for (var event in events) {
          print('Обработка события: $event');
          result.add({
            'id': event['id'] ?? 0,
            'eventType': event['eventType'] ?? 'Unknown',
            'createdAt': event['createdAt'] ?? '',
            'bookTitle': event['bookTitle'] ?? 'Книга не найдена',
            'CoverLink': event['CoverLink'],
          });
        }
        print('Обработанные данные: $result');
        return result;
      } else {
        throw Exception('Ошибка загрузки истории книг: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при получении истории книг: $e');
      throw Exception('Ошибка сети: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllBookEvents() async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/book/events/all'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> events = data['events'] ?? [];
        
        final List<Map<String, dynamic>> result = [];
        for (var event in events) {
          try {
            final book = await getBookDetails(event['bookId']);
            result.add({
              'id': event['id'] ?? 0,
              'eventType': event['eventType'] ?? 'Unknown',
              'createdAt': event['createdAt'] ?? '',
              'bookTitle': book.title,
              'cover_Link': book.cover_Link,
              'userLogin': event['userLogin'] ?? 'Неизвестен',
              'userFullName': event['userFullName'] ?? 'Неизвестен',
            });
          } catch (e) {
            print('Ошибка получения информации о книге ${event['bookId']}: $e');
            result.add({
              'id': event['id'] ?? 0,
              'eventType': event['eventType'] ?? 'Unknown',
              'createdAt': event['createdAt'] ?? '',
              'bookTitle': 'Книга не найдена',
              'cover_Link': null,
              'userLogin': event['userLogin'] ?? 'Неизвестен',
              'userFullName': event['userFullName'] ?? 'Неизвестен',
            });
          }
        }
        return result;
      } else {
        throw Exception('Ошибка сети: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllAuthors() async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/Authors'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Ошибка загрузки авторов: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  Future<void> removeSavedBook(int savedBookId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      headers['Content-Type'] = 'application/json';
      
      final response = await http.delete(
        Uri.parse('$baseUrl/book/save/$savedBookId'),
        headers: headers,
      );

      print('Удаление книги: $savedBookId');
      print('Статус ответа: ${response.statusCode}');
      print('Тело ответа: ${response.body}');

      if (response.statusCode != 200) {
        if (response.body.isNotEmpty) {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Ошибка удаления книги из сохраненных');
        }
        throw Exception('Ошибка удаления книги из сохраненных: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при удалении книги: $e');
      throw Exception('Ошибка удаления книги из сохраненных: $e');
    }
  }
} 