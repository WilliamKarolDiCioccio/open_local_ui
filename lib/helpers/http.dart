import 'dart:convert';

import 'package:http/http.dart' as http;

class HTTPResponse {
  final String status;
  final String currentTime;

  HTTPResponse({
    required this.status,
    required this.currentTime,
  });
}

class HTTPStreamResponse extends HTTPResponse {
  final int total;
  final int completed;
  final String startTime;

  HTTPStreamResponse({
    required super.status,
    required this.total,
    required this.completed,
    required this.startTime,
    required super.currentTime,
  });
}

class HTTPHelpers {
  static Future<http.Response> get(String url) async {
    return http.get(Uri.parse(url));
  }

  static Future<http.Response> post(String url,
      {Map<String, String>? body}) async {
    return http.post(Uri.parse(url), body: jsonEncode(body));
  }

  static Future<http.Response> delete(String url,
      {Map<String, String>? body}) async {
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
