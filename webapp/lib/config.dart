class BackendConfig {
  // Base URL for the API — just the domain + port
  static const String baseUrl = "http://localhost:8000";

  // Endpoints
  static String get uploadCsvEndpoint => "$baseUrl/pdv/upload-csv";
  static String get rerunClusteringEndpoint => "$baseUrl/pdv/rerun"; 
  static String get clustersEndpoint => "$baseUrl/pdv/clusters";
   // Add these new endpoints
  static String get assignPdvEndpoint => "$baseUrl/pdv/assign-pdv";
  static String get deletePdvEndpoint => "$baseUrl/pdv/delete-pdv";
}
  

