class UrlConfig {
  int maxDepth;
  String url;

  UrlConfig({required this.maxDepth, required this.url});

  // Method to convert JSON to UrlConfig
  factory UrlConfig.fromJson(Map<String, dynamic> json) {
    return UrlConfig(
      maxDepth: json['max_depth'],
      url: json['url'] ?? '',
    );
  }

  // Method to convert UrlConfig to JSON
  Map<String, dynamic> toJson() {
    return {
      'max_depth': maxDepth,
      'url': url,
    };
  }
}

class DataConfig {
  String dbType;
  String vectorType;
  List<UrlConfig> urlConfigs;
  List<String> files;
  String dbConnectionName;
  String type;
  String category;
  List<String> dbTableNames;

  DataConfig({
    this.dbType = '',
    required this.vectorType,
    required this.urlConfigs,
    this.files = const [],
    this.dbConnectionName = '',
    this.type = '',
    this.category = '',
    this.dbTableNames = const [],
  });

  // Method to convert JSON to DataConfig
  factory DataConfig.fromJson(Map<String, dynamic> json) {
    var urlConfigsFromJson = json['url_configs'] as List;
    List<UrlConfig> urlConfigsList = urlConfigsFromJson.map((urlConfigJson) => UrlConfig.fromJson(urlConfigJson)).toList();

    return DataConfig(
      dbType: json['db_type'] ?? '',
      vectorType: json['vector_type'] ?? '',
      urlConfigs: urlConfigsList,
      files: List<String>.from(json['files'] ?? []),
      dbConnectionName: json['db_connection_name'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      dbTableNames: List<String>.from(json['db_table_names'] ?? []),
    );
  }

  // Method to convert DataConfig to JSON
  Map<String, dynamic> toJson() {
    return {
      'db_type': dbType,
      'vector_type': vectorType,
      'url_configs': urlConfigs.map((urlConfig) => urlConfig.toJson()).toList(),
      'files': files,
      'db_connection_name': dbConnectionName,
      'type': type,
      'category': category,
      'db_table_names': dbTableNames,
    };
  }
}
