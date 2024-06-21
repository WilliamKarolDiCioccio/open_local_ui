import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;

part 'http.g.dart';

@JsonSerializable()
class HTTPResponse {
  final String status;
  final String currentTime;

  HTTPResponse({
    required this.status,
    required this.currentTime,
  });

  factory HTTPResponse.fromJson(Map<String, dynamic> json) =>
      _$HTTPResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HTTPResponseToJson(this);
}

@JsonSerializable()
class HTTPStreamResponse extends HTTPResponse {
  final int total;
  final int completed;
  final String startTime;

  HTTPStreamResponse({
    required super.status,
    required super.currentTime,
    required this.total,
    required this.completed,
    required this.startTime,
  });

  factory HTTPStreamResponse.fromJson(Map<String, dynamic> json) =>
      _$HTTPStreamResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HTTPStreamResponseToJson(this);
}

class HTTPMethods {
  static Future<http.Response> get(String url) async {
    return http.get(Uri.parse(url));
  }

  static Future<http.Response> post(String url,
      {Map<String, dynamic>? body}) async {
    return http.post(Uri.parse(url), body: jsonEncode(body));
  }

  static Future<http.Response> delete(String url,
      {Map<String, dynamic>? body}) async {
    return http.delete(Uri.parse(url), body: jsonEncode(body));
  }

  static Duration calculateRemainingTime(HTTPStreamResponse response) {
    final remainingBytes = response.total - response.completed;

    final startTime = DateTime.parse(response.startTime);
    final currentTime = DateTime.parse(response.currentTime);
    final elapsedTime = startTime.difference(currentTime);

    final speed = response.completed / elapsedTime.inSeconds;

    final remainingTime = remainingBytes ~/ speed;

    return Duration(seconds: remainingTime * -1);
  }
}
