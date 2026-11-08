class UserModel {
  final String id;
  final String? name;
  final String username;
  final String? role;
  final String? email;

  const UserModel({
    required this.id,
    required this.username,
    this.name,
    this.role,
    this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return UserModel(
      id: rawId == null ? '' : rawId.toString(),
      name: json['name']?.toString(),
      username: (json['username'] ?? json['name'] ?? '').toString(),
      role: json['role']?.toString(),
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'role': role,
    'email': email,
  };
}
