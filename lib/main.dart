import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() async {
  print('[APP] 应用开始启动');
  
  // 确保Flutter绑定初始化
  print('[APP] 初始化Flutter绑定...');
  WidgetsFlutterBinding.ensureInitialized();
  print('[APP] Flutter绑定初始化完成');

  // 运行应用，使用ProviderScope包装以支持Riverpod
  print('[APP] 正在启动应用...');
  runApp(
    const ProviderScope(
      child: VistaApp(),
    ),
  );
  print('[APP] 应用已成功启动');
}
