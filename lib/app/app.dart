import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes.dart';

/// VISTA应用的根组件
/// 负责初始化应用的全局配置，如主题、路由、本地化等
class VistaApp extends ConsumerWidget {
  const VistaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 设置应用方向为竖屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // 设置状态栏为透明
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    
    return MaterialApp(
      title: 'VISTA',
      debugShowCheckedModeBanner: false, // 移除调试标签
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark, // 使用深色主题，适合相机界面
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true, // 使用Material 3
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      // 配置无障碍支持
      supportedLocales: const [Locale('zh', 'CN')], // 支持中文
      locale: const Locale('zh', 'CN'), // 默认使用中文
    );
  }
}
