class Event {
  final String id;
  final String title;
  final String description;
  final String? image;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final Map<String, dynamic> author;
  final String category;
  final List<dynamic> attendees;
  final int? maxCapacity;
  final bool isPublished;
  final String status;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.author,
    required this.category,
    required this.attendees,
    this.maxCapacity,
    required this.isPublished,
    required this.status,
    required this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      location: json['location'] ?? '',
      author: json['author'] ?? {},
      category: json['category'] ?? '',
      attendees: json['attendees'] ?? [],
      maxCapacity: json['maxCapacity'],
      isPublished: json['isPublished'] ?? true,
      status: json['status'] ?? 'upcoming',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location,
      'author': author,
      'category': category,
      'attendees': attendees,
      'maxCapacity': maxCapacity,
      'isPublished': isPublished,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
