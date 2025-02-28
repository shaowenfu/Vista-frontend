import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

/// 触觉反馈提供者
/// 负责管理设备振动反馈
final hapticFeedbackProvider = Provider<HapticFeedbackService>((ref) {
  print('[HapticModule] 初始化触觉反馈服务...');
  final service = HapticFeedbackService();
  print('[HapticModule] 触觉反馈服务初始化完成');
  return service;
});

/// 触觉反馈服务
class HapticFeedbackService {
  /// 检查设备是否支持振动
  Future<bool> hasVibrator() async {
    print('[HapticModule] 检查设备振动支持...');
    final result = await Vibration.hasVibrator() ?? false;
    print('[HapticModule] 设备振动支持: $result');
    return result;
  }
  
  /// 检查设备是否支持自定义振动模式
  Future<bool> hasCustomVibrationsSupport() async {
    print('[HapticModule] 检查自定义振动模式支持...');
    final result = await Vibration.hasCustomVibrationsSupport() ?? false;
    print('[HapticModule] 自定义振动模式支持: $result');
    return result;
  }
  
  /// 执行简单振动
  Future<void> vibrate({int duration = 500}) async {
    print('[HapticModule] 尝试执行简单振动，持续时间: $duration ms');
    
    if (await hasVibrator()) {
      print('[HapticModule] 设备支持振动，开始执行...');
      Vibration.vibrate(duration: duration);
    } else {
      print('[HapticModule] 设备不支持振动');
    }
  }
  
  /// 执行模式振动
  Future<void> vibratePattern(List<int> pattern) async {
    print('[HapticModule] 尝试执行模式振动，模式: $pattern');
    
    if (await hasVibrator()) {
      print('[HapticModule] 设备支持振动，开始执行模式振动...');
      Vibration.vibrate(pattern: pattern);
    } else {
      print('[HapticModule] 设备不支持振动');
    }
  }
  
  /// 停止振动
  Future<void> cancel() async {
    if (await hasVibrator()) {
      Vibration.cancel();
    }
  }
  
  /// 操作确认振动
  Future<void> confirmationFeedback() async {
    print('[HapticModule] 执行操作确认振动...');
    await vibrate(duration: 100);
  }
  
  /// 错误振动
  Future<void> errorFeedback() async {
    print('[HapticModule] 执行错误振动...');
    await vibratePattern([100, 100, 100, 100, 100]);
  }
  
  /// 警告振动
  Future<void> warningFeedback() async {
    print('[HapticModule] 执行警告振动...');
    await vibratePattern([300, 100, 300]);
  }
  
  /// 成功振动
  Future<void> successFeedback() async {
    print('[HapticModule] 执行成功振动...');
    await vibratePattern([100, 50, 100, 50, 300]);
  }
}
