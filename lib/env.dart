import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
final class Env {
  @EnviedField(varName: 'GITHUB_FEEDBACK_PAT', obfuscate: true)
  static final String gitHubFeedbackPat = _Env.gitHubFeedbackPat;

  @EnviedField(varName: 'GITHUB_COLLABORATORS_PAT', obfuscate: true)
  static final String gitHubCollaboratorsPat = _Env.gitHubCollaboratorsPat;  

  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static final String supabaseUrl = _Env.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static final String supabaseAnonKey = _Env.supabaseAnonKey;
}
