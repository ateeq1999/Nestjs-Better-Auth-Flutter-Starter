class User {
  final String id;
  final String email;
  final String? name;
  final String? image;
  final bool emailVerified;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.image,
    required this.emailVerified,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      image: json['image'] as String?,
      emailVerified: json['emailVerified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'image': image,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? image,
    bool? emailVerified,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      image: image ?? this.image,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
