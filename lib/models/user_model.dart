class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? role;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.role,
    this.avatarUrl,
  });

  // Mengubah data dari Supabase (Map) ke Object Flutter
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      fullName: map['full_name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'],
      avatarUrl: map['avatar_url'],
    );
  }

  // Mengubah Object Flutter ke Map untuk dikirim ke Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}