import 'package:flutter/material.dart';
import 'add_book_screen.dart';
import 'delete_book_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель администратора'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAdminButton(
              context,
              'Добавить книгу',
              Icons.add,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddBookScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildAdminButton(
              context,
              'Удалить книгу',
              Icons.delete,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeleteBookScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          text,
          style: const TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
