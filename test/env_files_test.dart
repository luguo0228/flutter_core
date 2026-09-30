import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// TC-101 ~ TC-104：环境配置文件结构与取值校验。
/// `flutter test` 运行时工作目录为包根（core/），直接以相对路径读取 env/*.json。
void main() {
  const envNames = ['dev', 'test', 'prod'];
  const requiredFields = [
    'APP_ENV',
    'APP_NAME',
    'API_BASE_URL',
    'CDN_BASE_URL',
    'DEBUG_MODE',
  ];

  Map<String, Object?> load(String name) {
    final file = File('env/$name.json');
    expect(file.existsSync(), isTrue, reason: '缺少 env/$name.json');
    return (jsonDecode(file.readAsStringSync()) as Map).cast<String, Object?>();
  }

  test('TC-101 三份 JSON 字段集合一致且含全部基线字段', () {
    final maps = {for (final n in envNames) n: load(n)};
    final first = maps.values.first.keys.toSet();
    for (final entry in maps.entries) {
      expect(entry.value.keys.toSet(), first,
          reason: '${entry.key}.json 字段集合与其他环境不一致');
    }
    for (final f in requiredFields) {
      expect(first.contains(f), isTrue, reason: '缺少基线字段 $f');
    }
  });

  test('TC-102 prod 调试开关关闭，dev/test 开启', () {
    expect(load('prod')['DEBUG_MODE'], isFalse);
    expect(load('dev')['DEBUG_MODE'], isTrue);
    expect(load('test')['DEBUG_MODE'], isTrue);
  });

  test('TC-103 字段类型与非空校验', () {
    const stringFields = ['APP_ENV', 'APP_NAME', 'API_BASE_URL', 'CDN_BASE_URL'];
    const urlFields = ['API_BASE_URL', 'CDN_BASE_URL'];
    for (final n in envNames) {
      final m = load(n);
      for (final key in stringFields) {
        final v = m[key];
        expect(v is String && v.trim().isNotEmpty, isTrue,
            reason: '$n.json 的 $key 必须为非空字符串');
      }
      for (final key in urlFields) {
        expect(m[key] as String, startsWith('https://'),
            reason: '$n.json 的 $key 必须为 https 地址');
      }
    }
  });

  test('TC-104 APP_ENV 与文件名一致且取值合法', () {
    for (final n in envNames) {
      expect(load(n)['APP_ENV'], n, reason: 'env/$n.json 的 APP_ENV 应为 "$n"');
    }
  });
}
