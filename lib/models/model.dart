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

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      name: json['name'],
      modifiedAt: DateTime.parse(json['modified_at']),
      size: json['size'],
      digest: json['digest'],
      details: ModelDetails.fromJson(json['details']),
    );
  }
}

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

  factory ModelDetails.fromJson(Map<String, dynamic> json) {
    return ModelDetails(
      format: json['format'],
      family: json['family'],
      families:
          json['families'] != null ? List<String>.from(json['families']) : null,
      parameterSize: json['parameter_size'],
      quantizationLevel: json['quantization_level'],
    );
  }
}
