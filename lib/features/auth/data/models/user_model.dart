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
    return UserModel(
      id: json['id'].toString(),
      name: json['name']?.toString(),
      username: json['username'] ?? json['name'] ?? '',
      role: json['role']?.toString(),
      email: json['email'],
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
