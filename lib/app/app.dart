import 'package:flutter/material.dart';
import 'routes.dart';

/// VISTA应用的根组件
/// 负责初始化应用的全局配置，如主题、路由、本地化等
class VistaApp extends StatelessWidget {
  const VistaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VISTA',
      // TODO: 配置主题
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // 后续添加自定义主题配置
      ),
      // TODO: 配置路由
      onGenerateRoute: AppRouter.onGenerateRoute,
      // TODO: 配置本地化
      // TODO: 配置无障碍支持
    );
  }
}
