import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_local_ui/core/http.dart';

part 'ollama_responses.g.dart';

/// Represents a response from the Ollama API when pulling a model from registry.
///
/// This class extends the [HTTPStreamResponse] class and provides additional functionality specific to Ollama responses.

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

/// Represents a response from the Ollama API when pushing a model to the registry.
///
/// This class extends the [HTTPStreamResponse] class and provides additional functionality specific to OllamaPush responses.
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

/// Represents the response returned from the Ollama API when creating a new model locally.
///
/// This class extends the [HTTPStreamResponse] class and provides additional functionality specific to OllamaPush responses.
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
