import 'package:supabase_flutter/supabase_flutter.dart';

/// SupabaseUtilクラスは、Supabaseクライアントの初期化と管理を行うユーティリティクラスです。
class SupabaseUtil {
  /// Supabaseクライアントのインスタンスを保持する静的変数
  static SupabaseClient? _supabaseClient;

  /// Supabaseクライアントのゲッター
  /// 
  /// クライアントが未初期化の場合は初期化してから返します。
  static SupabaseClient get client {
    _supabaseClient ??= Supabase.instance.client;
    return _supabaseClient!;
  }

  /// Supabaseを初期化するメソッド
  /// 
  /// プロジェクトのURLとanon keyを使用してSupabaseを初期化します。
  /// 
  /// 返り値: 初期化されたSupabaseインスタンス
  static Future<Supabase> initialize() async {
    return await Supabase.initialize(
      // Project URLの値
      url: const String.fromEnvironment('supabaseUrl'),
      // Project API keysのanon keyの値
      anonKey: const String.fromEnvironment('supabaseAnonKey'),
    );
  }

  /// 指定されたパスの公開URLを取得するメソッド
  /// 
  /// @param path ストレージ内のファイルパス
  /// @return ファイルの公開URL
  static Future<String> getPublicUrl(String path) async {
    return SupabaseUtil.client.storage.from('tokyo_mania_images').getPublicUrl(path);
  }
}