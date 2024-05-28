import 'package:grpc/grpc.dart';
import 'package:open_local_ui/services/protobufs/server.pbgrpc.dart';
import 'package:open_local_ui/utils/logger.dart';

class TTSService {
  late ClientChannel channel;
  late TTSClient stub;

  TTSService() {
    channel = ClientChannel(
      'localhost',
      port: 50051,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );

    stub = TTSClient(
      channel,
      options: CallOptions(
        timeout: const Duration(seconds: 30),
      ),
    );
  }

  Future<bool> synthesize(String text) async {
    try {
      final request = TTSRequest()..text = text;
      final response = await stub.synthesize(request);
      return response.finished;
    } catch (e) {
      logger.e(e);
    }

    return true;
  }

  void shutdown() async {
    await channel.shutdown();
  }
}
