class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String role;
  final String? avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    required this.role,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      role: json['role'] ?? 'user',
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'avatar': avatar,
    };
  }
}
