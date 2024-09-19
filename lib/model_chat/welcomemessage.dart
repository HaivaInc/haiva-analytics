class WelcomeMessageData {
  final String type;
  final Map<String, dynamic> data;

  WelcomeMessageData({required this.type, required this.data});

  factory WelcomeMessageData.fromJson(Map<String, dynamic> json) {
    return WelcomeMessageData(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }
}
