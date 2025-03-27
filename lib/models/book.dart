class Book {
  final int id;
  final String title;
  final String? description;
  final String? fragment;
  final String? cover_Link;
  final String? author;
  final int? authorId;
  final String? category;
  final int? categoryId;
  final String? branch;
  final int? branchId;
  final String? publisher;
  final int? publicationYear;
  final String? isbn;
  final int? pageCount;

  Book({
    required this.id,
    required this.title,
    this.description,
    this.fragment,
    this.cover_Link,
    this.author,
    this.authorId,
    this.category,
    this.categoryId,
    this.branch,
    this.branchId,
    this.publisher,
    this.publicationYear,
    this.isbn,
    this.pageCount,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      fragment: json['fragment'],
      cover_Link: json['cover_Link'],
      author: json['author'],
      authorId: json['authorId'],
      category: json['category'],
      categoryId: json['categoryId'],
      branch: json['branch'],
      branchId: json['branchId'],
      publisher: json['publisher'],
      publicationYear: json['publicationYear'],
      isbn: json['isbn'],
      pageCount: json['pageCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'fragment': fragment,
      'cover_Link': cover_Link,
      'author': author,
      'authorId': authorId,
      'category': category,
      'categoryId': categoryId,
      'branch': branch,
      'branchId': branchId,
      'publisher': publisher,
      'publicationYear': publicationYear,
      'isbn': isbn,
      'pageCount': pageCount,
    };
  }
} 