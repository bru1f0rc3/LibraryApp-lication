import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../services/auth_service.dart';

class AdminBookHistoryScreen extends StatefulWidget {
  const AdminBookHistoryScreen({Key? key}) : super(key: key);

  @override
  State<AdminBookHistoryScreen> createState() => _AdminBookHistoryScreenState();
}

class _AdminBookHistoryScreenState extends State<AdminBookHistoryScreen> {
  final BookService _bookService = BookService(AuthService());
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final events = await _bookService.getAllBookEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getEventTypeText(String eventType) {
    switch (eventType) {
      case 'Saved':
        return 'Сохранено';
      case 'Taken':
        return 'Взято';
      case 'Requested':
        return 'Запрошено';
      case 'Returned':
        return 'Возвращено';
      default:
        return eventType;
    }
  }

  IconData _getEventTypeIcon(String eventType) {
    switch (eventType) {
      case 'Saved':
        return Icons.favorite;
      case 'Taken':
        return Icons.check_circle;
      case 'Requested':
        return Icons.pending;
      case 'Returned':
        return Icons.assignment_return;
      default:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История книг'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadEvents,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : _events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'История пуста',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              _getEventTypeIcon(event['eventType']),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(
                              event['bookTitle'] ?? 'Без названия',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['bookAuthor'] ?? 'Автор неизвестен',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  'Пользователь: ${event['userFullName'] ?? 'Неизвестен'} (${event['userLogin'] ?? 'Нет логина'})',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  _getEventTypeText(event['eventType']),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              DateTime.parse(event['createdAt']).toLocal().toString().split('.')[0],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
} 