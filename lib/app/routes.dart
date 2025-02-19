import 'package:flutter/material.dart';
import '../features/home/screens/home_screen.dart';
import '../features/scene/screens/scene_understanding_screen.dart';
import '../features/ocr/screens/text_recognition_screen.dart';
import '../features/object/screens/object_detection_screen.dart';

/// 应用路由配置类
/// 负责管理所有页面路由的注册和生成
class AppRouter {
  // 路由名称常量
  static const String home = '/';
  static const String sceneUnderstanding = '/scene';
  static const String textRecognition = '/ocr';
  static const String objectDetection = '/object';
  static const String settings = '/settings';

  /// 路由生成器
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    
    if (name == home) {
      return MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      );
    }
    
    if (name == sceneUnderstanding) {
      return MaterialPageRoute(
        builder: (_) => const SceneUnderstandingScreen(),
      );
    }
    
    if (name == textRecognition) {
      return MaterialPageRoute(
        builder: (_) => const TextRecognitionScreen(),
      );
    }
    
    if (name == objectDetection) {
      return MaterialPageRoute(
        builder: (_) => const ObjectDetectionScreen(),
      );
    }
    
    if (name == settings) {
      // TODO: 实现设置页面
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('设置页面 - 待实现')),
        ),
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
