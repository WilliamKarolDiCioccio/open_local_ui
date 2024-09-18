import 'package:freezed_annotation/freezed_annotation.dart';

part 'model.g.dart';

/// This class is used to encapsulate the properties of an Ollama model.
///
/// The [Model] class is annotated with `@JsonSerializable` to enable JSON serialization and deserialization.
///
/// NOTE: The casing of the fields in the JSON data is forced to snake_case for interoperability with the Ollama REST API. This allows Ollama API responses to be converted to [Model] objects.
///
/// Model options are encapsulated in the [ModelSettings] class.
@JsonSerializable(fieldRename: FieldRename.snake)
class Model {
  final String name;
  final DateTime modifiedAt;
  final int size;
  final String digest;
  final ModelDetails details;

  Model({
    required this.name,
    required this.modifiedAt,
    required this.size,
    required this.digest,
    required this.details,
  });

  factory Model.fromJson(Map<String, dynamic> json) => _$ModelFromJson(json);

  Map<String, dynamic> toJson() => _$ModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ModelDetails {
  final String format;
  final String family;
  final List<String>? families;
  final String parameterSize;
  final String quantizationLevel;

  ModelDetails({
    required this.format,
    required this.family,
    required this.families,
    required this.parameterSize,
    required this.quantizationLevel,
  });

  factory ModelDetails.fromJson(Map<String, dynamic> json) =>
      _$ModelDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ModelDetailsToJson(this);
}

/// This class is used to encapsulate the properties of the Ollama model settings.
///
/// For more information on the model settings, refer to the Ollama API documentation at https://github.com/ollama/ollama/blob/main/docs/modelfile.md#valid-parameters-and-values.
@JsonSerializable()
class ModelSettings {
  String? systemPrompt;
  bool? enableWebSearch;
  bool? enableDocsSearch;
  int? numGpu;
  int? keepAlive;
  double? temperature;
  int? concurrencyLimit;
  bool? f16KV;
  double? frequencyPenalty;
  bool? logitsAll;
  bool? lowVram;
  int? mainGpu;
  int? mirostat;
  double? mirostatEta;
  double? mirostatTau;
  int? numBatch;
  int? numCtx;
  int? numKeep;
  int? numPredict;
  int? numThread;
  bool? numa;
  bool? penalizeNewline;
  double? presencePenalty;
  int? repeatLastN;
  double? repeatPenalty;
  int? seed;
  List<String>? stop;
  double? tfsZ;
  int? topK;
  double? topP;
  double? typicalP;
  bool? useMlock;
  bool? useMmap;
  bool? vocabOnly;

  ModelSettings({
    this.systemPrompt,
    this.enableWebSearch,
    this.enableDocsSearch,
    required this.numGpu,
    required this.keepAlive,
    required this.temperature,
    required this.concurrencyLimit,
    this.f16KV,
    this.frequencyPenalty,
    this.logitsAll,
    this.lowVram,
    this.mainGpu,
    this.mirostat,
    this.mirostatEta,
    this.mirostatTau,
    this.numBatch,
    this.numCtx,
    this.numKeep,
    this.numPredict,
    this.numThread,
    this.numa,
    this.penalizeNewline,
    this.presencePenalty,
    this.repeatLastN,
    this.repeatPenalty,
    this.seed,
    this.stop,
    this.tfsZ,
    this.topK,
    this.topP,
    this.typicalP,
    this.useMlock,
    this.useMmap,
    this.vocabOnly,
  });

  factory ModelSettings.fromJson(Map<String, dynamic> json) =>
      _$ModelSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ModelSettingsToJson(this);
}
