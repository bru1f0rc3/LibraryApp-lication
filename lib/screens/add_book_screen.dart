import 'package:flutter/material.dart';

class AddBookScreen extends StatefulWidget {
  final Map<String, dynamic>? bookData;
  
  const AddBookScreen({
    super.key,
    this.bookData,
  });

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Контроллеры для полей книги
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _fragmentController;
  late final TextEditingController _coverLinkController;
  
  // Контроллеры для полей автора
  late final TextEditingController _authorNameController;
  bool _useExistingAuthor = false;
  String? _selectedAuthor;
  
  // Контроллеры для полей категории
  late final TextEditingController _categoryNameController;
  bool _useExistingCategory = false;
  String? _selectedCategory;
  
  // Контроллеры для полей филиала
  late final TextEditingController _branchNameController;
  bool _useExistingBranch = false;
  String? _selectedBranch;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Инициализация контроллеров с данными книги, если они есть
    _titleController = TextEditingController(text: widget.bookData?['title']);
    _descriptionController = TextEditingController(text: widget.bookData?['description']);
    _fragmentController = TextEditingController(text: widget.bookData?['fragment']);
    _coverLinkController = TextEditingController(text: widget.bookData?['cover_link']);
    _authorNameController = TextEditingController(text: widget.bookData?['author_name']);
    _categoryNameController = TextEditingController(text: widget.bookData?['category_name']);
    _branchNameController = TextEditingController(text: widget.bookData?['branch_name']);
    
    // Если есть данные книги, устанавливаем флаги использования существующих элементов
    if (widget.bookData != null) {
      _useExistingAuthor = true;
      _useExistingCategory = true;
      _useExistingBranch = true;
      _selectedAuthor = widget.bookData!['author_id'].toString();
      _selectedCategory = widget.bookData!['category_id'].toString();
      _selectedBranch = widget.bookData!['branch_id'].toString();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _fragmentController.dispose();
    _coverLinkController.dispose();
    _authorNameController.dispose();
    _categoryNameController.dispose();
    _branchNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookData == null ? 'Добавить книгу' : 'Редактировать книгу'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Книга'),
            Tab(text: 'Автор'),
            Tab(text: 'Категория'),
            Tab(text: 'Филиал'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookTab(),
          _buildAuthorTab(),
          _buildCategoryTab(),
          _buildBranchTab(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_tabController.index > 0)
              ElevatedButton(
                onPressed: () {
                  _tabController.animateTo(_tabController.index - 1);
                },
                child: const Text('Назад'),
              )
            else
              const SizedBox.shrink(),
            if (_tabController.index < 3)
              ElevatedButton(
                onPressed: () {
                  _tabController.animateTo(_tabController.index + 1);
                },
                child: const Text('Далее'),
              )
            else
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: Добавить логику сохранения
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.bookData == null ? 'Сохранить' : 'Сохранить изменения'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название книги',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите название книги';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fragmentController,
              decoration: const InputDecoration(
                labelText: 'Фрагмент',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _coverLinkController,
              decoration: const InputDecoration(
                labelText: 'Ссылка на обложку',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Выберите существующие элементы:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Автор'),
                      value: _useExistingAuthor,
                      onChanged: (value) {
                        setState(() {
                          _useExistingAuthor = value ?? false;
                        });
                      },
                    ),
                    if (_useExistingAuthor)
                      DropdownButtonFormField<String>(
                        value: _selectedAuthor,
                        decoration: const InputDecoration(
                          labelText: 'Выберите автора',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: '1', child: Text('Автор 1')),
                          DropdownMenuItem(value: '2', child: Text('Автор 2')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedAuthor = value;
                          });
                        },
                      ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Категория'),
                      value: _useExistingCategory,
                      onChanged: (value) {
                        setState(() {
                          _useExistingCategory = value ?? false;
                        });
                      },
                    ),
                    if (_useExistingCategory)
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Выберите категорию',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: '1', child: Text('Категория 1')),
                          DropdownMenuItem(value: '2', child: Text('Категория 2')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Филиал'),
                      value: _useExistingBranch,
                      onChanged: (value) {
                        setState(() {
                          _useExistingBranch = value ?? false;
                        });
                      },
                    ),
                    if (_useExistingBranch)
                      DropdownButtonFormField<String>(
                        value: _selectedBranch,
                        decoration: const InputDecoration(
                          labelText: 'Выберите филиал',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: '1', child: Text('Филиал 1')),
                          DropdownMenuItem(value: '2', child: Text('Филиал 2')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedBranch = value;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _authorNameController,
            decoration: const InputDecoration(
              labelText: 'ФИО автора',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Пожалуйста, введите ФИО автора';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Существующие авторы:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 2, // TODO: Заменить на реальное количество авторов
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text('Автор ${index + 1}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // TODO: Добавить логику редактирования
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _categoryNameController,
            decoration: const InputDecoration(
              labelText: 'Название категории',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Пожалуйста, введите название категории';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Существующие категории:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 2, // TODO: Заменить на реальное количество категорий
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text('Категория ${index + 1}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // TODO: Добавить логику редактирования
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _branchNameController,
            decoration: const InputDecoration(
              labelText: 'Название филиала',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Пожалуйста, введите название филиала';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Существующие филиалы:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 2, // TODO: Заменить на реальное количество филиалов
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text('Филиал ${index + 1}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // TODO: Добавить логику редактирования
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 