import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 相机初始化提供者
/// 负责获取设备可用的相机列表
final availableCamerasProvider = FutureProvider<List<CameraDescription>>((ref) async {
  return await availableCameras();
});

/// 相机控制器提供者
/// 负责创建和管理相机控制器
final cameraControllerProvider = FutureProvider.autoDispose<CameraController>((ref) async {
  // 获取可用相机列表
  final cameras = await ref.watch(availableCamerasProvider.future);
  
  // 默认使用后置相机
  final camera = cameras.firstWhere(
    (camera) => camera.lensDirection == CameraLensDirection.back,
    orElse: () => cameras.first,
  );
  
  // 创建相机控制器
  final controller = CameraController(
    camera,
    ResolutionPreset.medium, // 使用中等分辨率以平衡性能和质量
    enableAudio: false, // 不需要音频
    imageFormatGroup: ImageFormatGroup.jpeg, // 使用JPEG格式
  );
  
  // 初始化相机
  await controller.initialize();
  
  // 当提供者被销毁时释放相机资源
  ref.onDispose(() {
    controller.dispose();
  });
  
  return controller;
});

/// 相机状态提供者
/// 跟踪相机的当前状态
final cameraStateProvider = StateProvider<CameraState>((ref) {
  return CameraState.initializing;
});

/// 相机状态枚举
enum CameraState {
  initializing, // 初始化中
  ready,        // 准备就绪
  analyzing,    // 分析中
  error,        // 错误状态
}
