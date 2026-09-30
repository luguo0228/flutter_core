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

## Android 自动构建（GitHub Actions）

仓库根 `.github/workflows/android-release.yml` 提供 Android 端自动构建与发布，产出 release 签名的 APK 与 AAB。

> 注意：仓库主托管在 Gitee（默认分支 `master`），而 GitHub Actions 只在 GitHub 上运行。需先把仓库镜像/同步推送到 GitHub，Secrets 也配在 GitHub 侧，否则工作流不会触发。

### 触发规则

| 事件 | 行为 |
|---|---|
| PR → `master` | 仅静态检查（`flutter analyze`）与单测（`flutter test`），不出包、不注入密钥 |
| push → `master` | 检查通过后构建 APK + AAB，作为 artifact 保留 30 天 |
| push tag `v*` | 在上一行基础上自动创建 GitHub Release 并挂载产物 |
| 手动触发 | 可选环境 `env`（prod / test / dev，默认 prod）与格式 `format`（both / apk / appbundle） |

### 需要配置的 Secrets

| Secret | 说明 |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `upload-keystore.jks` 的 base64 编码 |
| `ANDROID_KEYSTORE_PASSWORD` | keystore 密码 |
| `ANDROID_KEY_ALIAS` | 密钥别名 |
| `ANDROID_KEY_PASSWORD` | 密钥密码 |

```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload

base64 -i upload-keystore.jks | gh secret set ANDROID_KEYSTORE_BASE64
gh secret set ANDROID_KEYSTORE_PASSWORD
gh secret set ANDROID_KEY_ALIAS
gh secret set ANDROID_KEY_PASSWORD
```

未配置 Secrets 时构建不会失败，会自动回退 debug 签名（仅用于跑通流水线，产物不可上架）。

### 本地打包签名

在 `android/key.properties` 写入以下内容即可让 release 包使用正式签名（该文件已被 gitignore，切勿提交）：

```properties
storeFile=/绝对路径/upload-keystore.jks
storePassword=******
keyAlias=upload
keyPassword=******
```

### 产物路径

| 格式 | 构建输出 | artifact 命名 |
|---|---|---|
| APK | `build/app/outputs/flutter-apk/app-release.apk` | `base-template-<env>-<version>.apk` |
| AAB | `build/app/outputs/bundle/release/app-release.aab` | `base-template-<env>-<version>.aab` |

版本号来源：tag 构建取 tag 名（去 `v` 前缀）作为 `versionName`，其余取 `pubspec.yaml` 的 `version`；`versionCode` 取 `+N`，缺省时用流水线运行号。

> CI 使用的 Flutter 版本由 `.flutter-version` 锁定，升级 Flutter 时需同步修改该文件。

## Getting Started

This project is a starting point for a Flutter application.

A few resources for getting you started with Flutter development:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
