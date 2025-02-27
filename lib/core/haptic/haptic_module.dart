import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

/// 触觉反馈提供者
/// 负责管理设备振动反馈
final hapticFeedbackProvider = Provider<HapticFeedbackService>((ref) {
  return HapticFeedbackService();
});

/// 触觉反馈服务
class HapticFeedbackService {
  /// 检查设备是否支持振动
  Future<bool> hasVibrator() async {
    return await Vibration.hasVibrator() ?? false;
  }
  
  /// 检查设备是否支持自定义振动模式
  Future<bool> hasCustomVibrationsSupport() async {
    return await Vibration.hasCustomVibrationsSupport() ?? false;
  }
  
  /// 执行简单振动
  Future<void> vibrate({int duration = 500}) async {
    if (await hasVibrator()) {
      Vibration.vibrate(duration: duration);
    }
  }
  
  /// 执行模式振动
  Future<void> vibratePattern(List<int> pattern) async {
    if (await hasVibrator()) {
      Vibration.vibrate(pattern: pattern);
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
    vibrate(duration: 100);
  }
  
  /// 错误振动
  Future<void> errorFeedback() async {
    vibratePattern([100, 100, 100, 100, 100]);
  }
  
  /// 警告振动
  Future<void> warningFeedback() async {
    vibratePattern([300, 100, 300]);
  }
  
  /// 成功振动
  Future<void> successFeedback() async {
    vibratePattern([100, 50, 100, 50, 300]);
  }
}
