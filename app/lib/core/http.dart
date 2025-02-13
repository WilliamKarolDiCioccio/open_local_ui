import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;

part 'http.g.dart';

/// Represents an HTTP single response with embedded metadata.
///
/// This classe is marked as `@JsonSerializable`.
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

/// Represents an HTTP stream response with emdedded metadata.
///
/// This class is marked as `@JsonSerializable`.
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

/// A helper class for handling HTTP requests.
///
/// The [HTTPHelpers] class provides basic wrappers around the `http` package for making HTTP requests.
class HTTPHelpers {
  /// Sends a GET request to the given [url].
  ///
  /// See https://restfulapi.net/http-methods/#get.
  static Future<http.Response> get(String url) async {
    return http.get(Uri.parse(url));
  }

  /// Sends a POST request to the given [url].
  ///
  /// See https://restfulapi.net/http-methods/#post.
  static Future<http.Response> post(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    return http.post(Uri.parse(url), body: jsonEncode(body));
  }

  /// Sends a PUT request to the given [url].
  ///
  /// See https://restfulapi.net/http-methods/#put.
  static Future<http.Response> put(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    return http.put(Uri.parse(url), body: jsonEncode(body));
  }

  /// Sends a PUT request to the given [url].
  ///
  /// See https://restfulapi.net/http-methods/#delete.
  static Future<http.Response> delete(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    return http.delete(Uri.parse(url), body: jsonEncode(body));
  }

  /// Sends a PATCH request to the given [url].
  ///
  /// See https://restfulapi.net/http-methods/#patch.
  static Future<http.Response> patch(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    return http.patch(Uri.parse(url), body: jsonEncode(body));
  }

  /// Calculates the remaining time for the given [response] stream to complete.
  ///
  /// The [response] parameter should be an instance of [HTTPStreamResponse].
  /// Returns a [Duration] representing the remaining time.
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
