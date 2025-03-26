class Book {
  final int id;
  final String title;
  final String? description;
  final String? fragment;
  final String? coverLink;
  final int authorId;
  final int branchId;
  final int categoryId;
  final int year;
  final String isbn;
  final int quantity;
  final int availableQuantity;
  final String? authorName;

  Book({
    required this.id,
    required this.title,
    this.description,
    this.fragment,
    this.coverLink,
    required this.authorId,
    required this.branchId,
    required this.categoryId,
    required this.year,
    required this.isbn,
    required this.quantity,
    required this.availableQuantity,
    this.authorName,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      fragment: json['fragment'],
      coverLink: json['cover_Link'],
      authorId: json['authorId'] ?? 0,
      branchId: json['branchId'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      year: json['year'] ?? 0,
      isbn: json['isbn'] ?? '',
      quantity: json['quantity'] ?? 0,
      availableQuantity: json['availableQuantity'] ?? 0,
      authorName: json['authorName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'fragment': fragment,
      'cover_Link': coverLink,
      'authorId': authorId,
      'branchId': branchId,
      'categoryId': categoryId,
      'year': year,
      'isbn': isbn,
      'quantity': quantity,
      'availableQuantity': availableQuantity,
      'authorName': authorName,
    };
  }
} 