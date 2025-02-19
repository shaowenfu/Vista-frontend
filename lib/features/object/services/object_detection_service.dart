import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/camera/camera_controller.dart';

/// 物体检测结果模型
class ObjectDetectionResult {
  /// 检测到的物体列表
  final List<DetectedObject> objects;
  
  /// 检测的置信度 (0.0-1.0)
  final double confidence;
  
  /// 检测时间戳
  final DateTime timestamp;
  
  /// 场景上下文描述
  final String? contextDescription;

  const ObjectDetectionResult({
    required this.objects,
    required this.confidence,
    required this.timestamp,
    this.contextDescription,
  });
}

/// 检测到的物体模型
class DetectedObject {
  /// 物体类别
  final String category;
  
  /// 物体在图像中的位置
  final Rect bounds;
  
  /// 置信度 (0.0-1.0)
  final double confidence;
  
  /// 详细描述
  final String? description;
  
  /// 预估距离（米）
  final double? estimatedDistance;
  
  /// 物体属性
  final Map<String, dynamic>? attributes;

  const DetectedObject({
    required this.category,
    required this.bounds,
    required this.confidence,
    this.description,
    this.estimatedDistance,
    this.attributes,
  });
}

/// 物体检测服务接口
/// 负责处理物体检测的核心业务逻辑
abstract class ObjectDetectionService {
  /// 初始化服务
  Future<void> initialize();

  /// 开始实时物体检测
  /// 返回物体检测结果流
  Stream<ObjectDetectionResult> startRealtimeDetection();

  /// 停止实时物体检测
  Future<void> stopRealtimeDetection();

  /// 检测单帧图像中的物体
  /// [frame] 要检测的相机帧
  /// [options] 检测配置选项
  Future<ObjectDetectionResult> detectInSingleFrame(
    CameraFrame frame, {
    ObjectDetectionOptions? options,
  });

  /// 获取当前检测状态
  ObjectDetectionState get currentState;

  /// 释放资源
  Future<void> dispose();
}

/// 物体检测状态
enum ObjectDetectionState {
  /// 未初始化
  uninitialized,
  
  /// 准备就绪
  ready,
  
  /// 正在检测
  detecting,
  
  /// 检测完成
  completed,
  
  /// 发生错误
  error,
}

/// 物体检测配置选项
class ObjectDetectionOptions {
  /// 最小检测置信度阈值 (0.0-1.0)
  final double minConfidence;
  
  /// 最大检测物体数量
  final int maxDetections;
  
  /// 是否启用物体跟踪
  final bool enableTracking;
  
  /// 是否启用距离估算
  final bool enableDistanceEstimation;
  
  /// 是否生成详细描述
  final bool generateDescriptions;
  
  /// 目标物体类别列表（为空则检测所有类别）
  final List<String>? targetCategories;

  const ObjectDetectionOptions({
    this.minConfidence = 0.5,
    this.maxDetections = 10,
    this.enableTracking = true,
    this.enableDistanceEstimation = true,
    this.generateDescriptions = true,
    this.targetCategories,
  });
}

/// 物体属性类型
class ObjectAttributes {
  /// 颜色
  static const String color = 'color';
  
  /// 大小
  static const String size = 'size';
  
  /// 形状
  static const String shape = 'shape';
  
  /// 材质
  static const String material = 'material';
  
  /// 状态（如开/关、满/空等）
  static const String state = 'state';
  
  /// 方向
  static const String orientation = 'orientation';
}
