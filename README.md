# base_template

A new Flutter project.

## 多环境配置（dev / test / prod）

环境配置集中在 `env/` 目录（`dev.json` / `test.json` / `prod.json`），通过 `--dart-define-from-file` 在编译期注入，由 `lib/env/env_config.dart` 的 `EnvConfig` 统一读取。零第三方依赖，全平台（Android / iOS / ohos / Web / 桌面）行为一致。

> 缺省防呆：不带参数的 `flutter run` 默认回落 dev 环境，不会误连生产。

### 常用命令（Makefile）

| 命令 | 说明 |
|---|---|
| `make run-dev`、`make run env=dev` | 以 dev 环境启动 |
| `make run-test`、`make run env=test` | 以 test 环境启动 |
| `make run-prod` | 以 prod 配置启动（debug 模式连接生产 API，谨慎使用） |
| `make build env=prod platform=apk` | 以 prod 配置打 release 包（platform 可为 apk / ios / appbundle） |
| `make build-apk-prod` / `make build-ios-prod` | 快捷打包 |
| `make test` / `make test-env env=test` | 运行测试（缺省 / 指定环境） |

### 原生命令

```bash
flutter run --dart-define-from-file=env/dev.json          # 开发环境
flutter run --dart-define-from-file=env/test.json         # 测试环境
flutter run --dart-define-from-file=env/prod.json         # 生产配置
flutter build apk --release --dart-define-from-file=env/prod.json
```

### IDE 启动

- **VSCode**：调试面板下拉选择 `dev` / `test` / `prod` 配置（见 `.vscode/launch.json`），支持断点调试
- **Android Studio / IntelliJ**：Run → Edit Configurations → Flutter 配置的 *Additional run args* 填入 `--dart-define-from-file=env/dev.json`，按环境复制三份

### 约定与注意事项

- 业务代码只从 `EnvConfig` 取值（如 `EnvConfig.apiBaseUrl`、`EnvConfig.isProd`），禁止直接调用 `String.fromEnvironment`
- 切换环境需重新编译，不支持热重载切换
- `env/*.json` 只放占位配置；真实密钥由 CI 经 `--dart-define=KEY=value` 追加注入（dart-define 值会编译进产物，勿放机密）
- 三份 JSON 必须保持字段集合一致（由 `test/env_files_test.dart` 自动校验）

### 配置字段

| 字段 | 说明 |
|---|---|
| `APP_ENV` | 环境标识：dev / test / prod |
| `APP_NAME` | 应用显示名称 |
| `API_BASE_URL` | 后端 API 基础地址 |
| `CDN_BASE_URL` | 静态资源基础地址 |
| `DEBUG_MODE` | 调试开关（prod 恒为 false） |

## Getting Started

This project is a starting point for a Flutter application.

A few resources for getting you started with Flutter development:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
