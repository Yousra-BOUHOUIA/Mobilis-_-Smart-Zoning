class User {
  final int id;
  final String fullname;
  final String email;
  final String phone;
  final String manager;
  final String password;

  
  User({
    required this.id, 
    required this.fullname, 
    required this.email,
    required this.phone, 
    required this.manager, 
    required this.password

  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_users'],
      fullname: json['fullname'],
      email: json['email'],
      phone: json['phone'],
      manager: json['manager'],
      password: json['password'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_users': id,
      'fullname': fullname,
      'email': email,
      'phone': phone,
      'manager': manager,
      'password': password,
    };
  }
}