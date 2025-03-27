import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../services/auth_service.dart';

class LibrarianScreen extends StatefulWidget {
  const LibrarianScreen({Key? key}) : super(key: key);

  @override
  State<LibrarianScreen> createState() => _LibrarianScreenState();
}

class _LibrarianScreenState extends State<LibrarianScreen> {
  final BookService _bookService = BookService(AuthService());
  List<Map<String, dynamic>> _requestedBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequestedBooks();
  }

  Future<void> _loadRequestedBooks() async {
    try {
      setState(() => _isLoading = true);
      final books = await _bookService.getRequestedBooks();
      print('Полученные данные: $books'); // Для отладки
      setState(() {
        _requestedBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      print('Ошибка загрузки: $e'); // Для отладки
      setState(() {
        _requestedBooks = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки данных: $e')),
        );
      }
    }
  }

  Future<void> _approveRequest(int requestId) async {
    try {
      await _bookService.approveRequest(requestId);
      await _loadRequestedBooks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Запрос одобрен')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  Future<void> _rejectRequest(int requestId) async {
    try {
      await _bookService.rejectRequest(requestId);
      await _loadRequestedBooks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Запрос отклонен')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель библиотекаря'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequestedBooks,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requestedBooks.isEmpty
              ? const Center(
                  child: Text('Нет запросов на книги'),
                )
              : ListView.builder(
                  itemCount: _requestedBooks.length,
                  itemBuilder: (context, index) {
                    final book = _requestedBooks[index];
                    print('Отображение книги: $book'); // Для отладки
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(
                          book['bookTitle'] ?? 'Название книги не найдено',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book['userFullName'] ?? 'Имя пользователя не найдено',
                              style: const TextStyle(fontSize: 14),
                            ),
                            if (book['createdAt'] != null)
                              Text(
                                'Дата запроса: ${DateTime.parse(book['createdAt']).toLocal().toString().split('.')[0]}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle_outline),
                              onPressed: () => _approveRequest(book['id']),
                              color: Colors.green,
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel_outlined),
                              onPressed: () => _rejectRequest(book['id']),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 