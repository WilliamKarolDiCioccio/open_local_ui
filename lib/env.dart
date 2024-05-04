import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
final class Env {
  @EnviedField(varName: 'GITHUB_TOKEN', obfuscate: true)
  static final String gitHubToken = _Env.gitHubToken;
}
