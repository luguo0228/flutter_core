# 多环境命令封装（--dart-define-from-file 编译期注入）
# 环境配置见 env/{dev,test,prod}.json，缺省 env=dev
#
# 常用：
#   make run env=dev | make run env=test | make run env=prod
#   make run-dev / make run-test / make run-prod
#   make build env=prod platform=apk
#   make build-apk-prod / make build-ios-prod
#   make test / make analyze

env ?= dev
platform ?= apk
ENV_FILE := env/$(env).json

.PHONY: run run-dev run-test run-prod build build-apk-prod build-ios-prod test test-env analyze

## 以指定环境启动：make run env=dev
run:
	flutter run --dart-define-from-file=$(ENV_FILE)

run-dev:
	flutter run --dart-define-from-file=env/dev.json

run-test:
	flutter run --dart-define-from-file=env/test.json

run-prod:
	flutter run --dart-define-from-file=env/prod.json

## 以指定环境打 release 包：make build env=prod platform=apk|ios|appbundle
build:
	flutter build $(platform) --release --dart-define-from-file=$(ENV_FILE)

build-apk-prod:
	flutter build apk --release --dart-define-from-file=env/prod.json

build-ios-prod:
	flutter build ios --release --dart-define-from-file=env/prod.json

## 缺省态跑全部测试
test:
	flutter test

## 以指定环境跑测试：make test-env env=test
test-env:
	flutter test --dart-define-from-file=$(ENV_FILE)

analyze:
	flutter analyze
