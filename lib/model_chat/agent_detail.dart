class deployPayload {
  bool? isDeployed;
  AgentConfigs? agentConfigs;

  deployPayload({
    this.isDeployed,
    this.agentConfigs,
  });

  factory deployPayload.fromJson(Map<String, dynamic> json) {
    return deployPayload(
      isDeployed: json['is_deployed'] != null ? json['is_deployed'] as bool : false,
      agentConfigs: json['agent_configs'] != null
          ? AgentConfigs.fromJson(json['agent_configs'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_deployed': isDeployed,
      'agent_configs': agentConfigs?.toJson(),
    };
  }
}

class AgentConfigs {
  String? image;
  String? displayName;
  List<String>? customQuestions;
  String? description;
  bool? isSpeech2Text;
  List<String>? languages;
  Map<String, dynamic>? colors;

  AgentConfigs({
    this.image,
    this.displayName,
    this.customQuestions,
    this.description,
    this.isSpeech2Text,
    this.languages,
    this.colors,

  });

  factory AgentConfigs.fromJson(Map<String, dynamic> json) {
    return AgentConfigs(
      image: json['image'],
      displayName: json['display_name'],
      description: json['description'],
      customQuestions: (json['custom_questions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isSpeech2Text: json['is_speech2text'],
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e as String) // Convert list of strings
          .toList(),
      colors: (json['colors'] as Map<String, dynamic>?)?.map((key,value)=>MapEntry(key, value as String)),

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'display_name': displayName,
      'description': description,
      'custom_questions': customQuestions,
      'is_speech2text': isSpeech2Text,
      'languages': languages,
      'colors': colors,
    };
  }
}
