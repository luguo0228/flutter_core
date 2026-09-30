import 'package:flutter_test/flutter_test.dart';

import 'package:base_template/env/env_config.dart';

/// 期望值同样经编译期注入（EXPECT_*，缺省即 dev 期望），使同一套测试在
/// 任意参数组合下自洽；参数态命令仅运行本文件：
///
/// ```bash
/// # 缺省态（TC-001 / TC-002）
/// flutter test
///
/// # TC-003 非法环境标识容错（env 保留原值，appEnv 回落 dev）
/// flutter test test/env_config_test.dart \
///   --dart-define=APP_ENV=staging \
///   --dart-define=EXPECT_ENV=staging --dart-define=EXPECT_APP_ENV=dev
///
/// # TC-004 test 环境整体注入
/// flutter test test/env_config_test.dart \
///   --dart-define-from-file=env/test.json \
///   --dart-define=EXPECT_ENV=test --dart-define=EXPECT_APP_ENV=test \
///   --dart-define=EXPECT_DEBUG_MODE=true \
///   --dart-define=EXPECT_API_BASE_URL=https://test-api.example.com
///
/// # TC-005 prod 注入与 isProd
/// flutter test test/env_config_test.dart \
///   --dart-define-from-file=env/prod.json \
///   --dart-define=EXPECT_ENV=prod --dart-define=EXPECT_APP_ENV=prod \
///   --dart-define=EXPECT_IS_PROD=true --dart-define=EXPECT_DEBUG_MODE=false \
///   --dart-define=EXPECT_API_BASE_URL=https://api.example.com
///
/// # TC-006 单键覆盖（CI 密钥注入模式）
/// flutter test test/env_config_test.dart \
///   --dart-define=API_BASE_URL=https://ci-override.example.com \
///   --dart-define=EXPECT_API_BASE_URL=https://ci-override.example.com
/// ```
const _kExpectEnv = String.fromEnvironment('EXPECT_ENV', defaultValue: 'dev');
const _kExpectAppEnv =
    String.fromEnvironment('EXPECT_APP_ENV', defaultValue: 'dev');
const _kExpectIsProd =
    bool.fromEnvironment('EXPECT_IS_PROD', defaultValue: false);
const _kExpectApiBaseUrl = String.fromEnvironment(
  'EXPECT_API_BASE_URL',
  defaultValue: 'https://dev-api.example.com',
);
const _kExpectDebugMode =
    bool.fromEnvironment('EXPECT_DEBUG_MODE', defaultValue: true);

void main() {
  group('EnvConfig 缺省防呆（TC-001 / TC-002）', () {
    test('TC-001 生效环境等于期望环境（缺省回落 dev，不回落 prod）', () {
      expect(EnvConfig.appEnv.name, _kExpectAppEnv);
      expect(EnvConfig.isProd, _kExpectIsProd);
    });

    test('TC-002 环境枚举解析', () {
      expect(EnvConfig.appEnv, AppEnv.values.byName(_kExpectAppEnv));
    });
  });

  group('EnvConfig 注入态（TC-003 ~ TC-006，按文件头命令分别运行）', () {
    test('TC-003 非法环境标识容错回落 dev', () {
      // env 保留注入原值；appEnv 恒为合法枚举，非法标识回落 dev。
      expect(EnvConfig.env, _kExpectEnv);
      final isLegal = AppEnv.values.any((e) => e.name == EnvConfig.env);
      if (!isLegal) {
        expect(EnvConfig.appEnv, AppEnv.dev, reason: '非法环境标识必须回落 dev');
      }
      expect(
          AppEnv.values.map((e) => e.name), contains(EnvConfig.appEnv.name));
    });

    test('TC-004 整体注入：当前环境与调试开关等于期望值', () {
      expect(EnvConfig.env, _kExpectEnv);
      expect(EnvConfig.debugMode, _kExpectDebugMode);
    });

    test('TC-005 prod 注入与 isProd 判断', () {
      expect(EnvConfig.isProd, _kExpectIsProd);
      expect(EnvConfig.appEnv == AppEnv.prod, _kExpectIsProd);
      expect(EnvConfig.debugMode, _kExpectDebugMode);
    });

    test('TC-006 单键覆盖：API_BASE_URL 可被独立注入', () {
      expect(EnvConfig.apiBaseUrl, _kExpectApiBaseUrl);
    });
  });
}
