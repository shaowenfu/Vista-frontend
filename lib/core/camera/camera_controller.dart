import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// 相机控制器接口
/// 定义了相机模块需要实现的基本功能
abstract class CameraController {
  /// 初始化相机
  Future<void> initialize();

  /// 获取相机预览流
  Stream<CameraFrame> get frameStream;

  /// 拍摄静态图片
  Future<Uint8List> captureStillImage();

  /// 释放相机资源
  Future<void> dispose();
}

/// 相机帧数据模型
class CameraFrame {
  final Uint8List imageData;
  final DateTime timestamp;

  CameraFrame(this.imageData, this.timestamp);
}

/// 相机配置选项
class CameraOptions {
  final ResolutionPreset resolution;
  final bool enableAudio;
  
  const CameraOptions({
    this.resolution = ResolutionPreset.high,
    this.enableAudio = false,
  });
}

/// 分辨率预设
enum ResolutionPreset {
  low,
  medium,
  high,
  veryHigh,
  ultraHigh,
  max,
}
