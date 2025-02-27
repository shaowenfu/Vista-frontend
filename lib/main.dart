import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 运行应用，使用ProviderScope包装以支持Riverpod
  runApp(
    const ProviderScope(
      child: VistaApp(),
    ),
  );
}
