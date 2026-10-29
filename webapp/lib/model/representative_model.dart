class Representative {
  final String name;
  final String email;
  // Add any other fields you might have in your JSON file
  // Such as phone number, ID, region, etc.
  
  Representative({
    required this.name,
    required this.email,
    // Add other fields here
  });
  
  // Factory constructor to create a Representative from JSON
  factory Representative.fromJson(Map<String, dynamic> json) {
    return Representative(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      // Handle any other fields from your JSON structure
    );
  }
  
  // Convert Representative to JSON format
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      // Add other fields to the JSON output
    };
  }
}