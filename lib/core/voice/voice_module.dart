import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// 语音合成提供者
/// 负责文本到语音的转换
final ttsProvider = Provider<FlutterTts>((ref) {
  final tts = FlutterTts();
  
  // 配置TTS
  tts.setLanguage('zh-CN'); // 设置语言为中文
  tts.setSpeechRate(0.5);   // 设置语速
  tts.setVolume(1.0);       // 设置音量
  tts.setPitch(1.0);        // 设置音调
  
  // 当提供者被销毁时释放资源
  ref.onDispose(() {
    tts.stop();
  });
  
  return tts;
});

/// 语音识别提供者
/// 负责语音到文本的转换
final sttProvider = Provider<SpeechToTextService>((ref) {
  return SpeechToTextService();
});

/// 语音识别服务
class SpeechToTextService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  
  /// 初始化语音识别
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    _isInitialized = await _speech.initialize(
      onError: (error) => print('语音识别错误: $error'),
      onStatus: (status) => print('语音识别状态: $status'),
    );
    
    return _isInitialized;
  }
  
  /// 开始监听语音
  Future<void> startListening({
    required Function(String text) onResult,
    String? locale,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }
    
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      localeId: locale ?? 'zh-CN',
      listenMode: stt.ListenMode.confirmation,
      cancelOnError: true,
      partialResults: false,
    );
  }
  
  /// 停止监听
  Future<void> stopListening() async {
    await _speech.stop();
  }
  
  /// 检查是否正在监听
  bool get isListening => _speech.isListening;
  
  /// 检查是否可用
  bool get isAvailable => _isInitialized;
}

/// 语音命令处理提供者
/// 负责解析和处理语音命令
final voiceCommandProvider = Provider<VoiceCommandService>((ref) {
  return VoiceCommandService(ref);
});

/// 语音命令服务
class VoiceCommandService {
  final ProviderRef _ref;
  
  VoiceCommandService(this._ref);
  
  /// 处理语音命令
  Future<void> processCommand(String command) async {
    final tts = _ref.read(ttsProvider);
    
    // 简单的命令匹配逻辑
    if (command.contains('场景分析') || command.contains('分析场景')) {
      await tts.speak('已切换到场景分析模式');
      // TODO: 切换到场景分析模式
    } else if (command.contains('文字识别') || command.contains('识别文字')) {
      await tts.speak('已切换到文字识别模式');
      // TODO: 切换到文字识别模式
    } else if (command.contains('物体检测') || command.contains('检测物体')) {
      await tts.speak('已切换到物体检测模式');
      // TODO: 切换到物体检测模式
    } else {
      await tts.speak('未识别的命令，请重试');
    }
  }
  
  /// 播放语音提示
  Future<void> speak(String text) async {
    final tts = _ref.read(ttsProvider);
    await tts.speak(text);
  }
}
