class Session {
  final String id;
  final String userId;
  final DateTime expiresAt;
  final String? ipAddress;
  final String? userAgent;

  const Session({
    required this.id,
    required this.userId,
    required this.expiresAt,
    this.ipAddress,
    this.userAgent,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      userId: json['userId'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'expiresAt': expiresAt.toIso8601String(),
      'ipAddress': ipAddress,
      'userAgent': userAgent,
    };
  }
}
