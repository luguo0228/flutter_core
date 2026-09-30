// 环境可视化 Widget 测试（TC-201 / TC-202）+ 计数器冒烟测试。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:base_template/env/env_config.dart';
import 'package:base_template/main.dart';

void main() {
  testWidgets('TC-201/202 首页标题展示应用名与环境标识，MaterialApp 标题绑定 appName',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // TC-201: 首页标题格式 {APP_NAME} ({env})，缺省态为 dev。
    expect(
      find.text('${EnvConfig.appName} (${EnvConfig.appEnv.name})'),
      findsOneWidget,
    );
    expect(find.text('Base模板-Dev (dev)'), findsOneWidget);

    // TC-202: MaterialApp.title 使用 EnvConfig.appName。
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, EnvConfig.appName);
    expect(app.title, 'Base模板-Dev');
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
