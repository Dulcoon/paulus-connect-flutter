class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final int isCompleted;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isCompleted,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      isCompleted: json['isCompleted'] is bool
          ? (json['isCompleted'] ? 1 : 0)
          : int.tryParse(json['isCompleted'].toString()) ??
              0, // Konversi ke int
    );
  }
}
