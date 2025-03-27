import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../services/auth_service.dart';
import '../models/auth.dart';

class LibrarianScreen extends StatefulWidget {
  const LibrarianScreen({super.key});

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
      final books = await _bookService.getRequestedBooks();
      setState(() {
        _requestedBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> _approveRequest(int requestId) async {
    try {
      await _bookService.approveRequest(requestId);
      await _loadRequestedBooks();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Запрос одобрен')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> _rejectRequest(int requestId) async {
    try {
      await _bookService.rejectRequest(requestId);
      await _loadRequestedBooks();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Запрос отклонен')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель библиотекаря'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _requestedBooks.length,
              itemBuilder: (context, index) {
                final book = _requestedBooks[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(book['bookTitle'] ?? 'Название книги не найдено'),
                    subtitle: Text(book['FullName'] ?? 'Имя пользователя не найдено'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _approveRequest(book['id']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _rejectRequest(book['id']),
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