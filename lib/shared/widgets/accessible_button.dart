import 'package:flutter/material.dart';
import '../../core/haptic/haptic_controller.dart';
import '../../core/voice/voice_controller.dart';

/// 无障碍按钮组件
/// 提供触觉反馈和语音提示的可访问按钮
class AccessibleButton extends StatelessWidget {
  /// 按钮文本标签
  final String label;
  
  /// 按钮点击回调
  final VoidCallback onPressed;
  
  /// 触觉反馈模式
  final HapticPattern? hapticPattern;
  
  /// 语音提示文本（为空则使用label）
  final String? voicePrompt;
  
  /// 按钮图标
  final IconData? icon;
  
  /// 按钮大小
  final Size? size;
  
  /// 按钮颜色
  final Color? color;
  
  /// 是否启用触觉反馈
  final bool enableHaptic;
  
  /// 是否启用语音提示
  final bool enableVoice;

  const AccessibleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.hapticPattern,
    this.voicePrompt,
    this.icon,
    this.size,
    this.color,
    this.enableHaptic = true,
    this.enableVoice = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      enabled: true,
      child: GestureDetector(
        onTap: _handlePress,
        child: Container(
          width: size?.width,
          height: size?.height,
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          decoration: BoxDecoration(
            color: color ?? Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24.0,
                ),
                const SizedBox(width: 8.0),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 处理按钮点击事件
  void _handlePress() async {
    // TODO: 获取HapticController实例
    if (enableHaptic && hapticPattern != null) {
      // 执行触觉反馈
      // await hapticController.vibrate(hapticPattern!);
    }

    // TODO: 获取VoiceController实例
    if (enableVoice) {
      final prompt = voicePrompt ?? label;
      // 播放语音提示
      // await voiceController.speak(prompt);
    }

    // 执行点击回调
    onPressed();
  }
}

/// 无障碍图标按钮组件
/// 提供触觉反馈和语音提示的可访问图标按钮
class AccessibleIconButton extends AccessibleButton {
  const AccessibleIconButton({
    super.key,
    required super.label,
    required super.onPressed,
    required IconData icon,
    super.hapticPattern,
    super.voicePrompt,
    super.size = const Size(48.0, 48.0),
    super.color,
    super.enableHaptic = true,
    super.enableVoice = true,
  }) : super(icon: icon);
}

/// 无障碍浮动操作按钮组件
/// 提供触觉反馈和语音提示的可访问FAB
class AccessibleFloatingActionButton extends StatelessWidget {
  /// 按钮文本标签
  final String label;
  
  /// 按钮点击回调
  final VoidCallback onPressed;
  
  /// 按钮图标
  final IconData icon;
  
  /// 触觉反馈模式
  final HapticPattern? hapticPattern;
  
  /// 语音提示文本（为空则使用label）
  final String? voicePrompt;
  
  /// 按钮颜色
  final Color? backgroundColor;
  
  /// 是否启用触觉反馈
  final bool enableHaptic;
  
  /// 是否启用语音提示
  final bool enableVoice;
  
  /// 是否为小尺寸
  final bool mini;

  const AccessibleFloatingActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.icon,
    this.hapticPattern,
    this.voicePrompt,
    this.backgroundColor,
    this.enableHaptic = true,
    this.enableVoice = true,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      enabled: true,
      child: FloatingActionButton(
        onPressed: _handlePress,
        mini: mini,
        backgroundColor: backgroundColor,
        child: Icon(icon),
      ),
    );
  }

  /// 处理按钮点击事件
  void _handlePress() async {
    // TODO: 获取HapticController实例
    if (enableHaptic && hapticPattern != null) {
      // 执行触觉反馈
      // await hapticController.vibrate(hapticPattern!);
    }

    // TODO: 获取VoiceController实例
    if (enableVoice) {
      final prompt = voicePrompt ?? label;
      // 播放语音提示
      // await voiceController.speak(prompt);
    }

    // 执行点击回调
    onPressed();
  }
}
