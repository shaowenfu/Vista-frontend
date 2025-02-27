import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/camera/camera_controller_provider.dart';
import 'core/voice/voice_module.dart';
import 'core/haptic/haptic_module.dart';
import 'features/scene/services/scene_analysis_service.dart';

/// 相机页面
/// 用户打开应用后直接进入此页面，所有交互通过语音指令和触觉反馈完成
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> with WidgetsBindingObserver {
  bool _hasPermission = false;
  Timer? _analysisTimer;
  AnalysisMode _currentMode = AnalysisMode.scene;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissions();
    
    // 延迟一下，确保页面已经加载完成
    Future.delayed(const Duration(seconds: 1), () {
      _startVoiceService();
      _welcomeMessage();
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopAnalysisTimer();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 当应用进入后台时停止分析，回到前台时恢复
    if (state == AppLifecycleState.paused) {
      _stopAnalysisTimer();
    } else if (state == AppLifecycleState.resumed) {
      _startAnalysisTimer();
    }
  }
  
  /// 请求相机和麦克风权限
  Future<void> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();
    
    setState(() {
      _hasPermission = cameraStatus.isGranted && microphoneStatus.isGranted;
    });
    
    if (_hasPermission) {
      _startAnalysisTimer();
    } else {
      // 如果没有权限，通过语音提示用户
      final voiceService = ref.read(voiceCommandProvider);
      voiceService.speak('请授予相机和麦克风权限，以便应用正常工作');
    }
  }
  
  /// 启动语音服务
  Future<void> _startVoiceService() async {
    final sttService = ref.read(sttProvider);
    await sttService.initialize();
    
    // 开始监听语音命令
    await sttService.startListening(
      onResult: (text) {
        final voiceCommandService = ref.read(voiceCommandProvider);
        voiceCommandService.processCommand(text);
        
        // 根据命令切换模式
        if (text.contains('场景分析') || text.contains('分析场景')) {
          setState(() {
            _currentMode = AnalysisMode.scene;
          });
        } else if (text.contains('文字识别') || text.contains('识别文字')) {
          setState(() {
            _currentMode = AnalysisMode.ocr;
          });
        } else if (text.contains('物体检测') || text.contains('检测物体')) {
          setState(() {
            _currentMode = AnalysisMode.objectDetection;
          });
        }
        
        // 提供触觉反馈
        final hapticService = ref.read(hapticFeedbackProvider);
        hapticService.confirmationFeedback();
      },
    );
  }
  
  /// 欢迎消息
  Future<void> _welcomeMessage() async {
    final voiceService = ref.read(voiceCommandProvider);
    await voiceService.speak('欢迎使用VISTA。当前处于场景分析模式。如需切换模式，请说出相应指令，如"识别文字"或"检测物体"。');
  }
  
  /// 开始分析定时器
  void _startAnalysisTimer() {
    // 每3秒分析一次场景
    _analysisTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _analyzeCurrentFrame();
    });
  }
  
  /// 停止分析定时器
  void _stopAnalysisTimer() {
    _analysisTimer?.cancel();
    _analysisTimer = null;
  }
  
  /// 分析当前帧
  Future<void> _analyzeCurrentFrame() async {
    final cameraController = ref.read(cameraControllerProvider).valueOrNull;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    
    try {
      // 捕获图像
      final image = await cameraController.takePicture();
      final imageBytes = await image.readAsBytes();
      
      // 根据当前模式进行不同的分析
      switch (_currentMode) {
        case AnalysisMode.scene:
          await _analyzeScene(imageBytes);
          break;
        case AnalysisMode.ocr:
          // TODO: 实现OCR文字识别
          break;
        case AnalysisMode.objectDetection:
          // TODO: 实现物体检测
          break;
      }
    } catch (e) {
      print('分析当前帧错误: $e');
    }
  }
  
  /// 分析场景
  Future<void> _analyzeScene(List<int> imageBytes) async {
    final sceneService = ref.read(sceneAnalysisServiceProvider);
    final result = await sceneService.analyzeScene(Uint8List.fromList(imageBytes));
    
    if (!result.error) {
      // 通过语音播报分析结果
      final voiceService = ref.read(voiceCommandProvider);
      await voiceService.speak(result.description);
      
      // 提供触觉反馈
      final hapticService = ref.read(hapticFeedbackProvider);
      await hapticService.successFeedback();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // 使用Riverpod的异步值构建器
    return Scaffold(
      body: ref.watch(cameraControllerProvider).when(
        data: (controller) {
          if (!controller.value.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // 相机预览
          return Stack(
            children: [
              // 相机预览占满整个屏幕
              Positioned.fill(
                child: CameraPreview(controller),
              ),
              
              // 状态指示器（仅用于调试，实际应用中可以移除）
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
    );
  }
}

/// 分析模式枚举
enum AnalysisMode {
  scene,           // 场景分析
  ocr,             // 文字识别
  objectDetection, // 物体检测
}
