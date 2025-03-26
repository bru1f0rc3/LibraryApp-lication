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
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/book/save/user/$accountId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> books = data['Books'];
        return books.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Ошибка загрузки сохраненных книг: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserBookEvents(int accountId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/book/events/user/$accountId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> events = data['events'] ?? [];
        
        // Получаем все уникальные bookId из событий
        final Set<int> bookIds = events.map((e) => e['bookId'] as int).toSet();
        
        // Получаем информацию о книгах
        final Map<int, Book> books = {};
        for (final bookId in bookIds) {
          try {
            final book = await getBookDetails(bookId);
            books[bookId] = book;
          } catch (e) {
            print('Ошибка получения информации о книге $bookId: $e');
          }
        }

        return events.map((event) {
          final bookId = event['bookId'] as int;
          final book = books[bookId];
          
          return {
            'id': event['id'] ?? 0,
            'bookId': bookId,
            'accountId': event['accountId'] ?? 0,
            'eventType': event['eventType'] ?? '',
            'createdAt': event['createdAt'] ?? '',
            'bookTitle': book?.title ?? 'Книга не найдена',
            'authorName': book?.authorName ?? 'Автор неизвестен',
          };
        }).toList();
      } else {
        throw Exception('Ошибка загрузки истории событий: ${response.statusCode}');
      }
    } catch (e) {
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
        
        // Получаем все уникальные bookId из событий
        final Set<int> bookIds = events.map((e) => e['bookId'] as int).toSet();
        
        // Получаем информацию о книгах
        final Map<int, Book> books = {};
        for (final bookId in bookIds) {
          try {
            final book = await getBookDetails(bookId);
            books[bookId] = book;
          } catch (e) {
            print('Ошибка получения информации о книге $bookId: $e');
          }
        }

        return events.map((event) {
          final bookId = event['bookId'] as int;
          final book = books[bookId];
          
          return {
            'id': event['id'] ?? 0,
            'bookId': bookId,
            'accountId': event['accountId'] ?? 0,
            'eventType': event['eventType'] ?? '',
            'createdAt': event['createdAt'] ?? '',
            'bookTitle': book?.title ?? 'Книга не найдена',
            'authorName': book?.authorName ?? 'Автор неизвестен',
          };
        }).toList();
      } else {
        throw Exception('Ошибка загрузки истории событий: ${response.statusCode}');
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
} 