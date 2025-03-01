import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:porcupine_flutter/porcupine_error.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../communication/api_client.dart';
import 'voice_module.dart';

/// 持续语音监听服务提供者
final continuousVoiceServiceProvider = Provider<ContinuousVoiceService>((ref) {
  return ContinuousVoiceService(ref);
});

/// 持续语音监听状态提供者
final continuousVoiceStateProvider = StateProvider<ContinuousVoiceState>((ref) {
  return ContinuousVoiceState.idle;
});

/// 持续语音监听开关提供者
final continuousVoiceEnabledProvider = StateProvider<bool>((ref) {
  return false;
});

/// 语音监听状态枚举
enum ContinuousVoiceState {
  idle,           // 空闲状态
  listening,      // 正在监听（等待唤醒词）
  recording,      // 正在录音（已检测到语音）
  processing,     // 正在处理录音
}

/// 持续语音监听服务
class ContinuousVoiceService {
  final Ref _ref;
  final _logger = Logger('ContinuousVoiceService');
  
  // 录音相关
  late FlutterSoundRecorder _recorder;
  String? _recordingPath;
  bool _isRecorderInitialized = false;
  
  // 唤醒词检测相关
  PorcupineManager? _porcupineManager;
  bool _isWakeWordDetectionActive = false;
  
  // 语音活动检测相关
  Timer? _silenceTimer;
  DateTime? _lastVoiceActivityTime;
  static const int _silenceThresholdMs = 2000; // 2秒无声自动停止录音
  
  // 状态控制
  StreamSubscription? _recorderSubscription;
  bool _isProcessing = false;
  
  ContinuousVoiceService(this._ref) {
    _recorder = FlutterSoundRecorder();
  }
  
  /// 初始化服务
  Future<void> initialize() async {
    if (_isRecorderInitialized) return;
    
    try {
      await _recorder.openRecorder();
      _isRecorderInitialized = true;
      _logger.info('录音器初始化成功');
    } catch (e) {
      _logger.severe('录音器初始化失败: $e');
      rethrow;
    }
  }
  
  /// 启动持续监听
  Future<void> startContinuousListening() async {
    if (!_isRecorderInitialized) {
      await initialize();
    }
    
    if (_isWakeWordDetectionActive) {
      _logger.info('唤醒词检测已经在运行中');
      return;
    }
    
    try {
      // 更新状态
      _ref.read(continuousVoiceStateProvider.notifier).state = ContinuousVoiceState.listening;
      
      // 初始化唤醒词检测
      await _initializeWakeWordDetection();
      
      _logger.info('持续语音监听已启动');
    } catch (e) {
      _logger.severe('启动持续监听失败: $e');
      _ref.read(continuousVoiceStateProvider.notifier).state = ContinuousVoiceState.idle;
      rethrow;
    }
  }
  
  /// 停止持续监听
  Future<void> stopContinuousListening() async {
    try {
      // 停止唤醒词检测
      await _stopWakeWordDetection();
      
      // 如果正在录音，停止录音
      if (_recorder.isRecording) {
        await stopRecording();
      }
      
      // 更新状态
      _ref.read(continuousVoiceStateProvider.notifier).state = ContinuousVoiceState.idle;
      
      _logger.info('持续语音监听已停止');
    } catch (e) {
      _logger.severe('停止持续监听失败: $e');
      rethrow;
    }
  }
  
  /// 初始化唤醒词检测
  Future<void> _initializeWakeWordDetection() async {
    try {
      // 创建唤醒词检测管理器
      // 使用自定义唤醒词
      _porcupineManager = await PorcupineManager.fromKeywordPaths(
        "YOUR_PORCUPINE_ACCESS_KEY", // 替换为实际的访问密钥
        ["assets/wake_words/hey_vista_zh.ppn"], // 唤醒词模型文件路径
        _onWakeWordDetected, // 唤醒词检测回调
        errorCallback: (PorcupineException error) {
          _logger.severe('唤醒词检测错误: ${error.message}');
        },
      );
      
      // 启动唤醒词检测
      await _porcupineManager?.start();
      _isWakeWordDetectionActive = true;
      
      _logger.info('唤醒词检测已启动');
    } catch (e) {
      _logger.severe('初始化唤醒词检测失败: $e');
      rethrow;
    }
  }
  
  /// 停止唤醒词检测
  Future<void> _stopWakeWordDetection() async {
    try {
      if (_porcupineManager != null) {
        await _porcupineManager?.stop();
        await _porcupineManager?.delete();
        _porcupineManager = null;
        _isWakeWordDetectionActive = false;
        _logger.info('唤醒词检测已停止');
      }
    } catch (e) {
      _logger.severe('停止唤醒词检测失败: $e');
      rethrow;
    }
  }
  
  /// 唤醒词检测回调
  void _onWakeWordDetected(int keywordIndex) {
    _logger.info('检测到唤醒词，索引: $keywordIndex');
    
    // 播放提示音
    final voiceService = _ref.read(voiceCommandProvider);
    voiceService.speak('我在听');
    
    // 开始录音
    startRecording();
  }
  
  /// 开始录音
  Future<void> startRecording() async {
    if (_recorder.isRecording) {
      _logger.info('录音已经在进行中');
      return;
    }
    
    try {
      // 创建临时文件路径
      final tempDir = await getTemporaryDirectory();
      _recordingPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      // 更新状态
      _ref.read(continuousVoiceStateProvider.notifier).state = ContinuousVoiceState.recording;
      
      // 开始录音
      await _recorder.startRecorder(
        toFile: _recordingPath,
        codec: Codec.pcm16WAV,
      );
      
      // 监听录音电平，用于检测语音活动
      _recorderSubscription = _recorder.onProgress?.listen((event) {
        if (event.decibels != null && event.decibels! > -50) { // 调整阈值以适应环境
          _lastVoiceActivityTime = DateTime.now();
        }
        
        // 检查是否有足够长的静音
        _checkSilence();
      });
      
      // 初始化语音活动时间
      _lastVoiceActivityTime = DateTime.now();
      
      // 启动静音检测定时器
      _silenceTimer = Timer.periodic(Duration(milliseconds: 500), (_) {
        _checkSilence();
      });
      
      _logger.info('录音已开始: $_recordingPath');
    } catch (e) {
      _logger.severe('开始录音失败: $e');
      _ref.read(continuousVoiceStateProvider.notifier).state = ContinuousVoiceState.listening;
      rethrow;
    }
  }
  
  /// 检查静音
  void _checkSilence() {
    if (_lastVoiceActivityTime == null || !_recorder.isRecording) return;
    
    final now = DateTime.now();
    final silenceDuration = now.difference(_lastVoiceActivityTime!).inMilliseconds;
    
    if (silenceDuration > _silenceThresholdMs) {
      _logger.info('检测到${_silenceThresholdMs}ms静音，自动停止录音');
      stopRecording();
    }
  }
  
  /// 停止录音
  Future<void> stopRecording() async {
    if (!_recorder.isRecording) {
      _logger.info('没有正在进行的录音');
      return;
    }
    
    try {
      // 取消静音检测定时器
      _silenceTimer?.cancel();
      _silenceTimer = null;
      
      // 取消录音监听
      await _recorderSubscription?.cancel();
      _recorderSubscription = null;
      
      // 停止录音
      final recordingResult = await _recorder.stopRecorder();
      
      // 更新状态
      _ref.read(continuousVoiceStateProvider.notifier).state = ContinuousVoiceState.processing;
      
      _logger.info('录音已停止: $recordingResult');
      
      // 处理录音
      if (recordingResult != null) {
        await _processRecording(recordingResult);
      }
      
      // 恢复到监听状态
      if (_ref.read(continuousVoiceEnabledProvider)) {
        _ref.read(continuousVoiceStateProvider.notifier).state = ContinuousVoiceState.listening;
      } else {
        _ref.read(continuousVoiceStateProvider.notifier).state = ContinuousVoiceState.idle;
      }
    } catch (e) {
      _logger.severe('停止录音失败: $e');
      _ref.read(continuousVoiceStateProvider.notifier).state = ContinuousVoiceState.idle;
      rethrow;
    }
  }
  
  /// 处理录音
  Future<void> _processRecording(String filePath) async {
    if (_isProcessing) {
      _logger.info('已有录音正在处理中');
      return;
    }
    
    _isProcessing = true;
    
    try {
      // 读取录音文件
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('录音文件不存在: $filePath');
      }
      
      final audioBytes = await file.readAsBytes();
      
      // 发送到后端
      await _sendAudioToBackend(audioBytes);
      
      // 清理临时文件
      await file.delete();
      _logger.info('录音文件已删除: $filePath');
    } catch (e) {
      _logger.severe('处理录音失败: $e');
    } finally {
      _isProcessing = false;
    }
  }
  
  /// 发送录音到后端
  Future<void> _sendAudioToBackend(Uint8List audioBytes) async {
    try {
      // 使用API客户端发送录音
      final apiClient = _ref.read(apiClientProvider);
      final result = await apiClient.recognizeVoice(audioBytes);
      
      _logger.info('语音识别结果: $result');
      
      // 处理识别结果
      if (result['success'] == true && result['data'] != null) {
        final text = result['data']['text'];
        final command = result['data']['command'];
        
        // 处理命令
        if (command != null) {
          await _processCommand(command);
        }
        
        // 播放识别结果
        final voiceService = _ref.read(voiceCommandProvider);
        await voiceService.speak('我听到了: $text');
      } else if (result['error'] != null) {
        _logger.warning('语音识别错误: ${result['error']}');
        
        // 播放错误提示
        final voiceService = _ref.read(voiceCommandProvider);
        await voiceService.speak('抱歉，我没有听清楚');
      }
    } catch (e) {
      _logger.severe('发送录音到后端失败: $e');
      
      // 播放错误提示
      final voiceService = _ref.read(voiceCommandProvider);
      await voiceService.speak('抱歉，处理您的语音时出现了问题');
    }
  }
  
  /// 处理命令
  Future<void> _processCommand(Map<String, dynamic> command) async {
    final commandType = command['type'];
    final action = command['action'];
    final parameters = command['parameters'];
    
    _logger.info('处理命令: $commandType, $action, $parameters');
    
    // 根据命令类型和操作执行相应的功能
    // 这里需要根据实际需求实现
    final voiceService = _ref.read(voiceCommandProvider);
    await voiceService.processCommand('$commandType $action');
  }
  
  /// 释放资源
  Future<void> dispose() async {
    try {
      await stopContinuousListening();
      
      if (_isRecorderInitialized) {
        await _recorder.closeRecorder();
        _isRecorderInitialized = false;
      }
      
      _logger.info('持续语音监听服务已释放');
    } catch (e) {
      _logger.severe('释放持续语音监听服务失败: $e');
    }
  }
}
