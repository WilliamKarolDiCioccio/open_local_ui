import 'dart:io';

import 'package:feedback/feedback.dart';
import 'package:image/image.dart' as img;
import 'package:open_local_ui/core/logger.dart';
import 'package:open_local_ui/core/utils/github.dart';
import 'package:open_local_ui/src/rust/api/gpu.dart' as rust_gpu;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:system_info2/system_info2.dart';

/// A utility class for handling user feedback uploads to Supabase and GitHub.
class FeedbackUtils {
  static String _getDeviceInfo() {
    final bestGpu = rust_gpu.getBestGpu();

    return '''
- OS Name: ${SysInfo.operatingSystemName}
- Kernel Version: ${SysInfo.kernelVersion}
- OS Version: ${SysInfo.operatingSystemVersion}
- CPU: ${SysInfo.cores[0].name}
- CPU Cores: ${SysInfo.cores.length}
- System Memory: ${(SysInfo.getTotalPhysicalMemory() / (1024 * 1024)).round()}
- GPU: ${bestGpu?.deviceName}
- GPU Memory: ${bestGpu?.memoryMb}
''';
  }

  static Future<void> uploadFeedback(UserFeedback feedback) async {
    final supabase = Supabase.instance.client;

    final tempDir = await getTemporaryDirectory();
    final filename = DateTime.now().millisecondsSinceEpoch;

    final screenshotFile = File('${tempDir.path}/feedback-screenshot.temp.jpg');

    if (!await screenshotFile.exists()) {
      await screenshotFile.parent.create(recursive: true);
    }

    final pngImage = img.decodePng(feedback.screenshot);
    final resizedImage = img.copyResize(pngImage!, width: 1280);
    final jpgImage = img.encodeJpg(resizedImage);

    await screenshotFile.writeAsBytes(jpgImage);

    await supabase.storage
        .from('feedback')
        .upload('screenshots/$filename.jpg', screenshotFile);

    final screenshotUrl = supabase.storage
        .from('feedback')
        .getPublicUrl('screenshots/$filename.jpg');

    await supabase.storage
        .from('feedback')
        .upload('logs/$filename.txt', AppLogger().logFile!);

    final logUrl = supabase.storage
        .from('feedback')
        .getPublicUrl('logs/$filename.txt');

    appLogger.d('''
      Feedback attachment uploaded successfully!
      \n
      Screenshot: $screenshotUrl
      \n
      Log: $logUrl
      ''');

    final deviceInfo = _getDeviceInfo();

    await GitHubAPIUtils.createGitHubIssue(
      feedback.text,
      screenshotUrl,
      logUrl,
      deviceInfo,
    );

    await screenshotFile.delete();
  }
}
