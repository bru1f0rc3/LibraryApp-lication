import 'package:flutter/material.dart';
import 'screens/books_screen.dart';
import 'screens/search_screen.dart';
import 'screens/account_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/librarian_screen.dart';
import 'screens/user_history_screen.dart';
import 'screens/book_history_screen.dart';
import 'services/auth_service.dart';
import 'models/auth.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Библиотека',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => MainScreen(toggleTheme: toggleTheme),
        '/auth': (context) => const AuthScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  
  const MainScreen({super.key, required this.toggleTheme});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final _authService = AuthService();
  Account? _user;
  
  final List<Widget> _screens = [
    const BooksScreen(),
    const SearchScreen(),
    const AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getUser();
    if (mounted) {
      setState(() => _user = user);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Библиотека'),
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.light 
              ? Icons.dark_mode 
              : Icons.light_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      drawer: _buildDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Книги',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Поиск',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
          if (_user != null && (_user!.role == 1 || _user!.role == 2))
            BottomNavigationBarItem(
              icon: Icon(_user!.role == 1 ? Icons.admin_panel_settings : Icons.library_books),
              label: _user!.role == 1 ? 'Админ' : 'Библиотекарь',
            ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 3 && _user != null) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => _buildAdminMenu(),
            );
            return;
          }
          _onItemTapped(index);
        },
      ),
    );
  }

  Widget _buildAdminMenu() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _user?.role == 1 ? 'Панель администратора' : 'Панель библиотекаря',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_user?.role == 1) ...[
                  _buildMenuItem(
                    icon: Icons.book,
                    title: 'Управление книгами',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.request_quote,
                    title: 'Запросы на выдачу',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LibrarianScreen()),
                      );
                    },
                  ),
                ],
                if (_user?.role == 2) ...[
                  _buildMenuItem(
                    icon: Icons.request_quote,
                    title: 'Запросы на выдачу',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LibrarianScreen()),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _user?.fullName ?? 'Гость',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_user != null) ...[
              _buildDrawerItem(
                icon: Icons.favorite,
                title: 'Сохраненные книги',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookHistoryScreen(eventType: 'Saved'),
                    ),
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.check_circle,
                title: 'Взятые книги',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookHistoryScreen(eventType: 'Taken'),
                    ),
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.assignment_return,
                title: 'Возвращенные книги',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookHistoryScreen(eventType: 'Returned'),
                    ),
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.history,
                title: 'Вся история',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookHistoryScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              _buildDrawerItem(
                icon: Icons.email,
                title: 'Сменить email',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Реализовать смену email
                },
              ),
              _buildDrawerItem(
                icon: Icons.lock,
                title: 'Сменить пароль',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Реализовать смену пароля
                },
              ),
              _buildDrawerItem(
                icon: Icons.brightness_6,
                title: 'Сменить тему',
                onTap: () {
                  Navigator.pop(context);
                  widget.toggleTheme();
                },
              ),
              const Spacer(),
              _buildDrawerItem(
                icon: Icons.logout,
                title: 'Выйти',
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _authService.logout().then((_) {
                    Navigator.pushReplacementNamed(context, '/auth');
                  });
                },
              ),
            ] else ...[
              _buildDrawerItem(
                icon: Icons.login,
                title: 'Войти',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/auth');
                },
              ),
              _buildDrawerItem(
                icon: Icons.person_add,
                title: 'Регистрация',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/register');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}
