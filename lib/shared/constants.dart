import 'package:flutter/material.dart';

/// 应用主题颜色
class AppColors {
  /// 主色调
  static const Color primary = Color(0xFF2196F3);
  
  /// 次要色调
  static const Color secondary = Color(0xFF03A9F4);
  
  /// 强调色
  static const Color accent = Color(0xFFFF4081);
  
  /// 背景色
  static const Color background = Color(0xFFF5F5F5);
  
  /// 表面色
  static const Color surface = Colors.white;
  
  /// 错误色
  static const Color error = Color(0xFFB00020);
  
  /// 成功色
  static const Color success = Color(0xFF4CAF50);
  
  /// 警告色
  static const Color warning = Color(0xFFFFC107);
  
  /// 信息色
  static const Color info = Color(0xFF2196F3);
  
  /// 禁用色
  static const Color disabled = Color(0xFFBDBDBD);
  
  /// 文本主色
  static const Color textPrimary = Color(0xFF212121);
  
  /// 文本次要色
  static const Color textSecondary = Color(0xFF757575);
  
  /// 分割线颜色
  static const Color divider = Color(0xFFBDBDBD);
}

/// 应用文字样式
class AppTextStyles {
  /// 标题1
  static const TextStyle h1 = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  /// 标题2
  static const TextStyle h2 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  /// 标题3
  static const TextStyle h3 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  /// 正文-大
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    color: AppColors.textPrimary,
  );
  
  /// 正文-中
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    color: AppColors.textPrimary,
  );
  
  /// 正文-小
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    color: AppColors.textSecondary,
  );
  
  /// 按钮文字
  static const TextStyle button = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
  );
  
  /// 标签文字
  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    color: AppColors.textSecondary,
  );
}

/// 应用尺寸常量
class AppDimensions {
  /// 页面边距
  static const double pageMargin = 16.0;
  
  /// 内容间距-小
  static const double spacingSmall = 8.0;
  
  /// 内容间距-中
  static const double spacingMedium = 16.0;
  
  /// 内容间距-大
  static const double spacingLarge = 24.0;
  
  /// 圆角半径-小
  static const double radiusSmall = 4.0;
  
  /// 圆角半径-中
  static const double radiusMedium = 8.0;
  
  /// 圆角半径-大
  static const double radiusLarge = 16.0;
  
  /// 卡片阴影
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}

/// API相关常量
class ApiConstants {
  /// API基础URL
  static const String baseUrl = 'https://api.vista.example.com';
  
  /// WebSocket URL
  static const String wsUrl = 'wss://api.vista.example.com/ws';
  
  /// API版本
  static const String apiVersion = 'v1';
  
  /// 超时时间（毫秒）
  static const int timeout = 10000;
  
  /// 重试次数
  static const int maxRetries = 3;
}

/// 应用配置常量
class AppConfig {
  /// 相机预览分辨率
  static const double cameraPreviewAspectRatio = 16 / 9;
  
  /// 最大帧率
  static const double maxFrameRate = 30.0;
  
  /// 语音识别超时时间（毫秒）
  static const int voiceRecognitionTimeout = 10000;
  
  /// 最大录音时长（毫秒）
  static const int maxRecordingDuration = 60000;
  
  /// 缓存过期时间（毫秒）
  static const int cacheExpiration = 24 * 60 * 60 * 1000; // 24小时
  
  /// 是否启用调试模式
  static const bool enableDebug = true;
}

/// 本地化文本常量
class AppStrings {
  /// 应用名称
  static const String appName = 'VISTA';
  
  /// 通用文本
  static const String loading = '加载中...';
  static const String error = '发生错误';
  static const String retry = '重试';
  static const String cancel = '取消';
  static const String confirm = '确认';
  static const String save = '保存';
  static const String delete = '删除';
  static const String edit = '编辑';
  static const String done = '完成';
  
  /// 功能模块文本
  static const String sceneUnderstanding = '场景理解';
  static const String textRecognition = '文字识别';
  static const String objectDetection = '物体检测';
  
  /// 错误提示文本
  static const String networkError = '网络连接失败，请检查网络设置';
  static const String serverError = '服务器错误，请稍后重试';
  static const String timeoutError = '请求超时，请重试';
  static const String unknownError = '未知错误，请重试';
  
  /// 权限相关文本
  static const String cameraPermission = '需要相机权限以进行场景分析';
  static const String microphonePermission = '需要麦克风权限以进行语音交互';
  static const String locationPermission = '需要位置权限以提供更好的服务';
}
