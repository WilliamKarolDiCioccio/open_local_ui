import 'package:grpc/grpc.dart';
import 'package:open_local_ui/services/protobufs/server.pbgrpc.dart';
import 'package:open_local_ui/utils/logger.dart';

class TTSService {
  late ClientChannel _channel;
  late TTSClient _stub;

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

  Future<List<int>> synthesize(String text) async {
    try {
      final request = TTSRequest()..text = text;
      final response = await _stub.synthesize(request);
      return response.track;
    } catch (e) {
      logger.e(e);
    }

    return [];
  }

  Future<void> shutdown() async {
    await _channel.shutdown();
  }
}
