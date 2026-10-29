class PDV {
  final String name;
  final String commune;
  final String daira;
  final String wilaya;
  final double latitude;
  final double longitude;

  PDV({
    required this.name,
    required this.commune,
    required this.daira,
    required this.wilaya,
    required this.latitude,
    required this.longitude,
  });

  factory PDV.fromJson(Map<String, dynamic> json) {
    return PDV(
      name: json['Nom du point de vente'] ?? '',
      commune: json['Commune'] ?? '',
      daira: json['Daira'] ?? '',
      wilaya: json['Wilaya'] ?? '',
      latitude: (json['Latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['Longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Nom du point de vente': name,
      'Commune': commune,
      'Daira': daira,
      'Wilaya': wilaya,
      'Latitude': latitude,
      'Longitude': longitude,
    };
  }
}
