import 'dart:async';

/// 语音交互控制器接口
/// 定义了语音模块需要实现的基本功能，包括语音识别和语音合成
abstract class VoiceController {
  /// 初始化语音模块
  Future<void> initialize();

  /// 开始语音识别
  /// 返回识别到的文本
  Future<String> startRecognition();

  /// 停止语音识别
  Future<void> stopRecognition();

  /// 语音合成并播放
  /// [text] 需要转换为语音的文本
  /// [options] 语音合成的配置选项
  Future<void> speak(String text, {VoiceOptions? options});

  /// 停止当前正在播放的语音
  Future<void> stopSpeaking();

  /// 释放资源
  Future<void> dispose();
}

/// 语音配置选项
class VoiceOptions {
  /// 语音速率 (0.5-2.0)
  final double rate;
  
  /// 语音音调 (0.5-2.0)
  final double pitch;
  
  /// 音量 (0.0-1.0)
  final double volume;
  
  /// 语音语言
  final String language;

  const VoiceOptions({
    this.rate = 1.0,
    this.pitch = 1.0,
    this.volume = 1.0,
    this.language = 'zh-CN',
  });
}

/// 语音识别状态
enum VoiceRecognitionState {
  /// 未初始化
  uninitialized,
  
  /// 准备就绪
  ready,
  
  /// 正在识别
  recognizing,
  
  /// 识别完成
  finished,
  
  /// 发生错误
  error,
}

/// 语音合成状态
enum VoiceSynthesisState {
  /// 未初始化
  uninitialized,
  
  /// 准备就绪
  ready,
  
  /// 正在合成
  synthesizing,
  
  /// 正在播放
  playing,
  
  /// 播放完成
  finished,
  
  /// 发生错误
  error,
}
