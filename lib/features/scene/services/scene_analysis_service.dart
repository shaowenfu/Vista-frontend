import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/camera/camera_controller.dart';

/// 场景分析结果模型
class SceneAnalysisResult {
  /// 场景的整体描述
  final String description;
  
  /// 场景中识别到的主要物体
  final List<DetectedObject> objects;
  
  /// 场景的空间关系描述
  final String spatialRelations;
  
  /// 分析时间戳
  final DateTime timestamp;

  const SceneAnalysisResult({
    required this.description,
    required this.objects,
    required this.spatialRelations,
    required this.timestamp,
  });
}

/// 检测到的物体模型
class DetectedObject {
  /// 物体类别
  final String category;
  
  /// 物体在图像中的位置 (相对坐标 0.0-1.0)
  final Rect location;
  
  /// 置信度 (0.0-1.0)
  final double confidence;
  
  /// 详细描述
  final String? description;

  const DetectedObject({
    required this.category,
    required this.location,
    required this.confidence,
    this.description,
  });
}

/// 场景分析服务接口
/// 负责处理场景理解的核心业务逻辑
abstract class SceneAnalysisService {
  /// 初始化服务
  Future<void> initialize();

  /// 开始实时场景分析
  /// 返回场景分析结果流
  Stream<SceneAnalysisResult> startRealtimeAnalysis();

  /// 停止实时场景分析
  Future<void> stopRealtimeAnalysis();

  /// 分析单帧图像
  /// [frame] 要分析的相机帧
  Future<SceneAnalysisResult> analyzeSingleFrame(CameraFrame frame);

  /// 获取当前分析状态
  SceneAnalysisState get currentState;

  /// 释放资源
  Future<void> dispose();
}

/// 场景分析状态
enum SceneAnalysisState {
  /// 未初始化
  uninitialized,
  
  /// 准备就绪
  ready,
  
  /// 正在分析
  analyzing,
  
  /// 分析完成
  completed,
  
  /// 发生错误
  error,
}

/// 场景分析配置选项
class SceneAnalysisOptions {
  /// 是否启用物体检测
  final bool enableObjectDetection;
  
  /// 是否启用空间关系分析
  final bool enableSpatialAnalysis;
  
  /// 最小物体检测置信度阈值 (0.0-1.0)
  final double minConfidence;
  
  /// 分析结果语言
  final String language;

  const SceneAnalysisOptions({
    this.enableObjectDetection = true,
    this.enableSpatialAnalysis = true,
    this.minConfidence = 0.5,
    this.language = 'zh-CN',
  });
}
