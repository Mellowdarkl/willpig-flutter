class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.category,
  });

  final String id;
  final String title;
  final String author;
  final String? category;

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: (json['id'] ?? '').toString(),
    title: (json['title'] ?? '').toString(),
    author: (json['author'] ?? '').toString(),
    category: json['category']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'author': author,
    if (category != null && category!.isNotEmpty) 'category': category,
  };
}
