class AppConfigResponse {
  late AppConfig data;
  late int statusCode;

  AppConfigResponse({required this.data, required this.statusCode});

  AppConfigResponse.fromJson(Map<String, dynamic> json) {
    data = AppConfig.fromJson(json['data']);
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data.toJson();
    data['statusCode'] = statusCode;
    return data;
  }
}

class AppConfig {
  late String config;

  AppConfig({required this.config});

  AppConfig.fromJson(Map<String, dynamic> json) {
    config = json['config'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['config'] = config;
    return data;
  }
}
