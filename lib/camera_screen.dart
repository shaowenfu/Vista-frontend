import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/camera/camera_controller_provider.dart';
import 'core/voice/voice_module.dart';
import 'core/voice/continuous_voice_service.dart';
import 'core/haptic/haptic_module.dart';
import 'core/communication/api_client.dart';
import 'features/scene/services/scene_analysis_service.dart';

// Declare required permissions for audio recording
final recorderPermissions = [
  Permission.microphone,
  Permission.storage,
];

/// 分析模式枚举
enum AnalysisMode {
  scene,           // 场景分析
  ocr,             // 文字识别
  objectDetection, // 物体检测
}

/// 相机页面
/// 用户打开应用后直接进入此页面，所有交互通过语音指令和触觉反馈完成
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> with WidgetsBindingObserver {
  bool _hasPermission = false;
  late FlutterSoundRecorder _audioRecorder;
  Timer? _analysisTimer;
  AnalysisMode _currentMode = AnalysisMode.scene;
  bool _isRecording = false;
  String? _audioFilePath;
  bool _isContinuousListeningEnabled = false;
  
  @override
  void initState() {
    super.initState();
    _audioRecorder = FlutterSoundRecorder();
    WidgetsBinding.instance.addObserver(this);
    _initAudioRecorder(); // 初始化录音器
    _requestPermissions();
    
    // 监听持续语音监听状态变化
    ref.listen(continuousVoiceStateProvider, (previous, next) {
      setState(() {
        // 更新UI以反映当前状态
      });
    });
    
    // 监听持续语音监听开关变化
    ref.listen(continuousVoiceEnabledProvider, (previous, next) {
      setState(() {
        _isContinuousListeningEnabled = next;
      });
      
      // 根据开关状态启动或停止持续监听
      _handleContinuousListeningToggle(next);
    });
  }
  
  /// 处理持续语音监听开关变化
  void _handleContinuousListeningToggle(bool enabled) async {
    final continuousVoiceService = ref.read(continuousVoiceServiceProvider);
    
    if (enabled) {
      // 启动持续语音监听
      await continuousVoiceService.startContinuousListening();
      
      // 播放提示音
      final voiceService = ref.read(voiceCommandProvider);
      voiceService.speak('持续语音监听已启动');
    } else {
      // 停止持续语音监听
      await continuousVoiceService.stopContinuousListening();
      
      // 播放提示音
      final voiceService = ref.read(voiceCommandProvider);
      voiceService.speak('持续语音监听已停止');
    }
  }
  
  Timer? _permissionTimer;
  
  Future<void> _requestPermissions() async {
    await _checkAndRequestPermissions();
    final audioStatus = await _checkAndRequestAudioPermissions();
    
    if (!_hasPermission) {
      _permissionTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
        await _checkAndRequestPermissions();
        if (_hasPermission) {
          _permissionTimer?.cancel();
        }
      });
    }
  }
  
  Future<void> _checkAndRequestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();
    final hasPermission = cameraStatus.isGranted && microphoneStatus.isGranted;
    setState(() {
      _hasPermission = hasPermission;
    });
    if (_hasPermission) {
      _startFrameHadleTimer();
    } else {
      final voiceService = ref.read(voiceCommandProvider);
      voiceService.speak('请授予相机和麦克风权限，以便应用正常工作');
    }
  }
  
  Future<bool> _checkAndRequestAudioPermissions() async {
    var status = await recorderPermissions.request();
    final hasPermission = status.entries.every((entry) => entry.value.isGranted);
    if (!hasPermission) {
      final voiceService = ref.read(voiceCommandProvider);
      voiceService.speak('请授予录音权限，以便使用语音命令功能');
    }
    return hasPermission;
  }
  
  Future<void> _initAudioRecorder() async {
    try {
      await _audioRecorder.openRecorder();
    } catch (e) {
      print('[CameraScreen] 音频录制器初始化失败: $e');
    }
  }
  
  Future<void> _disposeAudioRecorder() async {
    try {
      await _audioRecorder.closeRecorder();
    } catch (e) {
      print('[CameraScreen] 音频录制器清理失败: $e');
    }
  }
  
  void _startFrameHadleTimer() {
    _analysisTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _analyzeCurrentFrame();
    });
  }
  
  void _stopAnalysisTimer() {
    _analysisTimer?.cancel();
  }
  
  Future<void> _analyzeCurrentFrame() async {
    final cameraController = ref.read(cameraControllerProvider).valueOrNull;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    
    try {
      final image = await cameraController.takePicture();
      final imageBytes = await image.readAsBytes();
      
      switch (_currentMode) {
        case AnalysisMode.scene:
          await _analyzeScene(imageBytes);
          break;
        default:
          break;
      }
    } catch (e) {
      print('[CameraScreen] 分析当前帧错误: $e');
    }
  }
  
  Future<void> _analyzeScene(List<int> imageBytes) async {
    final sceneService = ref.read(sceneAnalysisServiceProvider);
    final result = await sceneService.analyzeScene(Uint8List.fromList(imageBytes));
    
    if (!result.error) {
      final hapticService = ref.read(hapticFeedbackProvider);
      await hapticService.successFeedback();
    }
  }
  
  Timer? _longPressTimer;
  
  Future<void> _startRecording() async {
    try {
      final tempDir = Directory.systemTemp;
      _audioFilePath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _audioRecorder.startRecorder(
        toFile: _audioFilePath,
        codec: Codec.aacADTS,
      );
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('[CameraScreen] 录音启动失败: $e');
    }
  }
  
  Future<void> _stopRecording() async {
    try {
      final result = await _audioRecorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });
      if (result != null) {
        _sendAudioToBackend(result);
      }
    } catch (e) {
      print('[CameraScreen] 录音停止失败: $e');
    }
  }
  
  void _sendAudioToBackend(String filePath) async {
    try {
      // 读取录音文件
      final file = File(filePath);
      if (!await file.exists()) {
        print('[CameraScreen] 录音文件不存在: $filePath');
        return;
      }
      
      final audioBytes = await file.readAsBytes();
      
      // 使用API客户端发送录音
      final apiClient = ref.read(apiClientProvider);
      final result = await apiClient.recognizeVoice(audioBytes);
      
      print('[CameraScreen] 语音识别结果: $result');
      
      // 处理识别结果
      if (result['success'] == true && result['data'] != null) {
        final text = result['data']['text'];
        final command = result['data']['command'];
        
        // 处理命令
        if (command != null) {
          _processCommand(command);
        }
        
        // 播放识别结果
        final voiceService = ref.read(voiceCommandProvider);
        await voiceService.speak('我听到了: $text');
      }
      
      // 清理临时文件
      await file.delete();
    } catch (e) {
      print('[CameraScreen] 发送录音到后端失败: $e');
    }
  }
  
  void _processCommand(Map<String, dynamic> command) {
    final commandType = command['type'];
    final action = command['action'];
    
    print('[CameraScreen] 处理命令: $commandType, $action');
    
    // 根据命令类型和操作执行相应的功能
    if (commandType == 'SYSTEM' && action == 'TOGGLE_CONTINUOUS_LISTENING') {
      // 切换持续语音监听
      final newState = !_isContinuousListeningEnabled;
      ref.read(continuousVoiceEnabledProvider.notifier).state = newState;
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopAnalysisTimer();
    _permissionTimer?.cancel();
    _disposeAudioRecorder();
    
    // 停止持续语音监听
    if (_isContinuousListeningEnabled) {
      final continuousVoiceService = ref.read(continuousVoiceServiceProvider);
      continuousVoiceService.stopContinuousListening();
    }
    
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopAnalysisTimer();
      if (_isRecording) {
        _stopRecording();
      }
    } else if (state == AppLifecycleState.resumed) {
      _startFrameHadleTimer();
      
      // 如果持续监听已启用，恢复持续监听
      if (_isContinuousListeningEnabled) {
        final continuousVoiceService = ref.read(continuousVoiceServiceProvider);
        continuousVoiceService.startContinuousListening();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前持续语音监听状态
    final continuousVoiceState = ref.watch(continuousVoiceStateProvider);
    
    return GestureDetector(
      onLongPressStart: (details) {
        // 如果持续语音监听已启用，则不使用长按录音
        if (!_isContinuousListeningEnabled) {
          _longPressTimer = Timer(const Duration(seconds: 3), () {
            _startRecording();
          });
        }
      },
      onLongPressEnd: (details) {
        _longPressTimer?.cancel();
        if (_isRecording && !_isContinuousListeningEnabled) {
          _stopRecording();
        }
      },
      child: Scaffold(
        body: ref.watch(cameraControllerProvider).when(
          data: (controller) {
            if (!controller.value.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }
            return Stack(
              children: [
                // 相机预览
                Positioned.fill(
                  child: CameraPreview(controller),
                ),
                
                // 模式显示
                Positioned(
                  top: 40,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '模式: ${_currentMode.name}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                
                // 持续语音监听状态指示器
                Positioned(
                  top: 40,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(continuousVoiceState),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(continuousVoiceState),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                
                // 持续语音监听开关
                Positioned(
                  bottom: 40,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: () {
                      // 切换持续语音监听
                      ref.read(continuousVoiceEnabledProvider.notifier).state = !_isContinuousListeningEnabled;
                    },
                    backgroundColor: _isContinuousListeningEnabled ? Colors.green : Colors.grey,
                    child: Icon(
                      _isContinuousListeningEnabled ? Icons.mic : Icons.mic_off,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                // 录音状态指示器
                if (_isRecording)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red,
                          width: 4.0,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('相机初始化错误: $error'),
          ),
        ),
      ),
    );
  }
  
  // 获取状态颜色
  Color _getStatusColor(ContinuousVoiceState state) {
    switch (state) {
      case ContinuousVoiceState.idle:
        return Colors.grey;
      case ContinuousVoiceState.listening:
        return Colors.blue;
      case ContinuousVoiceState.recording:
        return Colors.red;
      case ContinuousVoiceState.processing:
        return Colors.orange;
    }
  }
  
  // 获取状态文本
  String _getStatusText(ContinuousVoiceState state) {
    switch (state) {
      case ContinuousVoiceState.idle:
        return '空闲';
      case ContinuousVoiceState.listening:
        return '等待唤醒词';
      case ContinuousVoiceState.recording:
        return '正在录音';
      case ContinuousVoiceState.processing:
        return '处理中';
    }
  }
}
