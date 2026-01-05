class Announcement {
  final String id;
  final String title;
  final String description;
  final String content;
  final String? image;
  final Map<String, dynamic> author;
  final String category;
  final bool isPinned;
  final bool isPublished;
  final int views;
  final DateTime createdAt;
  final DateTime updatedAt;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    this.image,
    required this.author,
    required this.category,
    required this.isPinned,
    required this.isPublished,
    required this.views,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      image: json['image'],
      author: json['author'] ?? {},
      category: json['category'] ?? '',
      isPinned: json['isPinned'] ?? false,
      isPublished: json['isPublished'] ?? true,
      views: json['views'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'image': image,
      'author': author,
      'category': category,
      'isPinned': isPinned,
      'isPublished': isPublished,
      'views': views,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
