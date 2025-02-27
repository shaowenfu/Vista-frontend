import 'package:flutter/material.dart';
import '../camera_screen.dart';

/// 应用路由配置类
/// 负责管理所有页面路由的注册和生成
class AppRouter {
  // 路由名称常量
  static const String camera = '/';

  /// 路由生成器
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name;

    if (name == camera) {
      return MaterialPageRoute(
        builder: (_) => const CameraScreen(),
      );
    }

    // 处理未知路由
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('错误')),
        body: Center(
          child: Text('未知路由: $name'),
        ),
      ),
    );
  }
}
