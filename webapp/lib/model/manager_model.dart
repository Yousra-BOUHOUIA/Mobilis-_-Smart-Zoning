class Manager {
  final String name;
  final String agency;
  final String email;

  final String phone;
  final String role;
  final String wilaya;
  String password;

 

  Manager({
    required this.name,
    required this.agency,
    required this.email,
    required this.phone,
    required this.role,
    required this.wilaya,
    required this.password,
    
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'agency': agency,
      'email': email,
      'phone': phone,
      'role': role,
      'wilaya': wilaya,
      'password': password,
      
    };
  }

  static Manager fromJson(Map<String, dynamic> json) {
    return Manager(
      name: json['name'] ?? '',
      agency: json['agency'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      wilaya: json['wilaya'] ?? '',
      password: json['password'] ?? '',
      
    );
  }
}
