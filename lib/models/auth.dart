class LoginDto {
  final String login;
  final String password;

  LoginDto({required this.login, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'password': password,
    };
  }
}

class Account {
  final int id;
  final String login;
  final String fullName;
  final String email;
  final String phone;
  final int role;

  Account({
    required this.id,
    required this.login,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      login: json['login'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
} 