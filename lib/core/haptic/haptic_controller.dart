import 'dart:async';

/// 触觉反馈控制器接口
/// 定义了触觉反馈模块需要实现的基本功能
abstract class HapticController {
  /// 初始化触觉反馈模块
  Future<void> initialize();

  /// 执行轻度触觉反馈
  /// 用于按钮点击等轻微交互
  Future<void> lightImpact();

  /// 执行中度触觉反馈
  /// 用于确认操作等中等强度交互
  Future<void> mediumImpact();

  /// 执行重度触觉反馈
  /// 用于警告或重要提示等强烈交互
  Future<void> heavyImpact();

  /// 执行自定义触觉反馈模式
  /// [pattern] 触觉反馈模式
  /// [intensity] 反馈强度 (0.0-1.0)
  Future<void> vibrate(HapticPattern pattern, {double intensity = 1.0});

  /// 停止当前触觉反馈
  Future<void> stop();

  /// 释放资源
  Future<void> dispose();
}

/// 触觉反馈模式
/// 定义了不同类型的触觉反馈模式
class HapticPattern {
  /// 振动持续时间（毫秒）列表
  final List<int> durations;
  
  /// 振动强度（0.0-1.0）列表，长度应与durations相同
  final List<double> intensities;
  
  /// 是否重复执行
  final bool repeat;

  HapticPattern({
    required this.durations,
    required this.intensities,
    this.repeat = false,
  }) {
    if (durations.length != intensities.length) {
      throw ArgumentError('持续时间列表和强度列表长度必须相同');
    }
  }

  /// 单次点击振动模式
  static final HapticPattern click = HapticPattern(
    durations: [50],
    intensities: [0.5],
  );

  /// 双击振动模式
  static final HapticPattern doubleClick = HapticPattern(
    durations: [50, 100, 50],
    intensities: [0.5, 0.0, 0.5],
  );

  /// 成功操作振动模式
  static final HapticPattern success = HapticPattern(
    durations: [50, 50, 100],
    intensities: [0.3, 0.6, 0.9],
  );

  /// 警告振动模式
  static final HapticPattern warning = HapticPattern(
    durations: [100, 50, 100],
    intensities: [0.9, 0.3, 0.9],
  );

  /// 错误振动模式
  static final HapticPattern error = HapticPattern(
    durations: [100, 50, 100, 50, 100],
    intensities: [1.0, 0.0, 1.0, 0.0, 1.0],
  );
}

/// 触觉反馈状态
enum HapticState {
  /// 未初始化
  uninitialized,
  
  /// 准备就绪
  ready,
  
  /// 正在执行
  active,
  
  /// 不支持
  unsupported,
  
  /// 发生错误
  error,
}
