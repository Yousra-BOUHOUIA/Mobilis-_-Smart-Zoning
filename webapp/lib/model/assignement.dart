
// Define an Assignment model to store the data
class Assignment {
  final int zoneId;
  final String representativeId;
  final String representativeName;
  final String representativeEmail;
  final List<String> pdvIds; // Store PDV IDs

  Assignment({
    required this.zoneId,
    required this.representativeId,
    required this.representativeName,
    required this.representativeEmail,
    required this.pdvIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'zoneId': zoneId,
      'representativeId': representativeId,
      'representativeName': representativeName, 
      'representativeEmail': representativeEmail,
      'pdvIds': pdvIds,
    };
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      zoneId: json['zoneId'],
      representativeId: json['representativeId'],
      representativeName: json['representativeName'],
      representativeEmail: json['representativeEmail'],
      pdvIds: List<String>.from(json['pdvIds']),
    );
  }
}

