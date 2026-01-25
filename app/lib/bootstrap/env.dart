import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
final class Env {
  @EnviedField(varName: 'GITHUB_PAT', obfuscate: true)
  static final String gitHubPat = _Env.gitHubPat;

  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static final String supabaseUrl = _Env.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static final String supabaseAnonKey = _Env.supabaseAnonKey;

  @EnviedField(varName: 'DEV_SUPABASE_URL', obfuscate: false)
  static const String devSupabaseUrl = _Env.devSupabaseUrl;

  @EnviedField(varName: 'DEV_SUPABASE_ANON_KEY', obfuscate: false)
  static const String devSupabaseAnonKey = _Env.devSupabaseAnonKey;

  @EnviedField(varName: 'DISCORD_CLIENT_ID', obfuscate: true)
  static final String discordClientId = _Env.discordClientId;

  @EnviedField(varName: 'VERSION', obfuscate: false)
  static const String version = _Env.version;

  @EnviedField(varName: 'BUILDNUMBER', obfuscate: false)
  static const String buildNumber = _Env.buildNumber;

  @EnviedField(varName: 'BUILDTAG', obfuscate: false)
  static const String buildTag = _Env.buildTag;
}
