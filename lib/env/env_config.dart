/// 应用运行环境枚举。
enum AppEnv { dev, test, prod }

/// 统一环境配置入口（--dart-define-from-file 编译期注入）。
///
/// 所有值来自编译期注入：`flutter run --dart-define-from-file=env/<env>.json`。
/// 默认值故意对齐 dev 环境，保证裸跑 `flutter run` 不会误连生产。
///
/// 业务代码必须经由本类读取配置，禁止直接调用 `String.fromEnvironment`
/// 等底层注入 API。
class EnvConfig {
  const EnvConfig._();

  /// 环境标识字符串："dev" / "test" / "prod"。
  static const String env =
      String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  /// 应用显示名称。
  static const String appName =
      String.fromEnvironment('APP_NAME', defaultValue: 'Base模板-Dev');

  /// 后端 API 基础地址。
  static const String apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://dev-api.example.com');

  /// 静态资源基础地址。
  static const String cdnBaseUrl = String.fromEnvironment(
      'CDN_BASE_URL',
      defaultValue: 'https://dev-cdn.example.com');

  /// 调试开关（日志 / 调试工具）。
  static const bool debugMode =
      bool.fromEnvironment('DEBUG_MODE', defaultValue: true);

  /// 当前环境枚举；未知标识容错回落 [AppEnv.dev]。
  static AppEnv get appEnv => AppEnv.values.firstWhere(
        (e) => e.name == env,
        orElse: () => AppEnv.dev,
      );

  /// 是否生产环境。
  static bool get isProd => appEnv == AppEnv.prod;
}
