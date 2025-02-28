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
import 'core/haptic/haptic_module.dart';
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
  
  @override
  void initState() {
    super.initState();
    _audioRecorder = FlutterSoundRecorder();
    WidgetsBinding.instance.addObserver(this);
    _initAudioRecorder(); // 初始化录音器
    _requestPermissions();
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
      _startAnalysisTimer();
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
  
  void _startAnalysisTimer() {
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
  
  void _sendAudioToBackend(String filePath) {
    // TODO: Implement API call to send audio file
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopAnalysisTimer();
    _permissionTimer?.cancel();
    _disposeAudioRecorder();
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
      _startAnalysisTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        _longPressTimer = Timer(const Duration(seconds: 3), () {
          _startRecording();
        });
      },
      onLongPressEnd: (details) {
        _longPressTimer?.cancel();
        if (_isRecording) {
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
                Positioned.fill(
                  child: CameraPreview(controller),
                ),
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
}
