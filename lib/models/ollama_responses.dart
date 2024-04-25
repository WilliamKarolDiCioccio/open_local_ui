import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:open_local_ui/helpers/http.dart';

part 'ollama_responses.g.dart';

@JsonSerializable()
class OllamaPullResponse extends HTTPStreamResponse {
  OllamaPullResponse({
    required super.status,
    required super.total,
    required super.completed,
    required super.startTime,
    required super.currentTime,
  });

  factory OllamaPullResponse.fromJson(Map<String, dynamic> json) =>
      _$OllamaPullResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OllamaPullResponseToJson(this);
}

@JsonSerializable()
class OllamaPushResponse extends HTTPStreamResponse {
  OllamaPushResponse({
    required super.status,
    required super.total,
    required super.completed,
    required super.startTime,
    required super.currentTime,
  });

  factory OllamaPushResponse.fromJson(Map<String, dynamic> json) =>
      _$OllamaPushResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OllamaPushResponseToJson(this);
}

@JsonSerializable()
class OllamaCreateResponse extends HTTPStreamResponse {
  OllamaCreateResponse({
    required super.status,
    required super.total,
    required super.completed,
    required super.startTime,
    required super.currentTime,
  });

  factory OllamaCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$OllamaCreateResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OllamaCreateResponseToJson(this);
}
