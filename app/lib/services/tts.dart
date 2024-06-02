import 'dart:convert';
import 'dart:io';

import 'package:grpc/grpc.dart';
import 'package:open_local_ui/services/protobufs/server.pbgrpc.dart';
import 'package:open_local_ui/utils/logger.dart';
import 'package:path/path.dart' as p;

class TTSService {
  static late ClientChannel _channel;
  static late TTSClient _stub;
  static late Process _process;

  TTSService._internal() {
    _channel = ClientChannel(
      'localhost',
      port: 50051,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );

    _stub = TTSClient(
      _channel,
      options: CallOptions(
        timeout: const Duration(seconds: 240),
      ),
    );
  }

  static final TTSService _instance = TTSService._internal();

  factory TTSService() {
    return _instance;
  }

  Future<List<int>> synthesize(
    String text, {
    int gender = 0,
    int age = 30,
  }) async {
    final request = TTSRequest()
      ..text = text
      ..gender = gender
      ..age = age;

    try {
      final response = await _stub.synthesize(request);

      return response.track;
    } catch (e) {
      logger.e(e);
    }

    return [];
  }

  static Future startServer() async {
    String executablePath = '';

    if (Platform.isWindows) {
      final directory = p.dirname(Platform.resolvedExecutable);
      executablePath = '$directory/server.exe';
    }

    try {
      Process.start(executablePath, ['']).then((Process process) {
        _process = process;

        logger.d('Program started with PID: ${process.pid}');

        process.stdout.transform(utf8.decoder).listen((data) {
          logger.t('stdout: $data');
        });

        process.stderr.transform(utf8.decoder).listen((data) {
          logger.e('stderr: $data');
        });

        process.exitCode.then((int code) {
          logger.d('Process exited with code $code');
        });
      });
    } catch (e) {
      logger.e(e);
    }
  }

  static Future stopServer() async {
    _process.kill();
    
    await _channel.shutdown();
  }
}
