import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../services/auth_service.dart';
import '../models/auth.dart';

class UserHistoryScreen extends StatefulWidget {
  const UserHistoryScreen({super.key});

  @override
  State<UserHistoryScreen> createState() => _UserHistoryScreenState();
}

class _UserHistoryScreenState extends State<UserHistoryScreen> {
  final BookService _bookService = BookService(AuthService());
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _bookEvents = [];
  bool _isLoading = true;
  Account? _user;

  @override
  void initState() {
    super.initState();
    _loadUserAndHistory();
  }

  Future<void> _loadUserAndHistory() async {
    try {
      final user = await _authService.getUser();
      if (user != null) {
        final events = await _bookService.getUserBookEvents(user.id);
        setState(() {
          _user = user;
          _bookEvents = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История книг'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _bookEvents.length,
              itemBuilder: (context, index) {
                final event = _bookEvents[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Книга ID: ${event['bookId']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Тип события: ${event['eventType']}'),
                        Text('Дата: ${DateTime.parse(event['date']).toString().split('.')[0]}'),
                      ],
                    ),
                    leading: Icon(
                      _getEventIcon(event['eventType']),
                      color: _getEventColor(event['eventType']),
                    ),
                  ),
                );
              },
            ),
    );
  }

  IconData _getEventIcon(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'requested':
        return Icons.bookmark_add;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'returned':
        return Icons.assignment_return;
      case 'saved':
        return Icons.bookmark;
      default:
        return Icons.book;
    }
  }

  Color _getEventColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'requested':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'returned':
        return Colors.blue;
      case 'saved':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
} 